import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:multiculturalapp/MyWidgets/clippingClass.dart';
import 'package:provider/provider.dart';
import 'package:multiculturalapp/MyWidgets/progress.dart';

import 'package:multiculturalapp/model/tournaments.dart';

import '../NextGameDetails.dart';

class GoldOnlyAdmin extends StatefulWidget {
  @override
  _GoldOnlyAdminState createState() => _GoldOnlyAdminState();
}

class _GoldOnlyAdminState extends State<GoldOnlyAdmin> {
  var tournamentInstance = Firestore.instance.collection("ourtournaments");

  bool _isloading;
  bool _goldIsFinished;
  String futureMatchProgress;
  String tournamentId;
  int TeamsInTournamentGold;
  String matchProgress;
  List<String> goldWinnerList = [];
  List<String> futurePhaseMatches = [];

//1.) Chekcs tournamentProgress to update views to the current Phase.
  checkTournamentProgress() async {
    var fireDoc = await tournamentInstance
        .doc(tournamentId)
        .collection("Status")
        .doc("Finals")
        .get();

    matchProgress = fireDoc.data()["matchProgress"];

    setState(() {
      _isloading = false;
    });
  }

//2.) In Finish Phase wer finish the current Gold Phase and advance to the next one.

  finishPhase() async {
    goldWinnerList.clear();

    //2.1) First we determin the futureMatchPRogress in an if Statement.
    if (matchProgress == "32 Teams left") {
      futureMatchProgress = "Eighth - Final";
      TeamsInTournamentGold = 32;
    } else if (matchProgress == "Eighth - Final") {
      futureMatchProgress = "Quarter - Final";
      TeamsInTournamentGold = 16;
    } else if (matchProgress == "Quarter - Final") {
      futureMatchProgress = "Semi - Final";
      TeamsInTournamentGold = 8;
    } else if (matchProgress == "Semi - Final") {
      futureMatchProgress = "Grand Finale";
      TeamsInTournamentGold = 4;
    } else if (matchProgress == "Grand Finale") {
      futureMatchProgress = "Gold - Over";
    } else if (matchProgress == "Gold - Over") {
      futureMatchProgress = "Gold - Over";
      _goldIsFinished = true;
    }

    //2.2.) We update the matchProgress in the Status collection of the Database to the futureMatchProgress.
    await tournamentInstance
        .doc(tournamentId)
        .collection("Status")
        .doc("Finals")
        .update({"matchProgress": futureMatchProgress});

    // 2.3) We get a list<String> of all Winners (goldWinnerList).
    var FireWinner = await tournamentInstance
        .doc(tournamentId)
        .collection("countries")
        .where("$matchProgress Winner", isEqualTo: true)
        .get();

    var fireWinnerdocNR;
    int NR = 0;
    for (var i = 0; i < FireWinner.docs.length; i++) {
      fireWinnerdocNR = FireWinner.docs[NR];
      goldWinnerList.add(fireWinnerdocNR.data()["CountryName"]);

      NR++;
    }

    print(goldWinnerList);

    // ONLY IF TOURNAMENT IS NOT FINISHED
    if (!_goldIsFinished) {
      // 2.4 We create a list of future Matches for the next Gold Phase (futurePhaseMatches <String>.
      String team1;
      String team2;
      int teamNR = 0;
      NR = 0;
      futurePhaseMatches.clear();
      for (var i = 0; i < goldWinnerList.length / 2; i++) {
        team1 = goldWinnerList[teamNR];
        team2 = goldWinnerList[teamNR + 1];

        futurePhaseMatches.add("$team1 vs. $team2");

        teamNR = teamNR + 2;
        NR++;
      }
      print(futurePhaseMatches);

      // 2.5 We upload the futureMatches List to the "Summary" collection in our database so it appears in the first ListView of our GoldMatches Streamvuilder.
      tournamentInstance
          .doc(tournamentId)
          .collection("Summary")
          .doc("Finals")
          .update({"GoldMatchList": futurePhaseMatches});

      // 2.6 upload all Match Data for each Country still in Game.

      //2.6.1
      Map<String, dynamic> uploadWinnerMap = {};
      NR = 0;
      double NR2 = 0;
      teamNR = 0;
      String currentMatch;
      String country1;
      String country2;
      for (var i = 0; i < goldWinnerList.length; i++) {
        print("This is the $goldWinnerList");
        print(goldWinnerList[teamNR]);
        print(futurePhaseMatches[NR]);

        print("This is the $futurePhaseMatches");
        print("This is the currentMatch $currentMatch");
        currentMatch = futurePhaseMatches[NR];

        // Here we get the teams involved in the game and add them into the Map as TEam1 and TEam2.
        var arr = currentMatch.split(" ");
        country1 = arr[0];
        country2 = arr[2];

        uploadWinnerMap.putIfAbsent(
          goldWinnerList[teamNR],
          () => {"matchId": currentMatch, "Team1": country1, "Team2": country2},
        );

        print(currentMatch);
        // upload the current Country in to Country - Finals collection so the user and Admin will be able to write and read result of the next phase.
        await tournamentInstance
            .doc(tournamentId)
            .collection("countries")
            .doc(goldWinnerList[teamNR])
            .collection("Finals")
            .doc(currentMatch)
            .set({
          "hangeRegister": "",
          "GameName": futureMatchProgress,
          "Group": "Gold",
          "Result $country1": "",
          "Result $country2": "",
          "Team1": team1,
          "Team2": team2,
        }, SetOptions(merge: true));

        teamNR++;
        NR2 = NR2 + 0.5;
        if (NR2 == 1 || NR2 == 2 || NR2 == 3) {
          NR++;
        } else if (NR2 == 4 || NR2 == 5 || NR2 == 6) {
          NR++;
        } else if (NR2 == 7 || NR2 == 8 || NR2 == 9) {
          NR++;
        }
      }

      List<String> goldLooserList = [];
      // 3) Mark the "Loosers" in their Country.
      var FireLooser = await tournamentInstance
          .doc(tournamentId)
          .collection("countries")
          .where("$matchProgress Winner", isEqualTo: false)
          .get();

      NR = 0;
      for (var i = 0; i < FireWinner.docs.length; i++) {
        var fireLooserdocNR = FireLooser.docs[NR];
        var looserVar = fireLooserdocNR.data()["CountryName"];

        goldLooserList.add(looserVar);

        NR++;
      }

      NR = 0;
      for (var i = 0; i < goldLooserList.length; i++) {
        await tournamentInstance
            .doc(tournamentId)
            .collection("countries")
            .doc(goldLooserList[NR])
            .set({"Disqualified": true}, SetOptions(merge: true));
        NR++;
      }
    }
    // If the tournament is Finished, bring the user to the Finish Screen.

    setState(() {
      matchProgress = futureMatchProgress;
    });
  }

