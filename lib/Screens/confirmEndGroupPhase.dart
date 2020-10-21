import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:multiculturalapp/MyWidgets/TournamentInfoScr/teamoverview.dart';
import 'package:multiculturalapp/MyWidgets/clippingClass.dart';
import 'package:multiculturalapp/Screens/home.dart';
import 'package:provider/provider.dart';
import 'package:multiculturalapp/MyWidgets/TournamentInfoScr/addPlayer1.dart';
import 'package:multiculturalapp/MyWidgets/TournamentInfoScr/addPlayer2.dart';
import 'package:multiculturalapp/MyWidgets/TournamentInfoScr/tournamentinfo.dart';
import 'package:multiculturalapp/MyWidgets/progress.dart';

import 'package:multiculturalapp/model/tournaments.dart';

import 'Final/FinalsAdmin.dart';

Column buildListView(List compList, String Groupname, bool isGold) {
  String groupsize = compList.length.toString();

  return Column(
    children: <Widget>[
      SizedBox(
        height: 15,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10),
            width: 70,
            height: 50,
            decoration: BoxDecoration(
                image: DecorationImage(
              image: isGold
                  ? AssetImage("assets/images/congratstrophy.png")
                  : AssetImage("assets/images/silvergroup.png"),
            )),
          ),
          SizedBox(
            width: 5,
          ),
          Column(
            children: [
              Text(
                Groupname,
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.8)),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "$groupsize Teams",
                style: TextStyle(
                    fontSize: 20, color: Colors.black.withOpacity(0.8)),
              ),
            ],
          ),
        ],
      ),
      SizedBox(
        height: 15,
      ),
      Flexible(
        child: ListView.builder(
            itemCount: compList.length,
            itemBuilder: (context, index) {
              String currentWins = compList[index]["countryWins"].toString();
              String currentACP =
                  compList[index]["accumulatedPoints"].toString();
              String currentGroup =
                  compList[index]["currentTeamGroup"].toString();
              return Container(
                height: 80,
                margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.1,
                    vertical: 10),
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      width: 1,
                      color: HexColor("#979797"),
                    )),
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 20),
                      color: HexColor("#ea070a"),
                      width: 80,
                      child: Center(
                        child: Text("$currentWins W",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(compList[index]["currentTeam"],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "$currentACP ACP",
                            style: TextStyle(
                                color: HexColor("#ea070a"),
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.1,
                      child: Text(
                        "$currentGroup OG",
                        textAlign: TextAlign.end,
                      ),
                    )
                  ],
                ),
              );
            }),
      )
    ],
  );
}

class ConfirmedEndGroupPhase extends StatefulWidget {
  static const link = "/ConfirmedendGroupPhase";

  @override
  _ConfirmedEndGroupPhaseState createState() => _ConfirmedEndGroupPhaseState();
}

class _ConfirmedEndGroupPhaseState extends State<ConfirmedEndGroupPhase> {
  List<Map> goldList;

  List<String> goldonlyCountryList = [];

  List<Map> silverList;

  List<String> goldMatchList = [];

  bool _goldOK;

  bool _isloading;

  var tournamentinstance =
      FirebaseFirestore.instance.collection("ourtournaments");

  String tournamentId;

  int teamsInSilverGroup;

  double silverGroups;

  TextEditingController _silverGroupController = TextEditingController();

  List groupChunk = [];

  List<String> tournamentIdsSilver = [];

  Map groupChunkMap;

  Map silverGameMap = {};

  Map silverGroupTeamMap = {};

  List<List<String>> groupsToSilverCountry = [];

  String gameName;

  List countryList = [];

