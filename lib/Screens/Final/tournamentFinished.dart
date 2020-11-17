import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:multiculturalapp/MyWidgets/clippingClass.dart';
import 'package:multiculturalapp/MyWidgets/myAppBars/finishTournamentAppBar.dart';
import 'package:multiculturalapp/MyWidgets/myAppBars/flagAppBar.dart';
import 'package:multiculturalapp/MyWidgets/progress.dart';
import 'package:multiculturalapp/Screens/Final/SilverWinnerListviewbuilder.dart';
import 'package:multiculturalapp/model/countryInfos.dart';
import 'package:multiculturalapp/model/tournaments.dart';
import 'package:multiculturalapp/model/users.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../CreateTeamsScreen.dart';
import '../home.dart';

class TournamentFinished extends StatefulWidget {
  static const link = "/TournamentFinished";

  @override
  _TournamentFinishedState createState() => _TournamentFinishedState();
}

class _TournamentFinishedState extends State<TournamentFinished> {
  static const silverTrophylink = "assets/images/silverTrophy2.png";
  static const goldTrophylink = "assets/images/goldtrophy.png";

  ConfettiController _controllerCenterRight;

  bool _isLoading;
  bool _isGold;
  bool _isGoldWinner;
  bool _lvlChanged;
  bool hasRated;
  String userName;
  String userID;
  String olduserlvl;
  String newUserlvl;
  String matchId;
  String myCountry;
  String myFlag;
  String finalGroup;
  String uploadNumber;
  String photoUrl;
  String organizerName;
  String organizerPhoto;
  String organizerId;
  List countryList;
  int groupPHasePoints;
  int finalPhaseWon;
  int finalPhasePoints;
  int organizerRating;
  double organizerRatingasDouble;

  int oldWins;
  int afterTournamentPoints;

  int newPoints;
  int beforeTournamentPoints;

  double oldWinLooseRatio;
  double afterTournamentWinLooseRatio;

  // Indice:
  //1.) Check if Winner of Gold Group
  // 2.) Check if Goldgroup - if you are, multiplicate the finalPHaseWon by 3.
  //3.) Calculate Total Points made in Tournament.

  //1.) Check if Winner of Gold Group
  checkWinnerGold() async {
    var FireCountry = await tournamentInstance
        .doc(tournamentId)
        .collection("countries")
        .doc(myCountry)
        .get();
    print(tournamentId + myCountry + "$_isGoldWinner");
    _isGoldWinner = FireCountry.data()["Grand Finale Winner"];
    if (_isGoldWinner == null) {
      _isGoldWinner = false;
    }
    showScore();
  }

  // 2.) Check if Goldgroup - if you are, multiplicate the finalPHaseWon by 3.
  checkGold() async {
    var fireCountry = await tournamentInstance
        .doc(tournamentId)
        .collection("countries")
        .doc(myCountry)
        .get();
    finalGroup = fireCountry.data()["Finalgroup"];

    if (finalGroup == "Gold") {
      _isGold = true;
      checkWinnerGold();
    } else {
      _isGold = false;

      var fireList = await tournamentInstance
          .doc(tournamentId)
          .collection("Summary")
          .doc("Finals")
          .get();

      countryList = await fireList.data()["SilverScoreTable"];
      await showScore();
    }
  }

  //2.) checkIf User rated orga

  //2.0.1) sendOpinon Function

  sendOpinon() async {
    //1.) Get Organizer Id
    var fireTournament = await tournamentInstance.doc(tournamentId).get();

    organizerId = fireTournament.data()["organizerId"];

    // Upload Organzier Rating

    organizerRating = organizerRatingasDouble.round();


    await FirebaseFirestore.instance
        .collection("orgaRatings")
        .doc(organizerId)
        .collection("userRatings")
        .doc(userID + tournamentId)
        .set(
      {"rating": organizerRating},
    );

    await tournamentInstance
        .doc(tournamentId)
        .collection("participants")
        .doc(userID)
        .update({"hasRated": true});
  }

  //2.1) Rate AlertDialog

