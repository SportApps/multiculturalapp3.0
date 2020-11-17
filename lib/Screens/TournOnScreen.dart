import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:multiculturalapp/MyWidgets/TournOnWidgets/GameCard.dart';
import 'package:multiculturalapp/MyWidgets/TournOnWidgets/myCountryInfo.dart';
import 'package:multiculturalapp/MyWidgets/TournamentInfoScr/tournamentinfo.dart';
import 'package:multiculturalapp/MyWidgets/clippingClass.dart';
import 'package:multiculturalapp/MyWidgets/myAppBars/flagAppBar.dart';
import 'package:multiculturalapp/MyWidgets/progress.dart';
import 'package:multiculturalapp/Screens/Final/tournamentFinished.dart';
import 'package:multiculturalapp/Screens/NextGameDetails.dart';
import 'package:multiculturalapp/Screens/groupphaseOverview.dart';
import 'package:multiculturalapp/Screens/home.dart';
import 'package:multiculturalapp/model/countryInfo.dart';
import 'package:multiculturalapp/model/countryInfos.dart';
import 'package:multiculturalapp/model/tournaments.dart';
import 'package:multiculturalapp/model/users.dart';
import 'package:provider/provider.dart';

import 'Final/finishedPhaseOverview.dart';

class TournOnScreen extends StatefulWidget {
  static const link = "/tournonscreen";

  @override
  _TournOnScreenState createState() => _TournOnScreenState();
}

class _TournOnScreenState extends State<TournOnScreen> {
  bool _countrySelected;
  String countryNow;
  String myCountry;
  String myGroup;
  String myFlag;
  int myWins;
  int myGamesLost;
  int gamesPlayed;
  int gamesLostLoop;
  var totalTeams;
  Map countryMap = {};
  List countryList = [];
  var loesung1;
  var loesung2;
  var _isloading;
  bool _finished;
  bool _isGoldWinner;
  bool _isGold;
  bool _silverFinished;
  bool _isdisqualified;
  String goldAdvance;

  bool _showScore = false;

  var matchesInGroup;

  List<List<String>> NRList = [];

  var tournamentinstance =
      FirebaseFirestore.instance.collection("ourtournaments");
  var _isAdmin;
  String userLvl;
  int grouplength;

  //1.) Is Admin Test Function

  // 2.) get Group Info function
  // --> Get GroupLength
  //--> Get Group Info (MyCountry, myFlag etc) and upload it on Provider CountryInfos
  //--> If Admin Activate get Groupswitcher Card
  // --> Calculate how many times we won/lost
  // -->Check if all matches are finished.
  // --> SetState()

// 3.) On GameCard Admin Functio9n - Change Group

  // 4.) calculateScoreButton (){} ADMIN