  // 00) Show Dialog - No Teams/ Group for Silver defined
  //
  void noTeamsErrermsg() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Information incomplete"),
          content:
              new Text("Please introduce a value for Teams/Group in Silver"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
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
            "End Group Phase",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
          SizedBox(
            width: 37,
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

  // Table of content
  //1.) Gold Group Quantity check
  // 2.) Create Gold Group Matches
  // 3.) Create Silver Group Matches
  // 4.) Create Status "Start Finals in DB" so user can access their next games.
  //5.) Upload Finals Summary
  // 6.) Add Points of Group Phase to the participants score.

  //1.) Gold Group Quantity check
  // Check if there is the correct quantity of Teams in the Gold Group before shwoing the "Create Matchtess Button".

  checkifGoldOK() {
    if (goldList.length == 2 ||
        goldList.length == 4 ||
        goldList.length == 8 ||
        goldList.length == 16 ||
        goldList.length == 32) {
      setState(() {
        _goldOK = true;
      });
    }
  }

  // 2.) Create Gold Group Matches and upload them on Firebase

  createGoldMatches() async {
    // 2.1) Make the groupNumber the first order so team plays against someone from different group.
    goldList.sort(
        (a, b) => (b["currentTeamGroup"]).compareTo(a["currentTeamGroup"]));

    // 2.2) Loop that creates the matches in a List.
    double doubleGames = goldList.length / 2;
    int goldmatchesLength = doubleGames.round();
    int Team1NR = 0;
    int Team2NR = goldmatchesLength * 2 - 1;
    String team1Name;
    String team2Name;
    String currentMatch;

    goldMatchList.clear();

    for (var i = 0; i < goldmatchesLength; i++) {
      print(Team1NR);
      print(Team2NR);

      team1Name = goldList[Team1NR]["currentTeam"];
      team2Name = goldList[Team2NR]["currentTeam"];

      currentMatch = "$team1Name vs. $team2Name";
      goldMatchList.add(currentMatch);
      print(currentMatch);
      Team1NR++;
      Team2NR--;
    }
    // 2.3) Determine wheather we are in Quarterfinals Semifinals etc.

    if (goldMatchList.length == 16) {
      gameName = "32 Teams left";
    } else if (goldMatchList.length == 8) {
      gameName = "Eighth - Final";
    } else if (goldMatchList.length == 4) {
      gameName = "Quarter - Final";
    } else if (goldMatchList.length == 2) {
      gameName = "Semi - Final";
    } else if (goldMatchList.length == 1) {
      gameName = "Grand Finale";
    }
// 2.4) Upload goldMatchList

    //2.4.1) Get a list with all the Countries that are in the Gold Group (future DOC ID)

    var Nummer = 0;
    var Country;
    goldonlyCountryList = [];
    for (var i = 0; i < goldList.length; i++) {
      Country = goldList[Nummer]["currentTeam"];
      goldonlyCountryList.add(Country);
      Nummer++;
    }

    // 2.4.2) Upload everything Country by Country
    Nummer = 0;
    String currentCountry;
    int zahl;

    // Outer loob where we go to all countries.
    for (var i = 0; i < goldMatchList.length; i++) {
      currentCountry = goldonlyCountryList[Nummer];

      zahl = 0;
      String thisMatch;
      // Inner Loop which goes through all Matches and checks if tht currentmatch contains the currentCountry.
      // Here we make the DB entry.
      for (var i = 0; i < goldmatchesLength; i++) {
        thisMatch = goldMatchList[zahl];

        List<String> matchpeaces = [];
        String team1;
        String team2;
        if (thisMatch.contains(currentCountry)) {
          matchpeaces = thisMatch.split(" ");
          team1 = matchpeaces[0];
          team2 = matchpeaces[2];

          // Upload for team1;
          await tournamentinstance
              .doc(tournamentId)
              .collection("countries")
              .doc(goldonlyCountryList[Nummer])
              .collection("Finals")
              .doc(thisMatch)
              .set({
            "Group": "Gold",
            "GameName": gameName,
            "ChangeRegister": "",
            "Looser": "",
            "Result $team1": "",
            "Result $team2": "",
            "Team1": team1,
            "Team2": team2,
            "Winner": "",
          });
          // Upload for team2;
          await tournamentinstance
              .doc(tournamentId)
              .collection("countries")
              .doc(team2)
              .collection("Finals")
              .doc(thisMatch)
              .set({
            "Group": "Gold",
            "GameName": gameName,
            "ChangeRegister": "",
            "Looser": "",
            "Result $team1": "",
            "Result $team2": "",
            "Team1": team1,
            "Team2": team2,
            "Winner": "",
          });
        }
        zahl++;
      }

      Nummer++;
    }

    // Step 2.5) Mark Gold Group Teams as participants in Gold Group

    var numma = 0;
    for (var i = 0; i < goldonlyCountryList.length; i++) {
      await tournamentinstance
          .doc(tournamentId)
          .collection("countries")
          .doc(goldonlyCountryList[numma])
          .set({"Finalgroup": "Gold"}, SetOptions(merge: true));

      numma++;
    }
  }

// 3.) Create Silver Group Matches
  createSilverMatches() async {
    int recentGroupnumber = 0;
    int recentTeam = 0;

    silverGroups = silverList.length / teamsInSilverGroup;

    // Step 1 Make a list of all countries inside the Silver Group:

    var NR = 0;
    var addTeamtoSilver;
    tournamentIdsSilver.clear();
    for (var i = 0; i < silverList.length; i++) {
      addTeamtoSilver = silverList[NR]["currentTeam"];
      tournamentIdsSilver.add(addTeamtoSilver);
      NR++;
    }
    print(tournamentIdsSilver);
    // Step 2: Check if we can make even groups.
    bool isIntegral(num groups) =>
        groups is int || groups.truncateToDouble() == groups;
    // Check if groups -1 is Integral --> There is 1 team too much.
    double groupsMinus1 = (silverList.length - 1) / teamsInSilverGroup;

    bool isMinus1Integral(num groupsMinus1) =>
        groupsMinus1 is int || groupsMinus1.truncateToDouble() == groupsMinus1;

    // Check if groups -2 is Integral.
    double groupsMinus2 = (silverList.length - 2) / teamsInSilverGroup;

    bool isMinus2Integral(num groupsMinus2) =>
        groupsMinus2 is int || groupsMinus2.truncateToDouble() == groupsMinus2;

    // Check if groups -3 is Integral.
    double groupsMinus3 = (silverList.length - 3) / teamsInSilverGroup;

    bool isMinus3Integral(num groupsMinus3) =>
        groupsMinus3 is int || groupsMinus3.truncateToDouble() == groupsMinus3;

// Step 3 Locally create groups in List.
    // Case 1: We have an even group size.

    groupChunk.clear();

    if (isIntegral(silverGroups)) {
      for (int i = 0; i < silverGroups; i++) {
        groupChunk.add(tournamentIdsSilver.sublist(
          recentTeam,
          recentTeam + teamsInSilverGroup,
        ));

        recentGroupnumber = recentGroupnumber + 1;
        recentTeam = recentTeam + teamsInSilverGroup;
        print(groupChunk);
      }
    }
// Case 2: Resting one team we have an even group size.
    else if (isMinus1Integral(groupsMinus1)) {
      print("Case 2 --> Groups-1");

      for (int i = 0; i < groupsMinus1; i++) {
        groupChunk.add(tournamentIdsSilver.sublist(
          recentTeam,
          recentTeam + teamsInSilverGroup,
        ));

        recentGroupnumber = recentGroupnumber + 1;
        recentTeam = recentTeam + teamsInSilverGroup;
      }
      recentGroupnumber--;

      print("The recent Team is $recentTeam");

      groupChunk[recentGroupnumber].insert(
          groupChunk[recentGroupnumber].length - 1,
          tournamentIdsSilver.elementAt(recentTeam));
    }
    // Case 3: Resting two team we have an even group size.
    else if (isMinus2Integral(groupsMinus2)) {
      print("Case 3 --> Groups-2");

      for (int i = 0; i < groupsMinus2; i++) {
        groupChunk.add(tournamentIdsSilver.sublist(
          recentTeam,
          recentTeam + teamsInSilverGroup,
        ));

        recentGroupnumber = recentGroupnumber + 1;
        recentTeam = recentTeam + teamsInSilverGroup;
        print(groupChunk);
      }
      // Add the rest of the teams (2 teams left because of uneven team numbers.
      // Here we add the first team to the last group.
      recentGroupnumber--;

      print("The recent Team is $recentTeam");
      print(recentGroupnumber);
      groupChunk[recentGroupnumber].insert(
          groupChunk[recentGroupnumber].length - 1,
          tournamentIdsSilver.elementAt(recentTeam));

      // Here we add the second team the second last group.
      recentGroupnumber--;
      recentTeam++;
      print("The recent Team is $recentTeam");
      print(recentGroupnumber);
      groupChunk[recentGroupnumber].insert(
          groupChunk[recentGroupnumber].length - 1,
          tournamentIdsSilver.elementAt(recentTeam));
    }

    // Case 4: Resting two team we have an even group size.
    else if (isMinus3Integral(groupsMinus3)) {
      print("Case 4 --> Groups-3");
      print(groupsMinus3);
      for (int i = 0; i < groupsMinus3; i++) {
        print(recentGroupnumber);

        groupChunk.add(tournamentIdsSilver.sublist(
          recentTeam,
          recentTeam + teamsInSilverGroup,
        ));

        recentGroupnumber = recentGroupnumber + 1;
        recentTeam = recentTeam + teamsInSilverGroup;
      }
      // Add the rest of the teams (2 teams left because of uneven team numbers.
      // Here we add the first team to the last group.
      recentGroupnumber--;

      groupChunk[recentGroupnumber].insert(
          groupChunk[recentGroupnumber].length - 1,
          tournamentIdsSilver.elementAt(recentTeam));

      // Here we add the second team the second last group.
      recentGroupnumber--;
      recentTeam++;

      groupChunk[recentGroupnumber].insert(
          groupChunk[recentGroupnumber].length - 1,
          tournamentIdsSilver.elementAt(recentTeam));

      // Here we add the third team the second last group.
      recentGroupnumber--;
      recentTeam++;

      groupChunk[recentGroupnumber].insert(
          groupChunk[recentGroupnumber].length - 1,
          tournamentIdsSilver.elementAt(recentTeam));
    } else {
      // THIS SHOULDNT HAPPEN ONLY IF THERE ARE MORE THEN 4 TEAMS OUT
      print(groupsMinus1);
      print("Group size is not an even number.");
    }
    print("This is the group CHUNK $groupChunk");
// Step 4: Preparing the upload by converting the Nested List into a Map and giving each Entry a GroupNumber.

    groupChunkMap = {};

    int currentGruppenNr = 1;
    int Laenge = groupChunk.length.floor();
    for (var ii = 0; ii < Laenge; ii++) {
      groupChunkMap.addAll({currentGruppenNr: groupChunk[ii]});
      currentGruppenNr++;
    }
    print("This is our GroupChunkmap $groupChunkMap");

    print("This is the groupChunk of Silver: $groupChunk");
    print(silverGroups);

    // Step 4.1 Create a List with all matches of Group Phase.

    var aktuelleGruppe = 1;
    var aktuelleGrupenInhalt;
    var aktuelleGruppenLaenge;
    // Loop through each group.
    var matchID = 0;
    List<String> currentGameList = [];
    for (var y = 0; y < groupChunkMap.length; y++) {
      // We need to know how big the current group is.
      aktuelleGrupenInhalt = groupChunkMap[aktuelleGruppe];
      aktuelleGruppenLaenge = aktuelleGrupenInhalt.length;
      String currentGame;

      var homeTeam = 0;
      var oppositeTeam = 1;
      var LoopAusgleich = 2;

      // In the following loop we make sure that 2vs3 2vs4 3vs4 etc
      for (var xx = 0; xx <= aktuelleGruppenLaenge - 2; xx++) {
        // Here we make sure that 1vs2 2vs3 etc...
        for (var x = 0; x <= aktuelleGruppenLaenge - LoopAusgleich; x++) {
          currentGame = aktuelleGrupenInhalt[homeTeam] +
              " vs. " +
              aktuelleGrupenInhalt[oppositeTeam];

          currentGameList.add(currentGame);

          matchID++;
          oppositeTeam++;
        }

        oppositeTeam = oppositeTeam - aktuelleGruppenLaenge + LoopAusgleich;
        LoopAusgleich++;

        homeTeam++;
      }

      // Durch das HomeTeam ++ setzen wir um, dass für das nächste Team alle Spiele gemacht werden
      aktuelleGruppe++;
    }

    print(currentGameList);

    // Step 4.2 Have a Map of countries with a List of all their games.
    // RESULT IS THE GAMEMAP which shows for each team which matches they have.

    var currentCountryNumber;
    var currentTeam = 0;
    String aktuellesSpiel;
    List spielList = [];

    for (var aa = 0; aa < tournamentIdsSilver.length; aa++) {
      currentCountryNumber = 0;
      for (var a = 0; a < currentGameList.length; a++) {
        aktuellesSpiel = currentGameList[currentCountryNumber];

        if (aktuellesSpiel.contains(tournamentIdsSilver[currentTeam])) {
          spielList.add(aktuellesSpiel);
        }

        currentCountryNumber++;

        silverGameMap.putIfAbsent(
            tournamentIdsSilver[currentTeam], () => spielList);
      }

      spielList = [];
      currentTeam++;
    }
    print(silverGameMap);

    // Step 4.3 Upload this map to Firestore so we can see for each country which matches they will have in the group phase.

    var toUploadCountryIndex = 0;
    String toUploadCountry;
    String uploadMatch;
    var matchIndex;
    var quantityTeams = tournamentIdsSilver.length;
    // In the Outside Loop, we go through all the Countries that signed up for the tournament (e.g.20)
    for (var b = 0; b < quantityTeams; b++) {
      // We take one tournamentParticipant (coutnry, at a time)
      toUploadCountry = tournamentIdsSilver[toUploadCountryIndex];
      print("This is the $silverGameMap");
      var quantityGamesofPatricpant = silverGameMap[toUploadCountry].length;
      print(quantityGamesofPatricpant);

      matchIndex = 0;
      for (var c = 0; c < quantityGamesofPatricpant; c++) {
        uploadMatch = silverGameMap[toUploadCountry][matchIndex];

        // Here we get the Country names involved in the Match
        var Team1;
        var Team2;

        List<String> matchElements = uploadMatch.split(' ');

        Team1 = matchElements[0];
        Team2 = matchElements[2];

        // Upload the match
        await tournamentinstance
            .doc(tournamentId)
            .collection("countries")
            .doc(toUploadCountry)
            .collection("Finals")
            .doc(uploadMatch)
            .set({
          "Group": "Silver",
          "Team1": Team1,
          "Result $Team1": "0",
          "Team2": Team2,
          "Result $Team2": "0",
          "Winner": "",
          "ChangeRegister": ""
        });
        matchIndex++;
      }
      toUploadCountryIndex++;
    }

    // Step 4.4) Mark Silver Group Teams as participants in Silver Group

    var numma = 0;
    for (var i = 0; i < tournamentIdsSilver.length; i++) {
      await tournamentinstance
          .document(tournamentId)
          .collection("countries")
          .document(tournamentIdsSilver[numma])
          .setData({"Finalgroup": "Silver"}, SetOptions(merge: true));

      numma++;
    }

    // Step 4.5) Upload in which group each Country plays
    int momZahl = 0;
    int innerMomZahl;
    groupsToSilverCountry.clear();
    String currentgroupCountry;
    print(groupChunk);
    print(silverList.length);

    for (var i = 0; i < groupChunk.length; i++) {
      print("following is groupChunk length.");
      print(groupChunk.length);
      innerMomZahl = 0;
      for (var ii = 0; ii < groupChunk[momZahl].length; ii++) {
        print("following is groupChunk[momZahl] length.");
        print(groupChunk[momZahl].length);
        currentgroupCountry = groupChunk[momZahl][innerMomZahl];
        groupsToSilverCountry
            .add([currentgroupCountry, (momZahl + 1).toString()]);

        await tournamentinstance
            .document(tournamentId)
            .collection("countries")
            .document(currentgroupCountry)
            .setData({"silverGroup": momZahl + 1}, SetOptions(merge: true));
        innerMomZahl++;
      }
      print("Outerloop completed");
      momZahl++;
    }
    print("Here you go!");
    print(groupsToSilverCountry);
  }

  startFinals() async {
    //1.) Start Finals
    await tournamentinstance
        .doc(tournamentId)
        .collection("Status")
        .doc("Finals")
        .set({"Beginn": true, "matchProgress": gameName},
            SetOptions(merge: true));
    //2.) Finish Group Phase
    await tournamentinstance
        .doc(tournamentId)
        .collection("Status")
        .doc("Beginn")
        .set({"Finish": true}, SetOptions(merge: true));
  }

  //5.) Upload Finals Summary
  uploadFinalsSummaries() async {
    await tournamentinstance
        .doc(tournamentId)
        .collection("Summary")
        .doc("Finals")
        .set({
      "SilverGroups": silverList.length,
      "SilverMatches": silverGameMap,
      "GoldTeams": goldonlyCountryList,
      "GoldMatchList": goldMatchList
    });
  }

  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    _silverGroupController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isloading = true;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var routeargs = ModalRoute.of(context).settings.arguments as Map;

      countryList = routeargs["countryList"];
      goldList = routeargs["gold"];
      goldList.sort(
          (a, b) => (b["accumulatedPoints"]).compareTo(a["accumulatedPoints"]));

      // Sort GoldList in first Order with CountryWins and in second Order with accumulated Wins.

      goldList.sort((a, b) => (b["countryWins"]).compareTo(a["countryWins"]));

      silverList = routeargs["silver"];

      // Sort SilverList in first Order with CountryWins and in second Order with accumulated Wins.
      silverList.sort(
          (a, b) => (b["accumulatedPoints"]).compareTo(a["accumulatedPoints"]));

      silverList.sort((a, b) => (b["countryWins"]).compareTo(a["countryWins"]));

      // Get tournamentID from Provider
      final tournamentInfo = Provider.of<Tournaments>(context, listen: false);
      final tournamentiform = tournamentInfo.item;
      tournamentId = tournamentiform[0].tournamentid;

      print("This is the countryList $countryList");
      print("This is the groupchunk map $groupChunkMap");

      setState(() {
        _isloading = false;
      });

      _goldOK = false;
      checkifGoldOK();
    });
  }

  addGroupPhasePoints() async {
    List pointOverviewGeneral = [];
    List pointOverview1 = [];
    List pointOverview2 = [];
    String currentPlayer1ID;
    String currentPlayer2ID;
    int currentWins;
    int currentcountryLost;
    pointOverviewGeneral.clear();

    var NR = 0;
    var IndexNR = 0;

    pointOverviewGeneral.clear();
    for (var i = 0; i < countryList.length; i++) {
      // For each country, create
      pointOverview1.clear();
      pointOverview2.clear();
      print(countryList.length);

      currentPlayer1ID = countryList[NR]["player1ID"];
      currentPlayer2ID = countryList[NR]["player2ID"];
      currentWins = countryList[NR]["countryWins"];
      currentcountryLost = countryList[NR]["countryLost"];

      var fireUser1DataP1 = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentPlayer1ID)
          .get();

      var previousGamesWonP1 = fireUser1DataP1.data()["historyGamesWon"];
      var previousPointsP1 = fireUser1DataP1.data()["points"];
      var previousLostP1 = fireUser1DataP1.data()["historyGamesLost"];

      var newPointsP1 = previousPointsP1 + currentWins;

      var newLostP1 = previousLostP1 + currentcountryLost;

      var newWinsP1 = previousGamesWonP1 + currentWins;

      var newWinLooseRatioP1 = newWinsP1 / newLostP1;

      String newLvlP1;

      if (newPointsP1 >= 100 && newWinLooseRatioP1 > 2) {
        newLvlP1 = "Volley God";
      } else if (newPointsP1 >= 50 && newWinLooseRatioP1 > 1) {
        newLvlP1 = "Experienced";
      } else if (newPointsP1 >= 30) {
        newLvlP1 = "Grown-Up";
      } else if (newPointsP1 >= 20) {
        newLvlP1 = "Amateur";
      } else if (newPointsP1 >= 10) {
        newLvlP1 = "Little Child";
      } else {
        newLvlP1 = "Baby Beginner";
      }

      FirebaseFirestore.instance
          .collection("users")
          .doc(currentPlayer1ID)
          .update({
        "points": newPointsP1,
        "historyGamesWon": newWinsP1,
        "historyGamesLost": newLostP1,
        "winLooseRatio": newWinLooseRatioP1,
        "achievedLvl": newLvlP1,
      });

      var fireUser1DataP2 = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentPlayer2ID)
          .get();

      var previousGamesWonP2 = fireUser1DataP2.data()["historyGamesWon"];
      var previousPointsP2 = fireUser1DataP2.data()["points"];
      var previousLostP2 = fireUser1DataP2.data()["historyGamesLost"];

      var newPointsP2 = previousPointsP2 + currentWins;

      var newLostP2 = previousLostP2 + currentcountryLost;

      var newWinsP2 = previousGamesWonP2 + currentWins;

      var newWinLooseRatioP2 = newWinsP2 / newLostP2;

      String newLvlP2;

      if (newPointsP2 >= 100 && newWinLooseRatioP2 > 2) {
        newLvlP2 = "Volley God";
      } else if (newPointsP2 >= 50 && newWinLooseRatioP2 > 1) {
        newLvlP2 = "Experienced";
      } else if (newPointsP2 >= 30) {
        newLvlP2 = "Grown-Up";
      } else if (newPointsP2 >= 20) {
        newLvlP2 = "Amateur";
      } else if (newPointsP2 >= 10) {
        newLvlP2 = "Little Child";
      } else {
        newLvlP2 = "Baby Beginner";
      }

      FirebaseFirestore.instance
          .collection("users")
          .doc(currentPlayer2ID)
          .update({
        "points": newPointsP2,
        "historyGamesWon": newWinsP2,
        "historyGamesLost": newLostP2,
        "winLooseRatio": newWinLooseRatioP2,
        "achievedLvl": newLvlP2,
      });
      print(newPointsP2);
      print("$previousPointsP2+$currentWins");

      NR++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isloading
          ? circularProgress()
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  appBarbuilder(),
                  Container(
                      padding: EdgeInsets.only(top: 20),
                      height: MediaQuery.of(context).size.height * 0.6,
                      color: Colors.white,
                      child: buildListView(goldList, "Gold List", true)),
                  Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      color: Colors.white,
                      child: buildListView(silverList, "Silver List", false)),
                  _goldOK
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.15),
                              width: double.infinity,
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                        color: Colors.white,
                                        child: Text(
                                          "Teams/Group in Silver",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: HexColor("#ea070a"),
                                          ),
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                  ),
                                  Container(
                                      height: 50,
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(3),
                                          border: Border.all(
                                              width: 1,
                                              color: HexColor("#ea070a"))),
                                      child: TextField(
                                          controller: _silverGroupController,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                              labelStyle: new TextStyle(
                                                  color: Colors.transparent)))),
                                ],
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.3,
                              width: double.infinity,
                              color: Colors.transparent,
                              child: Stack(
                                children: [
                                  ClipPath(
                                    clipper: ClippingClass(),
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.125,
                                      width: double.infinity,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.2,
                                      ),
                                      Center(
                                        child: RaisedButton(
                                          onPressed: () {
                                            setState(() {
                                              _isloading =true;
                                            });

                                            // If there is no value in the Textcontroller show error message.
                                            if (_silverGroupController
                                                .text.isEmpty) {
                                              noTeamsErrermsg();
                                              return;
                                            }

                                            teamsInSilverGroup = int.parse(
                                                _silverGroupController.text);

                                            createGoldMatches();
                                            createSilverMatches();
                                            startFinals();
                                            uploadFinalsSummaries();
                                            addGroupPhasePoints();

                                            _isloading=false;

                                            Navigator.of(context)
                                                .popAndPushNamed(
                                                    FinalsAdmin.link,
                                                    arguments: {
                                                  "matchProgress": gameName
                                                });
                                          },
                                          child: Text("Create Matches"),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        )
                      : Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "GOLD ERROR! Must be  2 - 4 - 8 or 16!",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                ],
              ),
            ),
    );
  }
}
