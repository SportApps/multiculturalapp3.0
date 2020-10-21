import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:multiculturalapp/Screens/home.dart';
import 'package:provider/provider.dart';
import 'package:multiculturalapp/MyWidgets/TournOnWidgets/GameCard.dart';
import 'package:multiculturalapp/MyWidgets/myAppBars/flagAppBar.dart';
import 'package:multiculturalapp/MyWidgets/progress.dart';
import 'package:multiculturalapp/Screens/Final/tournamentFinished.dart';
import 'package:multiculturalapp/model/countryInfos.dart';
import 'package:multiculturalapp/model/tournaments.dart';
import 'package:multiculturalapp/model/users.dart';

import '../NextGameDetails.dart';
import 'finishedPhaseOverview.dart';

class NextGoldMatchUser extends StatefulWidget {
  static const link = "/NextGoldMatchUser";

  @override
  _NextGoldMatchUserState createState() => _NextGoldMatchUserState();
}

class _NextGoldMatchUserState extends State<NextGoldMatchUser> {
  var tournamentinstance =
      FirebaseFirestore.instance.collection("ourtournaments");
  bool _isloading;
  bool _goldOver;
  String myCountry;
  String matchProgress;
  String tournamentID;
  String nextMatch;
  String myFlag;
  double appBarHeight = 200;
  String team1;
  String team2;
  String result1;
  String result2;
  bool _finished;
  String winner;
  String futureMatchProgress;

  getNextGoldMatch() {
    var snap = tournamentinstance
        .doc(tournamentID)
        .collection("countries")
        .doc(myCountry)
        .collection("Finals")
        .where("GameName", isEqualTo: matchProgress)
        .snapshots();

    return snap;
  }

  // Here we check if Admin gives ok to finish and reflect tath in "finished" variable.
  void checkGameStatus(ctx) async {
    await tournamentinstance
        .doc(tournamentID)
        .collection("Status")
        .doc("Finals")
        .get()
        .then(
      (doc) {
        var matchVortschritt = doc.data()["matchProgress"];
        print("futureMatchProgress at $futureMatchProgress");
        print("matchprogress at $matchVortschritt");

        if (futureMatchProgress == matchVortschritt) {
          _finished = true;
          if (matchProgress == "Grand Finale") {
            Navigator.of(context).popAndPushNamed(TournamentFinished.link);
            return;
          }

          //This function brings us to next screen and changes player Status.
          finishPhaseandGo();
        } else {
          print(matchProgress);

          _finished = false;

          Scaffold.of(ctx).openDrawer();
          Scaffold.of(ctx).showSnackBar(SnackBar(
              content: Text(
                "There are still some teams playing. Please wait for Admin Confirmation.",
                textAlign: TextAlign.center,
              ),
              duration: Duration(seconds: 6)));
        }
      },
    );
  }

  finishPhaseandGo() async {
    var disqualiFire = await tournamentinstance
        .doc(tournamentID)
        .collection("countries")
        .doc(myCountry)
        .get();

    var _Isdisqualified = disqualiFire.data()["Disqualified"];

    if (_Isdisqualified) {
      Navigator.of(context).popAndPushNamed(TournamentFinished.link);
    }

    var gameData = await tournamentinstance
        .doc(tournamentID)
        .collection("countries")
        .doc(myCountry)
        .collection("Finals")
        .doc(nextMatch)
        .get();

    winner = gameData.data()["Winner"];

    if (winner == myCountry) {
      // We made it to next Phase
      Navigator.of(context).popAndPushNamed(FinishedPhaseOverview.link,
          arguments: {"isGold": true, "progress": futureMatchProgress});
    } else {
      // We are out.
      Navigator.of(context).popAndPushNamed(TournamentFinished.link,
          arguments: {"isGold": true, "matchProgress": matchProgress});
    }
  }