  // 5.) USER - Finish Group Phase Functions --> _isGold? _Which final Phase? Quarterfinals???

//0.) Is Admin AppBarbuilder
  Container appBarbuilder() {
    return Container(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.width * 0.1, bottom: 10),
      color: HexColor("#ffe664"),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
          ),
          Text(
            "Admin Function",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
          SizedBox(
            width: 45,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).popAndPushNamed(Home.link);
            },
            child: Container(
              height: 45,
              width: 45,
              padding: EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/smalllogo.png"))),
            ),
          )
        ],
      ),
    );
  }

  // 2.) get Group Info function
  getGroupInfo(String tournamentId) async {
    var groupInfo = await tournamentinstance
        .doc(tournamentId)
        .collection("countries")
        .get();
    String displayCountry;
    grouplength = groupInfo.docs.length;
    int NR = 0;

    String groupNumber;

    for (var i = 0; i < grouplength; i++) {
      displayCountry = groupInfo.docs[NR].id;
      var groupInfoVar = groupInfo.docs[NR];
      groupNumber = groupInfoVar.data()["groupNumber"];

      NRList.add([displayCountry, groupNumber]);
      NR++;
    }
  }

  // Here we Search Querry Firebase to get: Country and Group Number so we can use it OnScreen and add it to User Provider.
  void getCountry(String TournId, String nutzerId) async {
    // Basic reference that leads directly to Country collection.
    var collection =
        await tournamentinstance.doc(TournId).collection("countries");


    //--> Get Group Info (MyCountry, myFlag etc) and upload it on Provider CountryInfos
    // Get documents where the Player1ID is equal to our nutzerId.
    var result =
        await collection.where("player1ID", isEqualTo: nutzerId).getDocuments();
    var resultContent;
    resultContent = result.docs;

    if (resultContent != [""]) {
      print("Case1");

      result.docs.forEach((res) {
        loesung1 = res.data();
      });
    }

    result = await collection.where("player2ID", isEqualTo: nutzerId).get();

    resultContent = result.docs;

    if (resultContent != []) {
      print("Case2");

      result.docs.forEach((res) {
        loesung2 = res.data();
      });

      var richtigeLoesung;

      if (loesung1 != null) {
        richtigeLoesung = loesung1;
      } else if (loesung2 != null) {
        richtigeLoesung = loesung2;
      }


      if (!_isAdmin) {

        myGroup = richtigeLoesung["groupNumber"];
        myCountry = richtigeLoesung["CountryName"];

        myFlag = richtigeLoesung["CountryURL"];

        CountryInfo myCountryInfo = CountryInfo();

        myCountryInfo.myGroup = myGroup;
        myCountryInfo.myCountry = myCountry;
        myCountryInfo.myFlag = myFlag;

        final countryINFO = Provider.of<Countryinfos>(context, listen: false);
        await countryINFO.addCountryInfo(myCountryInfo);
        await finishPhaseandGo();
      }

      //--> If Admin Activate get Groupswitcher Card
      if (_isAdmin) {
        await getGroupInfo(tournamentId);
      }

      // --> Calculate how many times we won/lost
      var winnerdata = await tournamentinstance
          .doc(tournamentId)
          .collection("countries")
          .doc(myCountry)
          .collection("Results")
          .where("Winner", isEqualTo: myCountry)
          .get();

      myWins = winnerdata.docs.length;

      var looserData = await tournamentinstance
          .doc(tournamentId)
          .collection("countries")
          .doc(myCountry)
          .collection("Results")
          .where("Looser", isEqualTo: myCountry)
          .get();

      myGamesLost = looserData.docs.length;

      gamesPlayed = await myWins + myGamesLost;

    }

    // --> Get All the full Country Quantity



    setState(() {
      _isloading = false;
    });
  }

  void finishPhaseandGo() async {

    var disqualiFire = await tournamentinstance
        .doc(tournamentId)
        .collection("countries")
        .doc(myCountry)
        .get();

    bool _Isdisqualified = disqualiFire.data()["Disqualified"];
  }