  creditPoints() async {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('Points are being credited to gold-athlets... .'),
      duration: Duration(seconds: 2),
    ));

    var fireSummary = await tournamentInstance
        .doc(tournamentId)
        .collection("Summary")
        .doc("Finals")
        .get();

    List<dynamic> goldList = fireSummary.data()["GoldTeams"];

    print("here the gold list");
    print(goldList);

    var NR = 0;

    bool _isGoldWinner;
    String userID1;
    String userID2;
    String currentCountry;
    int currentTeamWins;
    int goldPhaseGamesofCurrentTeam;
    int newPointsTeam;
    int currentTeamLost;

    int player1OldPoints;
    int player1OldWins;
    int player1OldLost;

    int player1NewPoints;
    int player1NewWins;
    int player1NewLost;

    int player2OldPoints;
    int player2OldWins;
    int player2OldLost;
    double newRatioP1;
    String newLvlP1;

    int player2NewPoints;
    int player2NewWins;
    int player2NewLost;
    double newRatioP2;
    String newLvlP2;

    for (var i = 0; i < goldList.length; i++) {
      currentCountry = goldList[NR];

      // Find out how many points made every Team (=country) from the GoldList.

      //1.) GAMES PLAYED
      // First we look how many games the current Team played in the Gold Group
      var totalGamesFire = await tournamentInstance
          .doc(tournamentId)
          .collection("countries")
          .doc(currentCountry)
          .collection("Finals")
          .get();

      goldPhaseGamesofCurrentTeam = totalGamesFire.docs.length;

      //2.) GAMES WON
      // Then we look how many games the currentTeam won in the Gold Phase.
      var totalGamesWonFire = await tournamentInstance
          .doc(tournamentId)
          .collection("countries")
          .doc(currentCountry)
          .collection("Finals")
          .where("Winner", isEqualTo: currentCountry)
          .get();

      currentTeamWins = totalGamesWonFire.docs.length;

      // 3.) GAMES LOST
      currentTeamLost = goldPhaseGamesofCurrentTeam - currentTeamWins;

      //4.) NEW POINTS

      newPointsTeam = currentTeamWins * 3;

      var fireCurrentCountry = await tournamentInstance
          .doc(tournamentId)
          .collection("countries")
          .doc(currentCountry)
          .get();

      _isGoldWinner = fireCurrentCountry.data()["Grand Finale Winner"];

      if (_isGoldWinner == null) {
        _isGoldWinner = false;
      }
      if (_isGoldWinner) {
        newPointsTeam = newPointsTeam + 10;
      }

      // Find out who played in this Country (userIds)
      var countryFire = await tournamentInstance
          .doc(tournamentId)
          .collection("countries")
          .doc(currentCountry)
          .get();

      userID1 = countryFire.data()["player1ID"];
      userID2 = countryFire.data()["player2ID"];

      // Now we find out how many points the athlets have so far (old Data)
      var fireUser1 = await FirebaseFirestore.instance
          .collection("users")
          .doc(userID1)
          .get();

      player1OldPoints = fireUser1.data()["points"];
      player1OldLost = fireUser1.data()["historyGamesLost"];

      if (player1OldLost == 0) {player1OldLost=1;}

      player1OldWins = fireUser1.data()["historyGamesWon"];

      var fireUser2 = await FirebaseFirestore.instance
          .collection("users")
          .doc(userID2)
          .get();

      player2OldPoints = fireUser2.data()["points"];
      player2OldLost = fireUser2.data()["historyGamesLost"];

      if (player2OldLost == 0) {player2OldLost=1;}

      player2OldWins = fireUser2.data()["historyGamesWon"];

      // Now we add the old and new points together.
      // Player1
      player1NewPoints = player1OldPoints + newPointsTeam;

      player1NewWins = player1OldWins + currentTeamWins;

      player1NewLost = player1OldLost + currentTeamLost;

      newRatioP1 = player1NewWins / player1NewLost;

      if (player1NewPoints >= 100 && newRatioP1 > 2) {
        newLvlP1 = "Volley God";
      } else if (player1NewPoints >= 50 && newRatioP1 > 1) {
        newLvlP1 = "Experienced";
      } else if (player1NewPoints >= 30) {
        newLvlP1 = "Grown-Up";
      } else if (player1NewPoints >= 20) {
        newLvlP1 = "Amateur";
      } else if (player1NewPoints >= 10) {
        newLvlP1 = "Little Child";
      } else {
        newLvlP1 = "Baby Beginner";
      }

// Player2
      player2NewPoints = player2OldPoints + newPointsTeam;

      player2NewWins = player2OldWins + currentTeamWins;

      player2NewLost = player2OldLost + currentTeamLost;


      newRatioP2 = player2NewWins / player2NewLost;

      if (player2NewPoints >= 100 && newRatioP2 > 2) {
        newLvlP2 = "Volley God";
      } else if (player2NewPoints >= 50 && newRatioP2 > 1) {
        newLvlP2 = "Experienced";
      } else if (player2NewPoints >= 30) {
        newLvlP2 = "Grown-Up";
      } else if (player2NewPoints >= 20) {
        newLvlP2 = "Amateur";
      } else if (player2NewPoints >= 10) {
        newLvlP2 = "Little Child";
      } else {
        newLvlP2 = "Baby Beginner";
      }

      // Update User Data on Firebase
      FirebaseFirestore.instance.collection("users").doc(userID1).update({
        "points": player1NewPoints,
        "historyGamesWon": player1NewWins,
        "historyGamesLost": player1NewLost,
        "winLooseRatio": newRatioP1,
        "achievedlvl": newLvlP1,
      });
      // Update User Data on Firebase
      FirebaseFirestore.instance.collection("users").doc(userID2).update({
        "points": player2NewPoints,
        "historyGamesWon": player2NewWins,
        "historyGamesLost": player2NewLost,
        "winLooseRatio": newRatioP2,
        "achievedlvl": newLvlP2,
      });

      NR++;
    }
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('Points have been successfully credited to users .'),
      duration: Duration(seconds: 5),
    ));
  }

  finishtournamentGold() async {
    await tournamentInstance
        .doc(tournamentId)
        .collection("Status")
        .doc("Finals")
        .update({"matchProgress": "Gold - Over"});
  }

  @override
  void initState() {
    _isloading = true;
    _goldIsFinished = false;

    final tournamentInfo = Provider.of<Tournaments>(context, listen: false);

    final tournamentiform = tournamentInfo.item;
    tournamentId = tournamentiform[0].tournamentid;

    checkTournamentProgress();

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isloading
        ? SizedBox(
            height: 1,
          )
        : SingleChildScrollView(
            child: Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        width: 70,
                        height: 50,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    "assets/images/congratstrophy.png"))),
                      ),
                      Text(
                        "Gold Match",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.width,
                    child: StreamBuilder(
                        stream: Firestore.instance
                            .collection("ourtournaments")
                            .doc(tournamentId)
                            .collection("Summary")
                            .snapshots(),
                        builder: (context, tsnapshot) {
                          if (tsnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return circularProgress();
                          }
                          //Data Snapshot
                          var _loadeddata = tsnapshot.data.documents;
                          var goldMatchListIndex = _loadeddata[0];
                          var goldMatchList =
                              goldMatchListIndex.data()["GoldMatchList"];

                          return ListView.builder(
                              itemCount: goldMatchList.length,
                              itemBuilder: (ctx, i) {
                                return InkWell(
                                  onTap: () {
                                    String myCountry;
                                    List<String> arr = [];

                                    String clickedGame = goldMatchList[i];
                                    arr = clickedGame.split(" ");
                                    myCountry = arr[0];

                                    Navigator.of(context).pushNamed(
                                        NextGameDetails.link,
                                        arguments: {
                                          "matchId": goldMatchList[i],
                                          "silverFinals": false,
                                          "goldGameNAme": matchProgress,
                                          "adminCountry": myCountry,
                                        });
                                  },
                                  child: Container(
                                    height: 60,

                                    margin: EdgeInsets.symmetric(
                                      vertical: 5,
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.1),

                                    decoration: BoxDecoration(
                                        color: HexColor("#e9e9e9"),
                                        borderRadius:
                                            BorderRadius.circular(11)),
                                    child: Center(
                                      child: Text(
                                        goldMatchList[i],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              });
                        }),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    color: HexColor("#ffe664"),
                    child: Stack(
                      children: [
                        ClipPath(
                          clipper: ClippingClass(),
                          child: Container(
                            color: Colors.white,
                            height: MediaQuery.of(context).size.height * 0.125,
                            width: double.infinity,
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                                child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.15,
                                ),
                                Text(
                                  "Results",
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.15,
                                  width: MediaQuery.of(context).size.width,
                                  child: StreamBuilder(
                                    stream: tournamentInstance
                                        .document(tournamentId)
                                        .collection("countries")
                                        .where("${matchProgress} Winner",
                                            isEqualTo: true)
                                        .snapshots(),
                                    builder: (context, tsnapshot) {
                                      if (tsnapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return circularProgress();
                                      }
                                      //Data Snapshot

                                      var _loadeddata =
                                          tsnapshot.data.documents;
                                      var _loadedDataIndexInfo;
                                      return ListView.builder(
                                        itemCount: _loadeddata.length,
                                        itemBuilder: (ctx, i) {
                                          _loadedDataIndexInfo = _loadeddata[i];

                                          if (_loadeddata.length == null) {
                                            return Text("No further matches");
                                          } else {
                                            return Container(
                                              height: 60,
                                              margin: EdgeInsets.symmetric(
                                                vertical: 5,

                                                  horizontal:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.1),

                                              decoration: BoxDecoration(
                                                  color: HexColor("#e9e9e9"),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          11)),
                                              child: Center(
                                                child: Text(
                                                  _loadedDataIndexInfo.data()[
                                                      "${matchProgress} Score"],
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )),
                            _goldIsFinished
                                ? Text("Gold Phase finished")
                                : Column(
                                    children: [
                                      Container(
                                          child: Builder(
                                        builder: (context) => RaisedButton(
                                            onPressed: () {
                                              if (matchProgress ==
                                                  "Gold - Over") {

                                                Scaffold.of(context).showSnackBar(SnackBar(
                                                  content: Text('Gold - Phase is finished. Points have already been credited to athlets.... .'),
                                                  duration: Duration(seconds: 5),
                                                ));
                                                return;
                                              } else if (matchProgress ==
                                                  "Grand Finale") {
                                                finishtournamentGold();
                                                creditPoints();
                                                setState(() {
                                                  _goldIsFinished=true;
                                                });

                                                return;
                                              } else {
                                                finishPhase();
                                              }
                                            },
                                            child: Text(
                                                "Finish ${matchProgress}")),
                                      )),
                                    ],
                                  ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