  initState() {
    // TODO: implement initState
    super.initState();

    _isloading = true;
    String userId;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var routeArgs =
          ModalRoute.of(context).settings.arguments as Map<String, String>;
      matchProgress = routeArgs["matchProgress"];

      if (matchProgress == "32 Teams left") {
        futureMatchProgress = "Eighth - Final";
      } else if (matchProgress == "Eighth - Final") {
        futureMatchProgress = "Quarter - Final";
      } else if (matchProgress == "Quarter - Final") {
        futureMatchProgress = "Semi - Final";
      } else if (matchProgress == "Semi - Final") {
        futureMatchProgress = "Grand Finale";
      } else if (matchProgress == "Grand Finale") {
        futureMatchProgress = "Gold - Over";
      }

      final userData = Provider.of<Users>(context, listen: false);

      final userinfo = userData.item;
      userId = userinfo[0].id;

      final tournamentInfo = Provider.of<Tournaments>(context, listen: false);

      final tournamentiform = tournamentInfo.item;
      tournamentID = tournamentiform[0].tournamentid;

      final countryData = Provider.of<Countryinfos>(context, listen: false);

      final countryInfo = countryData.item;
      myCountry = countryInfo[0].myCountry;
      myFlag = countryInfo[0].myFlag;
      // Here we load the next Match from Firebase

      setState(() {
        _isloading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isloading
          ? circularProgress()
          : Column(
              children: <Widget>[
                flagAppBar(
                  screenHeightPercentage: 0.3,
                  myFlag: myFlag,
                ),
                Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: Text(
                    "Gold Phase",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.black.withOpacity(0.8)),
                    textAlign: TextAlign.center,
                  ),
                ),
                Flexible(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        color: HexColor("#ffe664"),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.15),
                            Container(
                              padding: EdgeInsets.only(bottom: 25),
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                "Next Match",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black.withOpacity(0.8)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              height: 100,
                              child: StreamBuilder(
                                  stream: getNextGoldMatch(),
                                  builder: (context, tsnapshot) {
                                    if (tsnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return circularProgress();
                                    }
                                    //Data Snapshot
                                    var _loadeddata = tsnapshot.data.docs;
                                    var _loadeddataIndex;
                                    String team1;
                                    String team2;
                                    String ergebnis1;
                                    String ergebnis2;

                                    String nextMatch;
                                    print(_loadeddata.length);
                                    return ListView.builder(
                                        itemCount: _loadeddata.length,
                                        itemBuilder: (context, i) {
                                          _loadeddataIndex = _loadeddata[i];

                                          team1 =
                                              _loadeddataIndex.data()["Team1"];
                                          team2 =
                                              _loadeddataIndex.data()["Team2"];

                                          ergebnis1 = _loadeddataIndex
                                              .data()["Result $team1"];
                                          if (ergebnis1 == "") {
                                            ergebnis1 = "0";
                                          }
                                          ergebnis2 = _loadeddataIndex
                                              .data()["Result $team2"];
                                          if (ergebnis2 == "") {
                                            ergebnis2 = "0";
                                          }
                                          nextMatch = "$team1 vs. $team2";


                                          return InkWell(
                                              onTap: () {
                                                Navigator.of(context).pushNamed(
                                                    NextGameDetails.link,
                                                    arguments: {
                                                      "matchId": nextMatch,
                                                      "adminCountry": myCountry,
                                                      "silverFinals": false,
                                                      "goldGameNAme":
                                                          matchProgress
                                                    });
                                              },
                                              child: GameCard(
                                                team1: team1,
                                                team2: team2,
                                                Result1: ergebnis1,
                                                Result2: ergebnis2,
                                              ));
                                        });
                                  }),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.15,
                            ),
                            Builder(builder: (mycontext) {
                              return RaisedButton(
                                  onPressed: () {
                                    checkGameStatus(mycontext);
                                  },
                                  child: Text("Continue"));
                            })
                          ],
                        ),
                      ),
                      ClipOval(
                        child: Container(
                          color: Colors.white,
                          height: 80,
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        height: 30,
                      ),
                      Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(bottom: 10),
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              "$matchProgress",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(bottom: 10),
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              "Team $myCountry",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
