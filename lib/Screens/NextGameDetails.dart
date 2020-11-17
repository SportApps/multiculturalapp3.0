import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:multiculturalapp/MyWidgets/clippingClass.dart';
import 'package:multiculturalapp/MyWidgets/myAppBars/flagAppBar.dart';
import 'package:multiculturalapp/MyWidgets/myAppBars/standardAppBar.dart';
import 'package:multiculturalapp/MyWidgets/progress.dart';
import 'package:multiculturalapp/MyWidgets/userInfoStartscreen.dart';
import 'package:multiculturalapp/Screens/Final/FinalsAdmin.dart';
import 'package:multiculturalapp/Screens/Final/nextGoldMatchUser.dart';
import 'package:multiculturalapp/Screens/Final/silverGroupUser.dart';
import 'package:multiculturalapp/Screens/TournOnScreen.dart';
import 'package:multiculturalapp/model/countryInfos.dart';
import 'package:multiculturalapp/model/tournaments.dart';
import 'package:multiculturalapp/model/users.dart';
import 'package:provider/provider.dart';

class NextGameDetails extends StatefulWidget {
  static const link = "/NextGameDetails";

  @override
  _NextGameDetailsState createState() => _NextGameDetailsState();
}

class _NextGameDetailsState extends State<NextGameDetails> {
  var tournamentInstance =
      FirebaseFirestore.instance.collection("ourtournaments");

  String userName;

  String myUserId;

  String myCountry;

  String myFlag;

  String tournamentId;

  String matchId;

  String FireCountry1;

  String FireCountry2;

  String opponentTeam;

  String oppnentFlag;

  String opponentPlayer1Id;

  String opponentPlayer1Foto;

  String opponentPlayer1Name;

  String opponentPlayer2Foto;

  String opponentPlayer2Name;

  bool _isloading = true;

  String Result1;

  int result1NR;

  String Result2;

  int result2NR;

  int oldUserLikes;

  String lastChangeInfo;

  String previousResult1;

  String previousResult2;

  String winnerTeam;

  String looserTeam;

  String opponentPlayer1Lvl;

  String opponentPlayer2Lvl;

  String opponentPlayer2Id;

  bool _isAdmin;

  String userlvl;

  bool silverfinals;

  bool _isliked = false;

  bool _likedSomeOne;

  bool _isopponent1;

  bool _opponent1Liked;

  bool _opponent2Liked;

  String goldMatchName;

  String userPoints;
  String userGamesWon;
  String userGamesLost;
  String userWinLooseRatio;

  var firebaseDoc3;

  TextEditingController Controller1 = TextEditingController();
  TextEditingController Controller2 = TextEditingController();

  void getOpponentTeam(String tournamentId, String opponentTeam) async {
    var firedocs = await tournamentInstance
        .doc(tournamentId)
        .collection("countries")
        .doc(opponentTeam)
        .get();

    var resultContent;
    resultContent = firedocs.data();
    print(resultContent);
    opponentPlayer1Id = resultContent["player1ID"];
    opponentPlayer1Name = resultContent["player1Name"];
    opponentPlayer1Foto = resultContent["player1Photo"];
    opponentPlayer1Lvl = resultContent["player1lvl"];

    opponentPlayer2Id = resultContent["player2ID"];
    opponentPlayer2Name = resultContent["player2Name"];
    opponentPlayer2Foto = resultContent["player2Photo"];
    opponentPlayer2Lvl = resultContent["player2lvl"];

    oppnentFlag = resultContent["CountryURL"];

    var firedocs2;
    if (silverfinals) {
      firedocs2 = await tournamentInstance
          .doc(tournamentId)
          .collection("countries")
          .doc(myCountry)
          .collection("Finals")
          .doc(matchId)
          .get();
    } else if (!silverfinals) {
      if (goldMatchName != "") {
        print("Were producing sth here!!!");
        firebaseDoc3 = await tournamentInstance
            .doc(tournamentId)
            .collection("countries")
            .doc(myCountry)
            .collection("Finals")
            .where("GameName", isEqualTo: goldMatchName)
            .get();

        var firebaseDocdocIndexdata = firebaseDoc3.documents[0];

        lastChangeInfo = firebaseDocdocIndexdata.data()["ChangeRegister"];

        previousResult1 = firebaseDocdocIndexdata.data()["Result $myCountry"];

        previousResult2 =
            firebaseDocdocIndexdata.data()["Result $opponentTeam"];
      } else {
        firedocs2 = await tournamentInstance
            .doc(tournamentId)
            .collection("countries")
            .doc(myCountry)
            .collection("Results")
            .doc(matchId)
            .get();
      }
    } else {
      print("something went wrong in NextGameDetails lin e 110");
    }

    var resultContent2;
    print("This is the goldMatchName");
    print(goldMatchName);
    //Case we have to do the Gold-Group progress Querry
    if (goldMatchName != "") {
    } else {
      // Case for Group phase or Silver Group phase
      resultContent2 = firedocs2.data();

      lastChangeInfo = resultContent2["ChangeRegister"];

      previousResult1 = resultContent2["Result $myCountry"];
      Controller1.text = previousResult1;
      previousResult2 = resultContent2["Result $opponentTeam"];
      Controller2.text = previousResult2;
    }

    setState(() {
      _isloading = false;
    });
  }

