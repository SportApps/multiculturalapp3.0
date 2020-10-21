import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:multiculturalapp/MyWidgets/clippingClass.dart';
import 'package:provider/provider.dart';

import 'package:multiculturalapp/MyWidgets/myAppBars/flagAppBar.dart';
import 'package:multiculturalapp/MyWidgets/progress.dart';
import 'package:multiculturalapp/Screens/Final/nextGoldMatchUser.dart';
import 'package:multiculturalapp/Screens/Final/tournamentFinished.dart';

import 'package:multiculturalapp/Screens/home.dart';
import 'silverGroupUser.dart';
import 'package:multiculturalapp/model/countryInfos.dart';
import 'package:multiculturalapp/model/tournaments.dart';
import 'package:multiculturalapp/model/users.dart';

class FinishedPhaseOverview extends StatefulWidget {
  static const link = "/FinishedPhaseOverview";

  @override
  _FinishedPhaseOverviewState createState() => _FinishedPhaseOverviewState();
}

class _FinishedPhaseOverviewState extends State<FinishedPhaseOverview> {
  var tournamentinstance =
      FirebaseFirestore.instance.collection("ourtournaments");
  bool _isloading;
  String ourFinalsGroup;
  String winnerFotoLink =
      "https://images.unsplash.com/photo-1502082553048-f009c37129b9?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=750&q=80";
  int myWins;
  String userId;
  bool _isGold = false;
  bool _isFinished;
  bool _silverFinished;
  String myCountry;
  String tournamentId;
  String matchProgress;
  String myFlag;
  String myGroupName;

  checkisGold() async {
    if (_isGold) {
      winnerFotoLink =
          "https://cdn.pixabay.com/photo/2017/03/21/21/05/medal-2163345_960_720.png";

      myGroupName = "Gold";
    } else {
      winnerFotoLink =
          "https://cdn.pixabay.com/photo/2017/03/21/21/05/medal-2163349_960_720.png";
      myGroupName = "Silver";
    }

    var firestatus = await tournamentinstance
        .doc(tournamentId)
        .collection("Status")
        .doc("Finals")
        .get();

    matchProgress = firestatus.data()["matchProgress"];

    if (matchProgress == "Gold - Over") {
      _isFinished = true;
    }

    setState(() {
      _isloading = false;
    });
  }

  getFinalMatches() async {
    var futureSnap =
        await tournamentinstance.doc(tournamentId).collection("Summary").get();

    return futureSnap;
  }

  checkSilverFinished() async {
    var silverFire = await tournamentinstance
        .doc(tournamentId)
        .collection("Status")
        .doc("Finals")
        .get();

    var silverbool = silverFire.data()["silverFinished"];

    if (silverbool == true) {
      _silverFinished = true;
    } else {
      _silverFinished = false;
    }
  }

  @override
  initState() {
    // TODO: implement initState
    super.initState();

    _isloading = true;
    _isFinished = false;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var routeArgs =
          ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
      _isGold = routeArgs["isGold"];
      print("Here it says _isGold is $_isGold");

      final userData = Provider.of<Users>(context, listen: false);

      final userinfo = userData.item;
      userId = userinfo[0].id;

      final countryData = Provider.of<Countryinfos>(context, listen: false);

      final countrySpecs = countryData.item;
      myCountry = countrySpecs[0].myCountry;
      myFlag = countrySpecs[0].myFlag;

      final tournamentInfo = Provider.of<Tournaments>(context, listen: false);

      final tournamentiform = tournamentInfo.item;
      tournamentId = tournamentiform[0].tournamentid;

      checkisGold();
      checkSilverFinished();
    });

    // If we are not an Admin we set CountrySelected to true so the athlet can see his/her result (Streambuilder List)
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
                      flagAppBar(
                        myFlag: myFlag,
                        screenHeightPercentage: 0.3,
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        height: 100,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: <Widget>[
                            Text(
                              "Congratulations!!",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "You made it into the $myGroupName Group.",
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 180,
                        width: MediaQuery.of(context).size.width * 0.5,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: _isGold
                                    ? AssetImage(
                                        "assets/images/congratstrophy.png")
                                    : AssetImage(
                                        "assets/images/silvergroup.png"),
                                fit: BoxFit.contain)),
                      ),
                      // GOLD ONLY INFO: Which is the matchProgress and who is still In Game?
                      _isGold
                          ? Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  matchProgress,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: HexColor("#ea070a")),
                                ),
                                _isFinished
                                    ? Container(
                                        padding: EdgeInsets.all(20),
                                        child: Text(
                                          "The Tournament is over. Continue to see your final result",
                                          style: TextStyle(fontSize: 20),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    : Container(
                                        height: 100,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: FutureBuilder(
                                            future: getFinalMatches(),
                                            builder: (context, tsnapshot) {
                                              if (tsnapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return circularProgress();
                                              }
                                              //Data Snapshot
                                              var _loadeddata =
                                                  tsnapshot.data.documents;
                                              var proccessData = _loadeddata[0];

                                              var finalData = proccessData
                                                  .data()["GoldMatchList"];
                                              print(
                                                  "Das ist die LoadedData Lengrth");
                                              print(_loadeddata.length);
                                              return ListView.builder(
                                                  itemCount: finalData.length,
                                                  itemBuilder: (context, i) {
                                                    return Container(
                                                      height: 40,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: Text(
                                                        finalData[i],
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            }),
                                      ),
                              ],
                            )
                          : SizedBox(
                              height: 0,
                            ),

                      Stack(
                        children: [
                          Container(
                            color: HexColor("#ffe664"),
                            height: MediaQuery.of(context).size.height * 0.3,
                          ),
                          ClipPath(
                            clipper: ClippingClass(),
                            child: Container(
                              color: Colors.white,
                              height: MediaQuery.of(context).size.height * 0.1,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.325),
                                width: double.infinity,
                                child: RaisedButton(
                                    onPressed: () {
                                      if (matchProgress == "Gold - Over" &&
                                          _isGold == true) {
                                        Navigator.of(context).popAndPushNamed(
                                            TournamentFinished.link);
                                      }
                                      if (_silverFinished == true && _isGold == false) {
                                        Navigator.of(context).popAndPushNamed(
                                            TournamentFinished.link);
                                      } else if (_isGold) {
                                        Navigator.of(context).popAndPushNamed(
                                            NextGoldMatchUser.link,
                                            arguments: {
                                              "matchProgress": matchProgress
                                            });
                                      } else {
                                        Navigator.of(context).popAndPushNamed(
                                            SilverGroupUser.link);
                                      }
                                    },
                                    child: Text("Continue")),
                              )
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ));
  }
}
