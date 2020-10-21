import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:multiculturalapp/MyWidgets/clippingClass.dart';
import 'package:provider/provider.dart';
import 'package:multiculturalapp/MyWidgets/TournOnWidgets/GameCard.dart';
import 'package:multiculturalapp/MyWidgets/TournOnWidgets/myCountryInfo.dart';
import 'package:multiculturalapp/MyWidgets/myAppBars/flagAppBar.dart';
import 'package:multiculturalapp/MyWidgets/progress.dart';
import 'package:multiculturalapp/Screens/Final/tournamentFinished.dart';
import 'package:multiculturalapp/model/countryInfos.dart';
import 'package:multiculturalapp/model/tournaments.dart';

import '../NextGameDetails.dart';

class SilverGroupUser extends StatefulWidget {
  static const link = "/SilverGroupUser";

  @override
  _SilverGroupUserState createState() => _SilverGroupUserState();
}

class _SilverGroupUserState extends State<SilverGroupUser> {
  var tournamentinstance =
      FirebaseFirestore.instance.collection("ourtournaments");
  bool _isloading;
  bool _finished;
  String tournamentId;
  String myCountry;
  String mygroupNR;
  String myFlag;
  int myGamesWon;
  int myGamesLost;

  getWins() async {
    // --> Calculate how many times we won/lost
    var winnerdata = await tournamentinstance
        .doc(tournamentId)
        .collection("countries")
        .doc(myCountry)
        .collection("Finals")
        .where("Winner", isEqualTo: myCountry)
        .get();

    if (winnerdata.documents.isEmpty) {
      myGamesWon = 0;
    } else {
      myGamesWon = winnerdata.documents.length;
    }

    print("My Games Won $myGamesWon");
    var looserData = await tournamentinstance
        .doc(tournamentId)
        .collection("countries")
        .doc(myCountry)
        .collection("Finals")
        .where("Looser", isEqualTo: myCountry)
        .get();

    if (looserData.docs.isEmpty) {
      print("Doc is empty!");
      myGamesLost = 0;
    } else {
      myGamesLost = looserData.documents.length;
    }

    setState(() {
      _isloading = false;
    });
  }

  // Checks in which Group we play
  getCountryGroup() async {
    getWins();

    var countryFire = await tournamentinstance
        .doc(tournamentId)
        .collection("countries")
        .doc(myCountry)
        .get();

    mygroupNR = countryFire.data()["silverGroup"].toString();

    print("This is the SilverGroupNR $mygroupNR");
  }

  // Brings us to the MatchDetailsScreen where we can introduce the GAme Results.
  void onGameCardTap(BuildContext context, String matchId) {
    Navigator.of(context).pushNamed(NextGameDetails.link, arguments: {
      "matchId": matchId,
      "adminCountry": myCountry,
      "silverFinals": true,
      "goldGameNAme": ""
    });
  }

  // Will be called if user wants to finish the Silver Phase - Check if Admin gave OK
  void checkGameStatus(ctx) async {
    await tournamentinstance
        .doc(tournamentId)
        .collection("Status")
        .doc("Finals")
        .get()
        .then(
      (doc) {
        if (doc.data()["silverFinished"] == true) {
          _finished = true;
          // getMyFinalStatus is executed to fill out arguments of popandPushNamed.
          Navigator.of(context).popAndPushNamed(TournamentFinished.link);
        } else {
          _finished = false;

          Scaffold.of(ctx).openDrawer();
          Scaffold.of(ctx).showSnackBar(SnackBar(
              content: Text(
                "There are still some teams playing. Please wait for Admin Confirmation.",
                textAlign: TextAlign.center,
              ),
              duration: Duration(seconds: 5)));
        }
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isloading = true;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // Get tournamentID from Provider
      final tournamentInfo = Provider.of<Tournaments>(context, listen: false);
      final tournamentiform = tournamentInfo.item;
      tournamentId = tournamentiform[0].tournamentid;

      // Get tournamentID from Provider
      final countryInfo = Provider.of<Countryinfos>(context, listen: false);
      final countryInform = countryInfo.item;
      myCountry = countryInform[0].myCountry;
      myFlag = countryInform[0].myFlag;

      getCountryGroup();
      getWins();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isloading
          ? circularProgress()
          : SingleChildScrollView(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    flagAppBar(myFlag: myFlag, screenHeightPercentage: 0.25),
                    MyCountryInfo(
                      myCountry: myCountry,
                      phase: "Silver Group",
                      myWins: myGamesWon.toString(),
                      myLost: myGamesLost.toString(),
                      groupNR: mygroupNR,
                    ),
                    SizedBox(height: 10),
                    Stack(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          width: double.infinity,
                          color: HexColor("#ffe664"),
                        ),
                        ClipPath(
                          clipper: ClippingClass(),
                          child: Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.1,
                            color: Colors.white,
                          ),
                        ),
                        Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.15,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                "Next Matches",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black.withOpacity(0.8)),
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.3,
                              width: MediaQuery.of(context).size.width,
                              child: StreamBuilder(
                                  stream: tournamentinstance
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

                                    String team1;
                                    String team2;
                                    print(_loadeddata.length);
                                    return ListView.builder(
                                        itemCount: _loadeddata.length,
                                        itemBuilder: (context, i) {
                                          var processData = _loadeddata[i];
                                          team1 = processData.data()["Team1"];
                                          team2 = processData.data()["Team2"];
                                          return InkWell(
                                            onTap: () {
                                              onGameCardTap(context,
                                                  _loadeddata[i].documentID);
                                            },
                                            child: GameCard(
                                              team1: team1,
                                              team2: team2,
                                              Result1: processData
                                                  .data()["Result $team1"],
                                              Result2: processData
                                                  .data()["Result $team2"],
                                            ),
                                          );
                                        });
                                  }),
                            ),
                            Builder(builder: (mycontext) {
                              return Container(
                                child: RaisedButton(
                                    onPressed: () {
                                      checkGameStatus(mycontext);
                                    },
                                    child: Text("Finish Group Phase")),
                              );
                            })
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
