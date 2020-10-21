import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:multiculturalapp/Screens/Final/nextGoldMatchUser.dart';
import 'package:multiculturalapp/Screens/Final/silverGroupUser.dart';
import 'package:provider/provider.dart';
import 'package:multiculturalapp/MyWidgets/clippingClass.dart';
import 'package:multiculturalapp/MyWidgets/myAppBars/flagAppBar.dart';
import 'package:multiculturalapp/MyWidgets/progress.dart';
import 'package:multiculturalapp/Screens/TournOnScreen.dart';
import 'package:multiculturalapp/model/countryInfos.dart';
import 'package:multiculturalapp/model/tournaments.dart';
import 'package:multiculturalapp/model/users.dart';

class NextGameDetails extends StatefulWidget {
  static const link = "/NextGameDetails";

  @override
  _NextGameDetailsState createState() => _NextGameDetailsState();
}

class _NextGameDetailsState extends State<NextGameDetails> {
  var tournamentInstance =
      FirebaseFirestore.instance.collection("ourtournaments");

  String userName;

  String myCountry;

  String myFlag;

  String tournamentId;

  String matchId;

  String FireCountry1;

  String FireCountry2;

  String opponentTeam;

  String oppnentFlag;

  String opponentPlayer1Foto;

  String opponentPlayer1Name;

  String opponentPlayer2Foto;

  String opponentPlayer2Name;

  bool _isloading = true;

  String Result1;

  int result1NR;

  String Result2;

  int result2NR;

  String lastChangeInfo;

  String previousResult1;

  String previousResult2;

  String winnerTeam;

  String looserTeam;

  String opponentPlayer1Lvl;

  String opponentPlayer2Lvl;

  bool _isAdmin;

  String userlvl;

  bool silverfinals;

  String goldMatchName;
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
    opponentPlayer1Name = resultContent["player1Name"];
    opponentPlayer1Foto = resultContent["player1Photo"];
    opponentPlayer1Lvl = resultContent["player1lvl"];
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
                  CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.125,
                    backgroundImage: NetworkImage(opponentPlayer1Foto),
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
                  CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.125,
                    backgroundImage: NetworkImage(opponentPlayer2Foto),
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
        Navigator.of(context).popAndPushNamed(NextGoldMatchUser.link,
            arguments: {"matchProgress": goldMatchName});
        return;
      }
      Navigator.of(context).popAndPushNamed(SilverGroupUser.link);
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

  //1.) Is Admin Test Function
  void checkIfAdmin(String lvlInput) {
    if (lvlInput == "Admin") {
      _isAdmin = true;
    } else {
      _isAdmin = false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _isloading = true;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //0)Check is admin

      final userData = Provider.of<Users>(context, listen: false);

      userName = userData.item[0].username;
      userlvl = userData.item[0].lvl;
      checkIfAdmin(userlvl);

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
      print("matchid is $matchId");
      List<String> matchElements = matchId.split(' ');

      FireCountry1 = matchElements[0];
      FireCountry2 = matchElements[2];

      if (FireCountry1 == myCountry) {
        opponentTeam = FireCountry2;
      }

      if (FireCountry2 == myCountry) {
        opponentTeam = FireCountry1;
      }
      print("tournament id and opponentteam $tournamentId,$opponentTeam");
      getOpponentTeam(tournamentId, opponentTeam);

      print(_isAdmin);
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
    print("Opponent team is $opponentTeam ownTeam is $myCountry");
    return _isloading
        ? circularProgress()
        : Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  // Flag App Bar with some Extras - only if normal User.
                  !_isAdmin
                      ? flagAppBar(
                          myFlag: oppnentFlag,
                          screenHeightPercentage: 0.3,
                        )
                      : SizedBox(
                          height: 0,
                        ),
                  !_isAdmin
                      ? buildOponentPlayer()
                      : SizedBox(
                          height: 0,
                        ),

                  Stack(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: double.infinity,
                        color: HexColor("#ffe664"),
                      ),
                      ClipPath(
                          clipper: ClippingClass(),
                          child: Container(
                            color: Colors.white,
                            height: MediaQuery.of(context).size.height * 0.07,
                            width: double.infinity,
                          )),
                    ],
                  ),
                  Container(
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
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.1),
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
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.06,
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
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
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.06,
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
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
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.8),
                              fontSize: 12),
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
                  ),
                ],
              ),
            ),
          );
  }
}