  getUserInfo(String clickedUser) async {
    var fireUser = await FirebaseFirestore.instance
        .collection("users")
        .doc(clickedUser)
        .get();
    userPoints = fireUser.data()["points"].toString();
    userGamesWon = fireUser.data()["historyGamesWon"].toString();
    userGamesLost = fireUser.data()["historyGamesLost"].toString();
    userWinLooseRatio = fireUser.data()["winLooseRatio"].toString();
  }

  createInfoPlayerAlert(
    BuildContext context,
    bool isOpponent1,
    String athletId,
    String athletName,
    String athletlvl,
    String userPhoto,
  ) {
    double advanceProcent;
    if (athletlvl == "Baby Beginner") {
      advanceProcent = 0.125;
    } else if (athletlvl == "Little Child") {
      advanceProcent = 0.25;
    } else if (athletlvl == "Amateur") {
      advanceProcent = 0.5;
    } else if (athletlvl == "Grown-Up") {
      advanceProcent = 0.6125;
    } else if (athletlvl == "Experienced") {
      advanceProcent = 0.75;
    } else {
      advanceProcent = 1;
    }

    // flutter defined function
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          scrollable: true,
          title: Container(
            width: double.infinity,
            child: Column(
              children: [
                Text(
                  "Meet",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black.withOpacity(0.8),
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 3,
                ),
                Text(
                  athletName,
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.black.withOpacity(0.8),
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          content: Column(
            children: [
              Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                          painter: GradientArcPainter(
                            startColor: HexColor("#ffde03"),
                            endColor: Colors.red,
                            progress: advanceProcent,
                            width: 10,
                          ),
                          size: Size(
                            MediaQuery.of(context).size.width * 0.325,
                            MediaQuery.of(context).size.width * 0.325,
                          )),
                      CircleAvatar(
                        backgroundImage: NetworkImage(userPhoto),
                        radius: MediaQuery.of(context).size.width * 0.15,
                      ),
                    ],
                  ),
                  Container(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        athletlvl,
                        style: TextStyle(color: Colors.black.withOpacity(0.6)),
                      )),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text("Points:")),
                          Container(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text("Games Won:")),
                          Container(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text("Games Lost:")),
                          Container(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text("Win - Loose Ratio:")),
                        ],
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.16,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text(userPoints)),
                          Container(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text(userGamesWon)),
                          Container(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text(userGamesLost)),
                          Container(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text(userWinLooseRatio)),
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      width: double.infinity,
                      child: Text(
                        "Do you like how $athletName plays?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  SizedBox(
                    height: 25,
                  ),
                  _likedSomeOne
                      ? Text(
                          "You can only like 1 athlet per tournament.",
                          textAlign: TextAlign.center,
                        )
                      : GestureDetector(
                          onTap: () async {
                            await FirebaseFirestore.instance
                                .collection("ourtournaments")
                                .doc(tournamentId)
                                .collection("participants")
                                .doc(myUserId)
                                .update({"likedSomeOne": true});

                            var FireUser = await FirebaseFirestore.instance
                                .collection("users")
                                .doc(athletId)
                                .get();

                            oldUserLikes = FireUser.data()["likes"];
                            oldUserLikes++;

                            // Update Value in User Collection.
                            await FirebaseFirestore.instance
                                .collection("users")
                                .doc(athletId)
                                .update({"likes": oldUserLikes});

                            setState(() {
                              if (isOpponent1) {
                                _opponent1Liked = true;
                                Navigator.of(context).pop();
                              } else {
                                _opponent2Liked = true;
                                Navigator.of(context).pop();
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  spreadRadius: 0,
                                  blurRadius: 4,
                                  offset: Offset(
                                      0, 2), // changes position of shadow
                                ),
                              ],
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(23),
                                  topRight: Radius.circular(0),
                                  bottomLeft: Radius.circular(0),
                                  bottomRight: Radius.circular(23)),
                              color: HexColor("#ffde03"),
                            ),
                            width: MediaQuery.of(context).size.width * 0.2,
                            height: MediaQuery.of(context).size.width * 0.2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.width * 0.03,
                                ),
                                Icon(
                                  MdiIcons.heart,
                                  color: Colors.black,
                                  size:
                                      MediaQuery.of(context).size.width * 0.09,
                                ),
                                Text(
                                  "Like!",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black.withOpacity(0.8)),
                                )
                              ],
                            ),
                          ),
                        )
                ],
              )
            ],
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Column buildOponentPlayer() {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.white,
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
          height: MediaQuery.of(context).size.height * 0.06,
          width: double.infinity,
          child: Text(
            "Team $opponentTeam",
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.8)),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () async {
                      _isopponent1 = true;
                      await getUserInfo(opponentPlayer2Id);

                      var FireParticipant = await tournamentInstance
                          .doc(tournamentId)
                          .collection("participants")
                          .doc(myUserId)
                          .get();

                      _likedSomeOne = FireParticipant.data()["likedSomeOne"];

                      createInfoPlayerAlert(
                          context,
                          _isopponent1,
                          opponentPlayer1Id,
                          opponentPlayer1Name,
                          opponentPlayer1Lvl,
                          opponentPlayer1Foto);
                    },
                    child: Stack(
                      overflow: Overflow.visible,
                      children: [
                        CircleAvatar(
                          radius: MediaQuery.of(context).size.width * 0.125,
                          backgroundImage: NetworkImage(opponentPlayer1Foto),
                        ),
                        Positioned(
                          bottom: -MediaQuery.of(context).size.width * 0.0275,
                          right: MediaQuery.of(context).size.width * 0.0625,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: MediaQuery.of(context).size.width * 0.05,
                            child: Icon(MdiIcons.heart,
                                size: MediaQuery.of(context).size.width * 0.075,
                                color: _opponent1Liked
                                    ? Colors.red
                                    : Colors.black),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      opponentPlayer1Name,
                      style: TextStyle(
                          fontSize: 18, color: Colors.black.withOpacity(0.6)),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      opponentPlayer1Lvl,
                      style: TextStyle(
                          fontSize: 14, color: Colors.black.withOpacity(0.6)),
                    ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () async {
                      _isopponent1 = false;
                      await getUserInfo(opponentPlayer2Id);

                      var FireParticipant = await tournamentInstance
                          .doc(tournamentId)
                          .collection("participants")
                          .doc(myUserId)
                          .get();

                      _likedSomeOne = FireParticipant.data()["likedSomeOne"];

                      createInfoPlayerAlert(
                          context,
                          _isopponent1,
                          opponentPlayer2Id,
                          opponentPlayer2Name,
                          opponentPlayer2Lvl,
                          opponentPlayer2Foto);
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: MediaQuery.of(context).size.width * 0.125,
                          backgroundImage: NetworkImage(opponentPlayer2Foto),
                        ),
                        Positioned(
                          bottom: -MediaQuery.of(context).size.width * 0.0275,
                          right: MediaQuery.of(context).size.width * 0.0625,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: MediaQuery.of(context).size.width * 0.05,
                            child: Icon(MdiIcons.heart,
                                size: MediaQuery.of(context).size.width * 0.075,
                                color: _opponent2Liked
                                    ? Colors.red
                                    : Colors.black),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      opponentPlayer2Name,
                      style: TextStyle(
                          fontSize: 18, color: Colors.black.withOpacity(0.6)),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      opponentPlayer2Lvl,
                      style: TextStyle(
                          fontSize: 14, color: Colors.black.withOpacity(0.6)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  void saveResult() {
    // 1.) Determine who won the match

    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    Result1 = Controller1.text;

    Result2 = Controller2.text;

    result1NR = int.parse(Result1);

    result2NR = int.parse(Result2);

    if (result1NR > result2NR) {
      winnerTeam = myCountry;
      looserTeam = opponentTeam;
    } else {
      winnerTeam = opponentTeam;
      looserTeam = myCountry;
    }

    if (silverfinals || goldMatchName != "") {
      tournamentInstance
          .doc(tournamentId)
          .collection(("countries"))
          .doc(myCountry)
          .collection("Finals")
          .doc(matchId)
          .set({
        "Result $myCountry": Result1,
        "Result $opponentTeam": Result2,
        "ChangeRegister": "$userName of $myCountry",
        "Winner": winnerTeam,
        "Looser": looserTeam,
      }, SetOptions(merge: true));

      // We save the result in the opponents Result tree.
      tournamentInstance
          .doc(tournamentId)
          .collection(("countries"))
          .doc(opponentTeam)
          .collection("Finals")
          .doc(matchId)
          .set({
        "Result $myCountry": Result1,
        "Result $opponentTeam": Result2,
        "ChangeRegister": "$userName of $myCountry",
        "Winner": winnerTeam,
        "Looser": looserTeam
      }, SetOptions(merge: true));

      if (!silverfinals) {
        tournamentInstance
            .doc(tournamentId)
            .collection("countries")
            .doc(winnerTeam)
            .set({
          "$goldMatchName Winner": true,
          "$goldMatchName Score": "$myCountry $Result1 - $opponentTeam $Result2"
        }, SetOptions(merge: true));
        tournamentInstance
            .doc(tournamentId)
            .collection("countries")
            .doc(looserTeam)
            .set({
          "$goldMatchName Winner": false,
          "$goldMatchName Score": "$myCountry $Result1 - $opponentTeam $Result2"
        }, SetOptions(merge: true));

        if (!_isAdmin) {
          Navigator.of(context).popAndPushNamed(NextGoldMatchUser.link,
              arguments: {"matchProgress": goldMatchName});
          return;
        } else {
          Navigator.of(context).popAndPushNamed(FinalsAdmin.link,
              arguments: {"matchProgress": goldMatchName});
          return;
        }
      }
      if (!_isAdmin) {
        Navigator.of(context).popAndPushNamed(SilverGroupUser.link);
      } else {
        Navigator.of(context).popAndPushNamed(FinalsAdmin.link,
            arguments: {"matchProgress": goldMatchName});
      }
    } else {
      // 1.) We save the result in OUr Result tree.
      tournamentInstance
          .doc(tournamentId)
          .collection(("countries"))
          .doc(myCountry)
          .collection("Results")
          .doc(matchId)
          .set({
        "Result $myCountry": Result1,
        "Result $opponentTeam": Result2,
        "ChangeRegister": "$userName of $myCountry",
        "Winner": winnerTeam,
        "Looser": looserTeam,
      }, SetOptions(merge: true));

      // We save the result in the opponents Result tree.
      tournamentInstance
          .doc(tournamentId)
          .collection(("countries"))
          .doc(opponentTeam)
          .collection("Results")
          .doc(matchId)
          .set({
        "Result $myCountry": Result1,
        "Result $opponentTeam": Result2,
        "ChangeRegister": "$userName of $myCountry",
        "Winner": winnerTeam,
        "Looser": looserTeam
      }, SetOptions(merge: true));

      Navigator.of(context).popAndPushNamed(TournOnScreen.link);
    }
  }

  Container buildIntroFields() {
    return Container(
      color: HexColor("#ffe664"),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Text("Final Score",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.black.withOpacity(0.8),
                  fontWeight: FontWeight.bold)),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.125,
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.1),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0,
                      blurRadius: 4,
                      offset: Offset(0, 2))
                ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        myCountry,
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.8),
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                        height: MediaQuery.of(context).size.height * 0.06,
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: Center(
                          child: TextField(
                            controller: Controller1,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                          ),
                        )),
                  ],
                ),
                Text("vs",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.red,
                        fontWeight: FontWeight.bold)),
                Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        opponentTeam,
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                        height: MediaQuery.of(context).size.height * 0.06,
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: TextField(
                          controller: Controller2,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                        ))
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Last change of Results by user $lastChangeInfo",
            style:
                TextStyle(color: Colors.black.withOpacity(0.8), fontSize: 12),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          RaisedButton(
            onPressed: () {
              saveResult();
            },
            child: Text("Confirm Score"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _isloading = true;
    _isAdmin = false;
    _opponent1Liked = false;
    _opponent2Liked = false;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //0)Check is admin

      final userData = Provider.of<Users>(context, listen: false);

      myUserId = userData.item[0].id;
      userName = userData.item[0].username;
      _isAdmin = userData.item[0].isAdmin;

      // 1.)RouteArguments form TournOnScreen
      final routearguments =
          ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
      matchId = routearguments["matchId"];

      silverfinals = routearguments["silverFinals"];

      goldMatchName = routearguments["goldGameNAme"];

      if (_isAdmin) {
        myCountry = routearguments["adminCountry"];
      }

      //2.) Provider Data
      // 2.1) In which Team do we play?
      final countrydata = Provider.of<Countryinfos>(context, listen: false);

      if (!_isAdmin) {
        myCountry = countrydata.item[0].myCountry;
        myFlag = countrydata.item[0].myFlag;
      }

      // 2.2) In which Tournament do we play?
      final tournamentData = Provider.of<Tournaments>(context, listen: false);
      tournamentId = tournamentData.item[0].tournamentid;

      // 3.) Analis which team is my Team

      List<String> matchElements = matchId.split(' ');

      FireCountry1 = matchElements[0];
      FireCountry2 = matchElements[2];

      if (FireCountry1 == myCountry) {
        opponentTeam = FireCountry2;
      }

      if (FireCountry2 == myCountry) {
        opponentTeam = FireCountry1;
      }

      getOpponentTeam(tournamentId, opponentTeam);
    });
  }

  @override
  void dispose() {
    Controller1.dispose();
    Controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isloading
        ? circularProgress()
        : Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  // iF is normal User - Show Flag - AppBar and Info about the Opponent Player.
                  !_isAdmin
                      ? Column(
                          children: [
                            flagAppBar(
                              myFlag: oppnentFlag,
                              screenHeightPercentage: 0.3,
                            ),
                            buildOponentPlayer(),
                            Stack(
                              children: <Widget>[
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  width: double.infinity,
                                  color: HexColor("#ffe664"),
                                ),
                                buildIntroFields(),
                                ClipPath(
                                    clipper: ClippingClass(),
                                    child: Container(
                                      color: Colors.white,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.07,
                                      width: double.infinity,
                                    )),
                              ],
                            ),
                          ],
                        )
                      : Container(
                      height: MediaQuery.of(context).size.height*1,
                      width: double.infinity,
                      color: HexColor("#ffe664"),

                      child: Column(
                        children: [
                          StandardAppBar(),
                          SizedBox(height: 50,),
                          buildIntroFields(),
                        ],
                      )),
                ],
              ),
            ),
          );
  }
}