  void rateDialog(String organizerName, String OrganizerPhotoLink) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("Rate the organizer!"),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            content: Container(
              height: 250,
              child: Column(
                children: [
                  Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text("Are you happy with $organizerName ?")),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width * 0.2,
                    ),
                    child: FadeInImage.assetNetwork(
                        fit: BoxFit.cover,
                        width: 90,
                        height: 90,
                        fadeInDuration: Duration(seconds: 1),
                        placeholder: 'assets/images/volleychild.png',
                        imageErrorBuilder: (context, url, error) =>
                            new Image.asset("assets/images/volleychild.png"),
                        image: organizerPhoto),
                  ),
                  SizedBox(height: 20),
                  SmoothStarRating(
                      allowHalfRating: false,
                      onRated: (v) {
                        setState(() {
                          organizerRatingasDouble = v;

                        });
                      },
                      starCount: 5,
                      rating: organizerRatingasDouble,
                      size: 40.0,
                      isReadOnly: false,
                      color: HexColor("#0909EB"),
                      borderColor: HexColor("#0909EB"),
                      spacing: 0.0)
                ],
              ),
            ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              FlatButton(
                child: new Text("I have no opinion"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: new Text("Send Rating"),
                onPressed: () {
                  sendOpinon();

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }

  rateOrga() async {
    var fireParticipant = await tournamentInstance
        .doc(tournamentId)
        .collection("participants")
        .doc(userID)
        .get();

    hasRated = fireParticipant.data()["hasRated"];

    if (!hasRated) {
      rateDialog(organizerName, organizerPhoto);
    }
  }

  //3.) Upload Score on Firebase and quit.
  showScore() async {
    //3.1) How many points during group phase?
    var fireResults = await tournamentInstance
        .doc(tournamentId)
        .collection("countries")
        .doc(myCountry)
        .collection("Results")
        .where("Winner", isEqualTo: myCountry)
        .get();

    groupPHasePoints = fireResults.docs.length;

    // 3.3) Check how many Games we won in Final Phase.
    var fireFinal = await tournamentInstance
        .doc(tournamentId)
        .collection("countries")
        .doc(myCountry)
        .collection("Finals")
        .where("Winner", isEqualTo: myCountry)
        .get();

    finalPhaseWon = fireFinal.docs.length;

    // 3.5) Check if Goldgroup - if you are, multiplicate the finalPHaseWon by 3.

    if (_isGold) {
      finalPhasePoints = finalPhaseWon * 3;
      print(finalGroup);
    } else {
      _isGold = false;
      finalPhasePoints = finalPhaseWon;
    }

    newPoints = groupPHasePoints + finalPhasePoints;

    var FireUser =
        await FirebaseFirestore.instance.collection("users").doc(userID).get();

    newUserlvl = FireUser.data()["achievedlvl"];
    afterTournamentPoints = FireUser.data()["points"];
    if (olduserlvl != newUserlvl) {
      _lvlChanged = true;
      upgradeDialog();
    }

    setState(() {
      _isLoading = false;
    });
  }

  //4.) Build Functions

  //4.1) BuildTournamentWinnerScreen

  Container buildWinnerFunction() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              FinishTournamentAppBar(
                myFlag: myFlag,
                mycontext: context,
                imageUrl: photoUrl,
                userName: userName,
                userlvl: newUserlvl,
              ),
              Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.05,
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      "Congrats!",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    "You are the new Champion!",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  //4.2) Build Score Card

  Container buildScoreCard() {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            color: Colors.black.withOpacity(0.05),
            height: MediaQuery.of(context).size.height * 0.20,
            width: MediaQuery.of(context).size.width * 0.35,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Icon(
                  MdiIcons.sealVariant,
                  size: 35,
                ),
                Text(
                  "New Points",
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  newPoints.toString(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  height: 3,
                  width: MediaQuery.of(context).size.width * 0.275,
                  color: HexColor("#ffe664"),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.05),
            padding: EdgeInsets.symmetric(vertical: 10),
            height: MediaQuery.of(context).size.height * 0.20,
            width: MediaQuery.of(context).size.width * 0.35,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Icon(
                  MdiIcons.trophy,
                  size: 35,
                ),
                Text(
                  "Total Points",
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  afterTournamentPoints.toString(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  height: 3,
                  width: MediaQuery.of(context).size.width * 0.275,
                  color: HexColor("#4ecdc4"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //4.3) Build Gold End Class

  Container buildLooserHeader(String looserText, String imageLink) {
    double headerHeight = MediaQuery.of(context).size.height * 0.8;

    return Container(
      height: headerHeight,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          flagAppBar(
            myFlag: myFlag,
            screenHeightPercentage: 0.25,
          ),
          Container(
            height: headerHeight * 0.1,
            child: Text(
              "Great effort $myCountry !",
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.8)),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            height: headerHeight * 0.1,
            child: Text(
              "Thank you for sharing this great moment with us!",
              style:
                  TextStyle(fontSize: 18, color: Colors.black.withOpacity(0.8)),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            height: headerHeight * 0.35,
            child: Stack(
              children: <Widget>[
                Container(
                  height: headerHeight * 0.35,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.fitHeight, image: AssetImage(imageLink))),
                ),
                Container(
                  width: double.infinity,
                  child: Text(
                    looserText,
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(0.8)),
                    textAlign: TextAlign.center,
                  ),
                ),
                !_isGold
                    ? SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.07,
                            ),
                            SilverWinnerListviewbuilder(
                              countryList: countryList,
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        height: 0,
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // user defined function
  void upgradeDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("You leveled up!"),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          content: Text("You are now a $newUserlvl!"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _isGoldWinner = false;
    _isLoading = true;
    _lvlChanged = false;
    organizerRating = 0;
    organizerRatingasDouble=0;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //0)Check is admin

      _controllerCenterRight =
          ConfettiController(duration: const Duration(seconds: 10));

      Timer(Duration(seconds: 1), () {
        setState(() {
          _controllerCenterRight.play();
        });

        // 5s over, navigate to a new page
      });

      final userData = Provider.of<Users>(context, listen: false);

      userName = userData.item[0].username;
      olduserlvl = userData.item[0].achievedLvl;
      userID = userData.item[0].id;

      oldWins = userData.item[0].historyGamesWon;
      oldWinLooseRatio = userData.item[0].winLooseRatio;
      photoUrl = userData.item[0].photoUrl;

      // silverfinals = routearguments["silverFinals"];

      //goldMatchName = routearguments["goldGameNAme"];

      //2.) Provider Data
      // 2.1) In which Team do we play?
      final countrydata = Provider.of<Countryinfos>(context, listen: false);

      myCountry = countrydata.item[0].myCountry;
      myFlag = countrydata.item[0].myFlag;

      // 2.2) In which Tournament do we play?
      final tournamentData = Provider.of<Tournaments>(context, listen: false);
      tournamentId = tournamentData.item[0].tournamentid;
      organizerName = tournamentData.item[0].organizerName;
      organizerPhoto = tournamentData.item[0].organizerPhoto;
      Future.delayed(Duration(seconds: 6), () {
        rateOrga();
      });

      checkGold();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _controllerCenterRight.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Tournament finished screen");
    return Scaffold(
        body: _isLoading
            ? circularProgress()
            : SingleChildScrollView(
                child: Stack(
                  children: [
                    Align(
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          children: <Widget>[
                            // Case 1 Is Gold Winner
                            _isGoldWinner
                                ? buildWinnerFunction()
                                : SizedBox(
                                    height: 0,
                                  ),

                            //Case 2 Gold Group but didnt win
                            if (_isGold && !_isGoldWinner)
                              buildLooserHeader("Gold Group", goldTrophylink)
                            else
                              SizedBox(),

                            // Case 3) Participated in Silver Group
                            !_isGold
                                ? buildLooserHeader(
                                    "Silver Group", silverTrophylink)
                                : SizedBox(
                                    height: 0,
                                  ),

                            buildScoreCard(),
                            Container(
                              color: HexColor("#ffe664"),
                              width: double.infinity,
                              child: Stack(
                                children: <Widget>[
                                  ClipPath(
                                    clipper: ClippingClass(),
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.075,
                                      width: double.infinity,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.08,
                                      ),
                                      Container(
                                        height: 60,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    "assets/images/smalllogo.png"))),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 20),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                width: 3, color: Colors.black)),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.of(context)
                                                .popAndPushNamed(Home.link);
                                          },
                                          child: Text(
                                            "Finish Tournament",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    _isGold
                        ? Align(
                            alignment: Alignment.bottomCenter,
                            child: ConfettiWidget(
                              maxBlastForce: 60,
                              minBlastForce: 10,
                              confettiController: _controllerCenterRight,
                              emissionFrequency: 0.1,
                              blastDirectionality:
                                  BlastDirectionality.explosive,
                              // don't specify a direction, blast randomly
                              shouldLoop: false,
                              // start again as soon as the animation is finished
                              colors: const [
                                Colors.green,
                                Colors.blue,
                                Colors.pink,
                                Colors.orange,
                                Colors.purple
                              ], // manually specify the colors to be used
                            ),
                          )
                        : Align(
                            alignment: Alignment.bottomCenter,
                            child: ConfettiWidget(
                              maxBlastForce: 20,
                              minBlastForce: 10,
                              confettiController: _controllerCenterRight,
                              emissionFrequency: 0.05,
                              blastDirectionality:
                                  BlastDirectionality.explosive,
                              // don't specify a direction, blast randomly
                              shouldLoop: false,
                              // start again as soon as the animation is finished
                              colors: const [
                                Colors.yellow,
                                Colors.yellowAccent,
                                Colors.grey
                              ], // manually specify the colors to be used
                            ),
                          )
                  ],
                ),
              ));
  }
}