// 3.) On GameCard Admin Functio9n - Change Group

  void onGameCardTap(BuildContext context, String matchId) {
    print(myCountry);
    Navigator.of(context).pushNamed(NextGameDetails.link, arguments: {
      "matchId": matchId,
      "adminCountry": myCountry,
      "silverFinals": false,
      "goldGameNAme": ""
    });
  }

  // 4.) calculateScoreButton (){} ADMIN

  calculateScore() async {
    countryMap.clear();
    countryList.clear();

    tournamentinstance
        .doc(tournamentId)
        .collection("countries")
        .get()
        .then((countryDoc) async {
      totalTeams = countryDoc.docs.length;

      //4.1) Create first Country: groupNumber Group
      int countryNR = 0;
      String currentTeam;
      String currentParticipant1ID;
      String currenParticipant2ID;
      String currentTeamGroup;
      int countryWins;

      var gamesInGroup;
      int runningNR = 0;
      for (var i = 0; i < totalTeams; i++) {
        var currentDocCountryNR = countryDoc.docs[countryNR];

        // Here we create a nested Map with each country and GroupNumber:
        // {Austria: {groupNumbar: 1}, Brazil: {groupNumbar: 1}, China: {groupNumbar: 2}}
        currentTeam = currentDocCountryNR.data()["CountryName"];
        currentParticipant1ID = currentDocCountryNR.data()["player1ID"];
        currenParticipant2ID = currentDocCountryNR.data()["player2ID"];
        currentTeamGroup = currentDocCountryNR.data()["groupNumber"];

        var countryWinResults = await tournamentinstance
            .doc(tournamentId)
            .collection("countries")
            .doc(currentTeam)
            .collection("Results")
            .where("Winner", isEqualTo: currentTeam)
            .get();

        countryWins = countryWinResults.docs.length;

        var countryResults = await tournamentinstance
            .doc(tournamentId)
            .collection("countries")
            .doc(currentTeam)
            .collection("Results")
            .get();

        print("test1");
        // Now we determine how many Points the currentTEam made in each match and add it to a list.
        gamesInGroup = countryResults.docs.length;

        gamesLostLoop = gamesInGroup - countryWins;
        List<int> PointResults = [];
        int accumulatedPoints;
        int currentResult;
        var matchIndex = 0;
        print("test2");

        // Here we fill the PointResult List
        for (var iii = 0; iii < gamesInGroup; iii++) {
          var countryResultsDocMatchIndex =
              countryResults.docs[matchIndex].data();
          currentResult =
              int.parse(countryResultsDocMatchIndex["Result $currentTeam"]);

          PointResults.add(currentResult);

          matchIndex++;
        }
        print("test3");
        print(currentTeam);
        print(PointResults);

        // Here we put the GroupNumber, Wins and accumulated Points in one big List.
        countryMap.putIfAbsent(currentTeam, () {
          accumulatedPoints = PointResults.reduce((a, b) => a + b);
          print(countryMap);
          return {
            "groupNumbar": currentTeamGroup,
            "Wins": countryWins,
            "accumulatedPoints": accumulatedPoints,
          };
        });

        // Here we add the teamMembersId to the list so we can later add the points on their account.

        countryList.add({
          "runningNR": runningNR,
          "currentTeam": currentTeam,
          "currentTeamGroup": currentTeamGroup,
          "player1ID": currentParticipant1ID,
          "player2ID": currenParticipant2ID,
          "countryWins": countryWins,
          "countryLost": gamesLostLoop,
          "accumulatedPoints": accumulatedPoints,
          "goldGroup": false,
        });
        runningNR++;
        print(countryMap);
        print("This is the countryList $countryList");

        // Sort CountryMap

        // var Map = SortedMap.from(countryMap["Wins"]);
        // print(Map);

        countryNR++;
      }

      _isloading = false;
      Navigator.of(context)
          .pushNamed(GroupPhaseOverview.link, arguments: countryList);
      setState(() {
        _showScore = true;
      });
      // 4.2) Create second country: Wins map.
    });
  }

  void checkGameStatus(ctx) async {
    var fireCountry = await tournamentinstance
        .doc(tournamentId)
        .collection("countries")
        .doc(myCountry)
        .get();

    _isdisqualified = fireCountry.data()["Disqualified"];
    _isGoldWinner = fireCountry.data()["Grand Finale Winner"];

    if (_isGoldWinner == null) {
      _isGoldWinner = false;
    }

    if (_isdisqualified || _isGoldWinner) {
      Navigator.of(context).popAndPushNamed(TournamentFinished.link);
      return;
    }

    await tournamentinstance
        .doc(tournamentId)
        .collection("Status")
        .doc("Finals")
        .get()
        .then(
      (doc) {
        if (doc.exists) {
          _finished = true;
          // getMyFinalStatus is executed to fill out arguments of popandPushNamed.
          getMyFinalStatus();
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

  // 5.) USER - Finish Group Phase Functions --> _isGold? _Which final Phase? Quarterfinals???

  // 5.1) Main Function - Check if gold...
  getMyFinalStatus() async {
    var myTournamentData = await tournamentinstance
        .doc(tournamentId)
        .collection("countries")
        .doc(myCountry)
        .get();

    String goldStatus = myTournamentData.data()["Finalgroup"];

    print("In the TournamentOn it´s now $goldStatus");
    if (goldStatus == "Gold") {
      _isGold = true;
      getGoldGroupAdvance();
    }

    //HERE

    else {
      _isGold = false;
      //If we are in the Silver Group it checks if the Silver Group is over and in this case sends us back.
      getSilverGroupAdvance();
    }
  }

  // 5.2) Helper Function - IF Gold - it is implemented and gets the currentProgress.
  getGoldGroupAdvance() async {
    var myTournamentData = await tournamentinstance
        .doc(tournamentId)
        .collection("countries")
        .doc(myCountry)
        .collection("Finals")
        .get();

    var myTournamentDataDoc0 = myTournamentData.documents[0];

    goldAdvance = myTournamentDataDoc0.data()["GameName"];

    Navigator.of(context).popAndPushNamed(FinishedPhaseOverview.link,
        arguments: {"isGold": _isGold, "progress": goldAdvance});
  }

  // 5.2) Helper Function - IF Silver - it is implemented and gets the currentProgress.
  getSilverGroupAdvance() async {
    var silverData = await tournamentinstance
        .doc(tournamentId)
        .collection("Status")
        .doc("Finals")
        .get();

    if (silverData.data()["silverFinished"] != null) {
      _silverFinished = silverData.data()["silverFinished"];
    }

    if (_silverFinished) {
      print("Silver Phase is sover and we are send back.");

      Navigator.of(context).popAndPushNamed(Home.link);
    } else {
      Navigator.of(context).popAndPushNamed(FinishedPhaseOverview.link,
          arguments: {"isGold": _isGold, "progress": goldAdvance});
    }

    Navigator.of(context).popAndPushNamed(FinishedPhaseOverview.link,
        arguments: {"isGold": _isGold, "progress": goldAdvance});
  }

  Container buildCountrySelecter() {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 20, bottom: 20),
            child: Text(
              "Group Phase",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: 5, bottom: 15),
            child: Text(
              "Change Country",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color:Colors.black.withOpacity(0.6)),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05),
            height: 80,
            width: MediaQuery.of(context).size.width,
            child: GridView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: grouplength,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    childAspectRatio: 1 / 2,
                    mainAxisSpacing: 20),
                itemBuilder: (context, i) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            width: 1, color: Colors.black.withOpacity(0.48)),
                        borderRadius: BorderRadius.circular(11)),
                    child: InkWell(
                      onTap: () async {
                        setState(() {
                          _isloading = true;
                        });
                        var countryNow = NRList[i][0];

                        var newCountrydoc = await tournamentinstance
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            NRList[i][0],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Group ",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,

                                ),
                              ),
                              Text(
                                NRList[i][1],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,

                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  @override
  initState() {
    // TODO: implement initState
    super.initState();
    _silverFinished = false;
    _isloading = true;
    _showScore = false;
    _countrySelected = false;
    _isGold = false;
    goldAdvance = "";

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final userData = Provider.of<Users>(context, listen: false);

      final userinfo = userData.item;
      final String userId = userinfo[0].id;
      _isAdmin = userinfo[0].isAdmin;

      if (!_isAdmin) {
        _countrySelected = true;
      }



      final tournamentInfo = Provider.of<Tournaments>(context, listen: false);

      final tournamentiform = tournamentInfo.item;
      final String tournamentId = tournamentiform[0].tournamentid;
    });

    getCountry(tournamentId, userId);

    // If we are not an Admin we set CountrySelected to true so the athlet can see his/her result (Streambuilder List)
  }

  @override
  Widget build(BuildContext context) {
    return _isloading
        ? circularProgress()
        : Scaffold(
        resizeToAvoidBottomInset:false,
        body: Column(
              children: <Widget>[
                // We use the flagAppBar to visualize the users Country Flag.
                _isAdmin
                    ? appBarbuilder()
                    : flagAppBar(
                        myFlag: myFlag,
                        screenHeightPercentage: 0.25,
                      ),
                // FOR USERS: We use the My CountryInfo to show all relevavnt Country Info
                _isAdmin
                    ? SizedBox(
                        height: 0,
                      )
                    : Container(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.02),
                        color: Colors.white,
                        child: MyCountryInfo(
                          phase: "Group Phase",
                          groupNR: myGroup,
                          myCountry: myCountry,
                          myWins: myWins.toString(),
                          myLost: myGamesLost.toString(),
                        ),
                      ),
                // ADMIN FUNCTIONS
                !_isAdmin
                    ? SizedBox(
                        height: 0,
                      )
                    //The buildCountrySelecter buildFunction creates a Gridview which makes it possible for the ADMIN to select a Country.
                    : buildCountrySelecter(),
                // This Streambuilder shows the Game Results of the selected Country and is available for User and Admin.
                _countrySelected
                    ? Column(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.06,
                                width: double.infinity,
                                color: HexColor("#ffe664"),
                              ),
                              ClipPath(
                                clipper: ClippingClass(),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.06,
                                  width: double.infinity,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.03,
                                bottom: 5),
                            width: double.infinity,
                            color: HexColor("#ffe664"),
                            child: Text(
                              "Next Matches",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.8),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.225,
                            width: MediaQuery.of(context).size.width,
                            color: HexColor("#ffe664"),
                            child: StreamBuilder(
                                stream: tournamentinstance
                                    .doc(tournamentId)
                                    .collection("countries")
                                    .doc(myCountry)
                                    .collection("Results")
                                    .snapshots(),
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

                                  return ListView.builder(
                                      itemCount: _loadeddata.length,
                                      itemBuilder: (context, i) {
                                        _loadeddataIndex = _loadeddata[i];
                                        team1 =
                                            _loadeddataIndex.data()["Team1"];
                                        team2 =
                                            _loadeddataIndex.data()["Team2"];
                                        return InkWell(
                                          onTap: () {
                                            onGameCardTap(
                                                context, _loadeddata[i].id);
                                          },
                                          child: GameCard(
                                            team1: team1,
                                            team2: team2,
                                            Result1: _loadeddataIndex
                                                .data()["Result $team1"],
                                            Result2: _loadeddataIndex
                                                .data()["Result $team2"],
                                          ),
                                        );
                                      });
                                }),
                          ),
                          !_isAdmin
                              // If we have a user Profile there is a Button to progress to the next Screens.
                              // We make a Builder as the SnackBar if we are not finished with the Groupphase needs a special Context.
                              ? Builder(builder: (mycontext) {
                                  return Container(
                                    margin: EdgeInsets.only(top: 20),
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.24),
                                    width: double.infinity,
                                    color: HexColor("#ffe664"),
                                    child: RaisedButton(
                                        onPressed: () {
                                          checkGameStatus(mycontext);
                                        },
                                        child: Text("Finish Group Phase")),
                                  );
                                })
                              : SizedBox(height: 0),
                        ],
                      )
                    : Container(
                        color: Colors.white,
                        width: double.infinity,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "To see results please choose a country.",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black.withOpacity(0.6)),
                            ),
                          ],
                        ),
                      ),

                _isAdmin
                    ? RaisedButton(
                        child: Text("Calculate Score"),
                        onPressed: () {
                          setState(() {
                            _isloading = true;
                          });
                          calculateScore();
                        },
                      )
                    : SizedBox(
                        height: 0,
                      )
              ],
            ),
          );
  }
}
