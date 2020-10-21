import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:multiculturalapp/MyWidgets/TournamentInfoScr/teamoverview.dart';
import 'package:provider/provider.dart';
import 'package:multiculturalapp/model/tournaments.dart';

var tournamentInstance = Firestore.instance.collection("ourtournaments");

int teamsPerGroup;
double groups;

int roundedGroups;
int Mannschaften;
List groupChunk = [];
Map<int, dynamic> groupChunkMap = {};
String tournamentId;

class CreateTeamScreen extends StatefulWidget {
  @override
  _CreateTeamScreenState createState() => _CreateTeamScreenState();

  static const link = "/createTeamScreen";
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  @override
  void initState() {
    // TODO: implement initState

    groups = 1;

    super.initState();
  }

  void calculateGroupSize(String totalTeams, String textInput) {
    setState(() {
      Mannschaften = int.parse(totalTeams);
      teamsPerGroup = int.parse(textInput);
      groups = double.parse(totalTeams) / teamsPerGroup;
      roundedGroups = groups.floor();
    });
  }

  void createTeams(BuildContext context) async {
    // Bugfix 11.10.2020 - if you introduce 4 teamspergroup on 11 teams it creates only 2 groups which doesnt work... So in this case we reduce teams per group to 3.
    if (Mannschaften == 11 && teamsPerGroup == 4) {
      // Bugfix 11.10.2020 activated. Teamspergroup are reduced to 3.
      teamsPerGroup = 3;
    }

    else if (Mannschaften == 14 && teamsPerGroup == 5) {teamsPerGroup = 4;}
    else if (Mannschaften == 17 && teamsPerGroup == 6) {teamsPerGroup = 5;}

    groupChunk = [];
    // STEP 1 - Get all registered teams and store tem in the tournamentIDList
    List tournamentIds = [];
    QuerySnapshot querySnapshot = await tournamentInstance
        .doc(tournamentId)
        .collection("countries")
        .get();
    var docs = await querySnapshot.docs;

    int recentGroupnumber = 0;
    int recentTeam = 0;

    for (int i = 0; i < docs.length; i++) {
      var a = docs[i];
      tournamentIds.add(a.id);
    }

    // Step 2: Check if we can make even groups.
    bool isIntegral(num groups) =>
        groups is int || groups.truncateToDouble() == groups;
    // Check if groups -1 is Integral --> There is 1 team too much.
    double groupsMinus1 = (Mannschaften - 1) / teamsPerGroup;

    bool isMinus1Integral(num groupsMinus1) =>
        groupsMinus1 is int || groupsMinus1.truncateToDouble() == groupsMinus1;

    // Check if groups -2 is Integral.
    double groupsMinus2 = (Mannschaften - 2) / teamsPerGroup;
    print("Mannschaften are $Mannschaften and $teamsPerGroup");
    bool isMinus2Integral(num groupsMinus2) =>
        groupsMinus2 is int || groupsMinus2.truncateToDouble() == groupsMinus2;

    // Check if groups -3 is Integral.
    double groupsMinus3 = (Mannschaften - 3) / teamsPerGroup;

    bool isMinus3Integral(num groupsMinus3) =>
        groupsMinus3 is int || groupsMinus3.truncateToDouble() == groupsMinus3;

    // Step 3 Locally create groups in List.
    // Case 1: We have an even group size.
    if (isIntegral(groups)) {
      for (int i = 0; i < groups; i++) {
        groupChunk.add(tournamentIds.sublist(
          recentTeam,
          recentTeam + teamsPerGroup,
        ));

        recentGroupnumber = recentGroupnumber + 1;
        recentTeam = recentTeam + teamsPerGroup;

      }
    }
// Case 2: Resting one team we have an even group size.
    else if (isMinus1Integral(groupsMinus1)) {
      print("Case 2 --> Groups-1");

      for (int i = 0; i < groupsMinus1; i++) {
        groupChunk.add(tournamentIds.sublist(
          recentTeam,
          recentTeam + teamsPerGroup,
        ));

        recentGroupnumber = recentGroupnumber + 1;
        recentTeam = recentTeam + teamsPerGroup;
      }
      recentGroupnumber--;

      print("The recent Team is $recentTeam");

      groupChunk[recentGroupnumber].insert(
          groupChunk[recentGroupnumber].length - 1,
          tournamentIds.elementAt(recentTeam));
    }
    // Case 3: Resting two team we have an even group size.
    else if (isMinus2Integral(groupsMinus2)) {
      print("Case 3 --> Groups-2");

      for (int i = 0; i < groupsMinus2; i++) {
        groupChunk.add(tournamentIds.sublist(
          recentTeam,
          recentTeam + teamsPerGroup,
        ));

        recentGroupnumber = recentGroupnumber + 1;
        recentTeam = recentTeam + teamsPerGroup;
        print(groupChunk);
      }
      // Add the rest of the teams (2 teams left because of uneven team numbers.
      // Here we add the first team to the last group.
      recentGroupnumber--;

      print("The recent Team is $recentTeam");
      print(recentGroupnumber);
      groupChunk[recentGroupnumber].insert(
          groupChunk[recentGroupnumber].length - 1,
          tournamentIds.elementAt(recentTeam));

      // Here we add the second team the second last group.
      recentGroupnumber--;
      recentTeam++;
      print("The recent Team is $recentTeam");
      print(recentGroupnumber);
      groupChunk[recentGroupnumber].insert(
          groupChunk[recentGroupnumber].length - 1,
          tournamentIds.elementAt(recentTeam));
    }

    // Case 4: Resting two team we have an even group size.
    else if (isMinus3Integral(groupsMinus3)) {
      print("Case 4 --> Groups-3");

      print(groupsMinus3);
      for (int i = 0; i < groupsMinus3; i++) {
        print(recentGroupnumber);
        print("Here the groupchunk is $groupChunk");
        groupChunk.add(tournamentIds.sublist(
          recentTeam,
          recentTeam + teamsPerGroup,
        ));

        recentGroupnumber = recentGroupnumber + 1;
        recentTeam = recentTeam + teamsPerGroup;
      }
      // Add the rest of the teams (2 teams left because of uneven team numbers.
      // Here we add the first team to the last group.
      recentGroupnumber--;
      print("the recentGroupnumber here is $recentGroupnumber");
      groupChunk[recentGroupnumber].insert(
          groupChunk[recentGroupnumber].length - 1,
          tournamentIds.elementAt(recentTeam));

      // Here we add the second team the second last group.
      recentGroupnumber--;
      recentTeam++;
      print("The $recentTeam is the recentTeam");
      groupChunk[recentGroupnumber].insert(
          groupChunk[recentGroupnumber].length - 1,
          tournamentIds.elementAt(recentTeam));

      // Here we add the third team the second last group.
      recentGroupnumber--;
      recentTeam++;
      print("The $recentTeam is the recentTeam now");
      print(groupChunk);
      print(recentGroupnumber);
      groupChunk[recentGroupnumber].insert(
          groupChunk[recentGroupnumber].length - 1,
          tournamentIds.elementAt(recentTeam));
    } else {
      // THIS SHOULDNT HAPPEN ONLY IF THERE ARE MORE THEN 4 TEAMS OUT
      print(groupsMinus1);
      print("Group size is not an even number.");
    }

// Step 4: Preparing the upload by converting the Nested List into a Map and giving each Entry a GroupNumber.
    int currentGruppenNr = 1;
    int Laenge = groupChunk.length.floor();
    for (var ii = 0; ii < Laenge; ii++) {
      groupChunkMap.addAll({currentGruppenNr: groupChunk[ii]});
      currentGruppenNr++;
    }
    print("This is our GroupChunkmap $groupChunkMap");

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

    // Step 4.2 Have a Map of countries with a List of all their games.
    // RESULT IS THE GAMEMAP which shows for each team which matches they have.

    var currentCountryNumber;
    var currentTeam = 0;
    String aktuellesSpiel;
    List spielList = [];
    Map gameMap = {};

    for (var aa = 0; aa < tournamentIds.length; aa++) {
      currentCountryNumber = 0;
      for (var a = 0; a < currentGameList.length; a++) {
        aktuellesSpiel = currentGameList[currentCountryNumber];

        if (aktuellesSpiel.contains(tournamentIds[currentTeam])) {
          spielList.add(aktuellesSpiel);
        }

        currentCountryNumber++;

        gameMap.putIfAbsent(tournamentIds[currentTeam], () => spielList);
      }

      spielList = [];
      currentTeam++;
    }

    // Step 4.3 Upload this map to Firestore so we can see for each country which matches they will have in the group phase.

    var toUploadCountryIndex = 0;
    String toUploadCountry;
    String uploadMatch;
    var matchIndex;
    var quantityTeams = tournamentIds.length;
    // In the Outside Loop, we go through all the Countries that signed up for the tournament (e.g.20)
    for (var b = 0; b < quantityTeams; b++) {
      // We take one tournamentParticipant (coutnry, at a time)
      toUploadCountry = tournamentIds[toUploadCountryIndex];
      print("This is the $gameMap");
      var quantityGamesofPatricpant = gameMap[toUploadCountry].length;
      print(quantityGamesofPatricpant);

      matchIndex = 0;
      for (var c = 0; c < quantityGamesofPatricpant; c++) {
        uploadMatch = gameMap[toUploadCountry][matchIndex];

        // Here we get the Country names involved in the Match
        var Team1;
        var Team2;

        List<String> matchElements = uploadMatch.split(' ');

        Team1 = matchElements[0];
        Team2 = matchElements[2];

        // Upload the match
        await tournamentInstance
            .doc(tournamentId)
            .collection("countries")
            .doc(toUploadCountry)
            .collection("Results")
            .doc(uploadMatch)
            .set({
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

    //Step 5: Uploading the list.
    // We use a nested FOR Loop
    // Instance 1 --> For each Group we create a SubList called currentGroup using the currentGrouppeNr as Key.
    currentGruppenNr = 1;
    var groupName;
    var NR;
    for (var iii = 0; iii < Laenge; iii++) {
      groupName = currentGruppenNr.toString();

      print(groupChunkMap[currentGruppenNr]);
      List<dynamic> currentGroup = groupChunkMap[currentGruppenNr];
      currentGruppenNr++;
// Instance 2: For each Country in the Group we create a String and add it to the Group.
      NR = 0;

      print(groupName);
      // TEST
      tournamentInstance
          .doc(tournamentId)
          .collection("Groups")
          .doc(groupName)
          .set({"TestData": "Test"}, SetOptions(merge: true));

      for (var iiii = 0; iiii < currentGroup.length; iiii++) {
        String addCountrytoGroup = currentGroup[NR];

        // Here we create the Group Collection entry in Firstore

        tournamentInstance
            .doc(tournamentId)
            .collection("Groups")
            .doc(groupName)
            .collection("Countries")
            .doc(addCountrytoGroup)
            .set({"country": addCountrytoGroup}, SetOptions(merge: true));

        // Here we add the current Group Number to the Country Document.
        tournamentInstance
            .doc(tournamentId)
            .collection("countries")
            .doc(addCountrytoGroup)
            .set({
          "groupNumber": groupName,
        }, SetOptions(merge: true));

        NR++;

        print("Write complete $NR");
      }

    }
 
  }

  var groupController = TextEditingController();

  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    groupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This is the listener for USER DATA
    //By Adding the <> GENETIC DATA we indicate which Provider we listen to.
    final tournamentData = Provider.of<Tournaments>(context, listen: true);
    // here we access the data from the listener.
    final currentTournament = tournamentData.item;
    tournamentId = currentTournament[0].tournamentid;

    final routeargs =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;

    final totalTeams = routeargs["totalTeams"].toString();
    return Scaffold(
        appBar: AppBar(
          title: Text("Create Groups"),
          backgroundColor: HexColor("#ffe664"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height * 1,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height * 0.1,
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            "Total Teams:",
                            style: TextStyle(
                                fontSize: 20,
                                color: HexColor("#ea070a").withOpacity(0.8),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.1,
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            "How many teams/group?",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.1,
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            "How many Groups?",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: MediaQuery.of(context).size.height * 0.1,
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: Text(
                              totalTeams,
                              style: TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.1,
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: TextFormField(
                              onChanged: (text) {
                                calculateGroupSize(totalTeams, text);
                              },
                              controller: groupController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.1,
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: Text(
                              groups.toString(),
                              style: TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Builder(
                  builder: (context) => RaisedButton(
                    child: Text("Create Teams"),
                    onPressed: () {
                      createTeams(context);
                      Navigator.of(context).popAndPushNamed(Teamoverview.link);
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
