import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:multiculturalapp/MyWidgets/TournamentInfoScr/tournamentinfo.dart';
import 'package:provider/provider.dart';
import 'package:multiculturalapp/MyWidgets/TournOnWidgets/GameCard.dart';
import 'package:multiculturalapp/MyWidgets/progress.dart';
import 'package:multiculturalapp/Screens/Final/SilverWinnerListviewbuilder.dart';
import 'package:multiculturalapp/model/tournaments.dart';

import '../NextGameDetails.dart';

// THIS IS AN ADMIN ONLY SCREEN and is opened by the Pageview of the FinalsAdmin Screen.
class SilverOnlyMatches extends StatefulWidget {
  @override
  _SilverOnlyMatchesState createState() => _SilverOnlyMatchesState();
}

class _SilverOnlyMatchesState extends State<SilverOnlyMatches> {
  var tournamentInstance = Firestore.instance.collection("ourtournaments");
  bool _isloading;
  bool _countrySelected;
  bool _showScore;
  bool _silverFinished;

  String tournamentId;
  String countryNow;
  String myCountry;
  String currentGroupNR;
  List<List> silverCandidates = [];
  List countryData = [];
  List countryList = [];
  Map<String, dynamic> countryMap = {};

  Column buildCountrySelecter() {
    return Column(
      children: <Widget>[
        Card(
          elevation: 5,
          color: Colors.white,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.125,
            width: MediaQuery.of(context).size.width,
            child: GridView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: silverCandidates.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 1 / 2,
                ),
                itemBuilder: (context, i) {
                  countryData = silverCandidates[i];

                  countryNow = countryData[0];
                  currentGroupNR = countryData[1].toString();

                  return Container(
                    width: MediaQuery.of(context).size.width * 0.2,
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                        color: HexColor("#d8d8d8"),
                        border: Border.all(width: 1),
                        borderRadius: BorderRadius.circular(11)),
                    child: InkWell(
                      onTap: () async {
                        setState(() {
                          _isloading = true;
                        });
                        countryData = silverCandidates[i];

                        countryNow = countryData[0];
                        var newCountrydoc = await tournamentInstance
                            .doc(tournamentId)
                            .collection("countries")
                            .doc(countryNow)
                            .id;

                        myCountry = newCountrydoc;
                        _countrySelected = true;
                        setState(() {
                          _isloading = false;
                        });
                      },
                      child: _isloading
                          ? circularProgress()
                          : Container(
                              width: MediaQuery.of(context).size.width * 0.2,
                              height: MediaQuery.of(context).size.height * 0.1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    countryNow,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "Group $currentGroupNR",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  );
                }),
          ),
        ),
      ],
    );
  }

  //1.) Get Final Candidates which we need for the Streambuilder which shows all the matches.
  getSilverFinalsCanidates() async {
    var FireSilverCandidates = await tournamentInstance
        .doc(tournamentId)
        .collection("countries")
        .where("Finalgroup", isEqualTo: "Silver")
        .get();

    setState(() {
      FireSilverCandidates.docs.forEach((element) {
        silverCandidates.add(
            [element.data()["CountryName"], element.data()["silverGroup"]]);

        _isloading = false;
        return;
      });
    });
  }

  // 2.) Function that brings us to the Score Changing view (NextGameDetails)
  void onGameCardTap(BuildContext context, String matchId) {
    Navigator.of(context).pushNamed(NextGameDetails.link, arguments: {
      "matchId": matchId,
      "adminCountry": myCountry,
      "silverFinals": true,
      "goldGameNAme": ""
    });
  }

  //3.) Finish Silver Group Tournament

  void finishSilverPhase() async {
    // 3.1) Disqualify all players, as they finished the tournament.
    int NR = 0;
    for (var i = 0; i < silverCandidates.length; i++) {
      var silverData = silverCandidates[NR];

      await tournamentInstance
          .doc(tournamentId)
          .collection("countries")
          .doc(silverData[0])
          .set({"Disqualified": true}, SetOptions(merge: true));
      NR++;
    }

    // Nr.3.2) UPdate the Silver Tournament Status.

    tournamentInstance
        .doc(tournamentId)
        .collection("Status")
        .doc("Finals")
        .set({"silverFinished": true}, SetOptions(merge: true));
  }

  calculateScore() async {
    countryMap.clear();
    countryList.clear();

    tournamentInstance
        .doc(tournamentId)
        .collection("countries")
        .get()
        .then((countryDoc) async {
      int totalTeams = silverCandidates.length;

      //4.1) Create first Country: groupNumber Group
      int countryNR = 0;
      String currentTeam;
      String currentTeamGroup;
      int countryWins;

      int gamesInGroup;
      int countryLost;
      int runningNR = 0;
      for (var i = 0; i < totalTeams; i++) {
        var silverData = silverCandidates[countryNR];
        // Here we create a nested Map with each country and GroupNumber:
        // {Austria: {groupNumbar: 1}, Brazil: {groupNumbar: 1}, China: {groupNumbar: 2}}
        currentTeam = silverData[0];

        var countryDocCountryNR = countryDoc.docs[countryNR];
        currentTeamGroup = countryDocCountryNR.data()["groupNumber"];

        var countryWinResults = await tournamentInstance
            .doc(tournamentId)
            .collection("countries")
            .doc(currentTeam)
            .collection("Finals")
            .where("Winner", isEqualTo: currentTeam)
            .get();

        countryWins = countryWinResults.docs.length;

        var countryResults = await tournamentInstance
            .doc(tournamentId)
            .collection("countries")
            .doc(currentTeam)
            .collection("Finals")
            .get();

        // Now we determine how many Points the currentTEam made in each match and add it to a list.
        gamesInGroup = countryResults.docs.length;
        List<int> PointResults = [];
        String player1ID;
        String player2ID;
        int accumulatedPoints;
        int currentResult;

        int player1OldPoints;
        int player1OldWins;
        int player1OldLost;

        int player1NewPoints;
        int player1NewWins;
        int player1NewLost;
        double player1newRatio;
        String player1NewLvl;

        int player2OldPoints;
        int player2OldWins;
        int player2OldLost;

        int player2NewPoints;
        int player2NewWins;
        int player2NewLost;
        double player2newRatio;
        String player2NewLvl;

        var matchIndex = 0;

        countryLost = gamesInGroup - countryWins;

        // Find out who was playing in the teams.

        var fireCountry = await tournamentInstance
            .doc(tournamentId)
            .collection("countries")
            .doc(currentTeam)
            .get();

        player1ID = fireCountry.data()["player1ID"];
        player2ID = fireCountry.data()["player2ID"];

        // Get old points of athlets

        var fireUser1 = await FirebaseFirestore.instance
            .collection("users")
            .doc(player1ID)
            .get();

        player1OldPoints = fireUser1.data()["points"];
        player1OldWins = fireUser1.data()["historyGamesWon"];
        player1OldLost = fireUser1.data()["historyGamesLost"];

        var fireUser2 = await FirebaseFirestore.instance
            .collection("users")
            .doc(player2ID)
            .get();

        player2OldPoints = fireUser2.data()["points"];
        player2OldWins = fireUser2.data()["historyGamesWon"];
        player2OldLost = fireUser2.data()["historyGamesLost"];

        player1NewPoints = player1OldPoints + countryWins;
        player1NewWins = player1OldWins + countryWins;
        player1NewLost = player1OldLost + countryLost;
        player1newRatio = player1NewWins / player1NewLost;

        if (player1NewPoints >= 100 && player1newRatio > 2) {
          player1NewLvl = "Volley God";
        } else if (player1NewPoints >= 50 && player1newRatio > 1) {
          player1NewLvl = "Experienced";
        } else if (player1NewPoints >= 30) {
          player1NewLvl = "Grown-Up";
        } else if (player1NewPoints >= 20) {
          player1NewLvl = "Amateur";
        } else if (player1NewPoints >= 10) {
          player1NewLvl = "Little Child";
        } else {
          player1NewLvl = "Baby Beginner";
        }

        player2NewPoints = player2OldPoints + countryWins;
        player2NewWins = player2OldWins + countryWins;
        player2NewLost = player2OldLost + countryLost;
        player2newRatio = player2NewWins / player2NewLost;

        if (player2NewPoints >= 100 && player2newRatio > 2) {
          player2NewLvl = "Volley God";
        } else if (player2NewPoints >= 50 && player2newRatio > 1) {
          player2NewLvl = "Experienced";
        } else if (player2NewPoints >= 30) {
          player2NewLvl = "Grown-Up";
        } else if (player2NewPoints >= 20) {
          player2NewLvl = "Amateur";
        } else if (player2NewPoints >= 10) {
          player2NewLvl = "Little Child";
        } else {
          player2NewLvl = "Baby Beginner";
        }

        // Update User Data on DB

        await FirebaseFirestore.instance
            .collection("users")
            .doc(player1ID)
            .update({
          "points": player1NewPoints,
          "historyGamesWon": player1NewWins,
          "historyGamesLost": player1NewLost,
          "winLooseRatio": player1newRatio,
          "achievedLvl": player1NewLvl,
        });
        await FirebaseFirestore.instance
            .collection("users")
            .doc(player2ID)
            .update({
          "points": player2NewPoints,
          "historyGamesWon": player2NewWins,
          "historyGamesLost": player2NewLost,
          "winLooseRatio": player2newRatio,
          "achievedLvl": player2NewLvl,
        });

        // Here we fill the PointResult List
        for (var iii = 0; iii < gamesInGroup; iii++) {
          var countryResultdocMatchIndex = countryResults.docs[matchIndex];
          currentResult = int.parse(
              countryResultdocMatchIndex.data()["Result $currentTeam"]);

          PointResults.add(currentResult);

          matchIndex++;
        }

        // Here we put the GroupNumber, Wins and accumulated Points in one big List.
        countryMap.putIfAbsent(currentTeam, () {
          accumulatedPoints = PointResults.reduce((a, b) => a + b);

          return {
            "groupNumbar": currentTeamGroup,
            "Wins": countryWins,
            "accumulatedPoints": accumulatedPoints
          };
        });

        countryList.add({
          "runningNR": runningNR,
          "currentTeam": currentTeam,
          "currentTeamGroup": currentTeamGroup,
          "countryWins": countryWins,
          "accumulatedPoints": accumulatedPoints,
          "goldGroup": false,
        });
        runningNR++;

        // Sort CountryMap

        // var Map = SortedMap.from(countryMap["Wins"]);

        countryNR++;
      }

      await tournamentInstance
          .doc(tournamentId)
          .collection("Summary")
          .doc("Finals")
          .set({"SilverScoreTable": countryList}, SetOptions(merge: true));

      setState(() {
        _showScore = true;
        _countrySelected = false;
        _silverFinished = true;
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Silver phase finished successfully...'),
        ));
      });
      // 4.2) Create second country: Wins map.
    });
  }

  checkifSilverfinished() async {
    var fireSilver = await tournamentInstance
        .doc(tournamentId)
        .collection("Status")
        .doc("Finals")
        .get();

    _silverFinished = fireSilver.data()["silverFinished"];

    if (_silverFinished == null) {
      _silverFinished = false;
    }
  }

  @override
  void initState() {
    _isloading = true;
    _countrySelected = false;
    _showScore = false;
    _silverFinished = false;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final tournamentInfo = Provider.of<Tournaments>(context, listen: false);

      final tournamentiform = tournamentInfo.item;
      tournamentId = tournamentiform[0].tournamentid;

      checkifSilverfinished();

      getSilverFinalsCanidates();
    });

    // 3.) On GameCard Admin Functio9n - Change Group

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isloading
        ? circularProgress()
        : SingleChildScrollView(
            child: Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 30, bottom: 20),
                    child: Text(
                      "Silver Group",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      "Admin Functions",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      "Step 1: Select Country",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  buildCountrySelecter(),
                  if (_countrySelected && !_showScore)
                    Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(top: 20),
                      child: StreamBuilder(
                          stream: tournamentInstance
                              .doc(tournamentId)
                              .collection("countries")
                              .doc(myCountry)
                              .collection("Finals")
                              .snapshots(),
                          builder: (context, tsnapshot) {
                            if (tsnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return circularProgress();
                            }
                            //Data Snapshot
                            var _loadeddata = tsnapshot.data.documents;
                            var _loadeddataIndexdata;
                            String team1;
                            String team2;

                            return ListView.builder(
                                itemCount: _loadeddata.length,
                                itemBuilder: (context, i) {
                                  _loadeddataIndexdata = _loadeddata[i];
                                  team1 = _loadeddataIndexdata.data()["Team1"];
                                  team2 = _loadeddataIndexdata.data()["Team2"];
                                  return InkWell(
                                    onTap: () {
                                      onGameCardTap(
                                          context, _loadeddata[i].documentID);
                                    },
                                    child: GameCard(
                                      team1: team1,
                                      team2: team2,
                                      Result1: _loadeddataIndexdata
                                          .data()["Result $team1"],
                                      Result2: _loadeddataIndexdata
                                          .data()["Result $team2"],
                                    ),
                                  );
                                });
                          }),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: Center(
                          child: Text(
                        "No country selected yet.",
                        style: TextStyle(fontSize: 15),
                      )),
                    ),
                  _showScore
                      ? Column(
                          children: <Widget>[
                            SizedBox(
                              height: 70,
                            ),
                            SilverWinnerListviewbuilder(
                              countryList: countryList,
                            ),
                          ],
                        )
                      : SizedBox(
                          height: 0,
                        ),
                  Builder(
                    builder: (context) => FlatButton.icon(
                        onPressed: () {
                          if (!_silverFinished) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Silver phase finished. Points are being credited to athtlets...'),
                            ));

                            finishSilverPhase();
                            calculateScore();
                          } else {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text('Silver Phase is already over...'),
                            ));
                          }
                        },
                        icon: Icon(Icons.navigate_next),
                        label: Text(!_silverFinished
                            ? "Finish Silver Phase"
                            : "Silver Finished")),
                  )
                ],
              ),
            ),
          );
  }
}
