import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:multiculturalapp/MyWidgets/TournamentInfoScr/addCountry.dart';

import 'package:multiculturalapp/Screens/CreateTeamsScreen.dart';

import 'package:multiculturalapp/Screens/TournOnScreen.dart';
import 'package:multiculturalapp/Screens/home.dart';
import 'package:multiculturalapp/Screens/tournamentinfoscreen.dart';
import 'package:multiculturalapp/model/tournaments.dart';

import '../clippingClass.dart';
import '../progress.dart';

var teamInfoFirestore = FirebaseFirestore.instance.collection("ourtournaments");

var tournamentInstance =
    FirebaseFirestore.instance.collection("ourtournaments");
var total;

double teamsPerGroup;

class Teamoverview extends StatefulWidget {
  static const link = "/teamoverview";

  @override
  _TeamoverviewState createState() => _TeamoverviewState();
}

class _TeamoverviewState extends State<Teamoverview> {
  static GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String tournamentId;
  var _loadedDataIndex;

  // set up the AlertDialog
  showAlertDialogStart(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Continue"),
      onPressed: () {
        startTournament();
        Navigator.of(context).popAndPushNamed(TournOnScreen.link,
            arguments: {"tournamentID": tournamentId});
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Start Tournament"),
      content: Text(
          "Are you sure? The matches will be created and our athlets will be able to access the Group Phase.?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //DELETE TEAM FROM TOURNAMENT
  borrowCountryParticipant(String tournamentId, String CountryName) async {
    var player1NR;
    var player2NR;
    // Step 1
    // The player of the Team are not in a Team anymore.
    //1.1) Find player IDs in Country Subcollection
    await teamInfoFirestore
        .doc(tournamentId)
        .collection("countries")
        .doc(CountryName)
        .get()
        .then((CountrySnapshot) {
      player1NR = CountrySnapshot.data()["player1ID"];
      player2NR = CountrySnapshot.data()["player2ID"];

      //1.2) Change "hasTeam" field to false.
      // Player 1
      tournamentInstance
          .doc(tournamentId)
          .collection("participants")
          .doc(player1NR)
          .update({"hasTeam": false});
      // Player 2
      tournamentInstance
          .doc(tournamentId)
          .collection("participants")
          .doc(player2NR)
          .update({"hasTeam": false});
    });
    // Step 2
    // Delete the Team from the Countries DB.

    await teamInfoFirestore
        .doc(tournamentId)
        .collection("countries")
        .doc(CountryName)
        .delete();
  }

  // 3.) Start Tournament

  void startTournament() async {
    await tournamentInstance
        .doc(tournamentId)
        .collection("Status")
        .doc("Beginn")
        .set({"Beginn": true});
  }

// 4.) Build AppBAr
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
            "Team Overview",
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

  @override
  Widget build(BuildContext context) {
    // This is the listener for USER DATA
    //By Adding the <> GENETIC DATA we indicate which Provider we listen to.
    final tournamentData = Provider.of<Tournaments>(context, listen: true);
    // here we access the data from the listener.
    final currentTournament = tournamentData.item;
    tournamentId = currentTournament[0].tournamentid;

    return Scaffold(
        body: Container(
      width: double.infinity,
      color: HexColor("#ffe664"),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          appBarbuilder(),
          Container(
            height: MediaQuery.of(context).size.height * 0.55,
            width: double.infinity,
            child: StreamBuilder(
              stream: teamInfoFirestore
                  .doc(tournamentId)
                  .collection("countries")
                  .snapshots(),
              builder: (context, tsnapshot) {
                if (tsnapshot.connectionState == ConnectionState.waiting) {
                  return circularProgress();
                }

                //Data Snapshot
                var _loadeddata = tsnapshot.data.documents;
                total = tsnapshot.data.documents.length;
                String totalasString = total.toString();
                return Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.1,
                      color: Colors.white,
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.05),
                      child: Text(
                        "Teams: $totalasString ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(0.8)),
                      ),
                    ),
                    ClipPath(
                      clipper: ClippingClass(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        color: Colors.white,
                        child: ListView.builder(
                          itemCount: total,
                          itemBuilder: (BuildContext context, int i) {
                            _loadedDataIndex = _loadeddata[i];
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.05,
                                vertical:
                                    MediaQuery.of(context).size.height * 0.01,
                              ),
                              child: Dismissible(
                                key: ValueKey(TimeOfDay.now()),
                                onDismissed: (direction) {
                                  borrowCountryParticipant(tournamentId,
                                      _loadedDataIndex.data()["CountryName"]);
                                  setState(() {
                                    tsnapshot.data.documents.removeAt(i);
                                  });
                                },
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Theme.of(context).errorColor,
                                  child: Icon(Icons.delete,
                                      color: Colors.white, size: 40),
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Colors.black45),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(11.0))),
                                  height: 70,
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Container(
                                        height: 50,
                                        width: 70,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 0,
                                                blurRadius: 4,
                                                offset: Offset(0,
                                                    3), // changes position of shadow
                                              ),
                                            ],
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  _loadedDataIndex
                                                      .data()["CountryURL"]),
                                            )),
                                      ),
                                      SizedBox(
                                        width: 60,
                                      ),
                                      Text(
                                        _loadedDataIndex.data()["CountryName"],
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
              width: double.infinity,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.width * 0.05,
              ),
              child: Text(
                "3 Steps to start",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.8),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )),
          Row(
            children: <Widget>[
              Container(
                  width: MediaQuery.of(context).size.width * 0.65,
                  margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.05),
                  child: Text(
                    "Step`1: Add new Teams",
                    style: TextStyle(fontSize: 18),
                  )),
              RaisedButton(
                child: Text("Add"),
                padding: EdgeInsets.only(left: 10, right: 10),
                onPressed: () {
                  Navigator.of(context).pushNamed(addCountry.link,
                      arguments: {"tournamentID": tournamentId});
                },
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              Container(
                  width: MediaQuery.of(context).size.width * 0.65,
                  margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.05),
                  child: Text(
                    "Step`2: Create Groups",
                    style: TextStyle(
                        fontSize: 18, color: Colors.black.withOpacity(0.8)),
                  )),
              RaisedButton(
                  child: Text("Groups"),
                  onPressed: () {
                    Navigator.of(context).popAndPushNamed(CreateTeamScreen.link,
                        arguments: {"totalTeams": total});
                  }),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              Container(
                  width: MediaQuery.of(context).size.width * 0.65,
                  margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.05),
                  child: Text(
                    "Step`3: Confirm and Start",
                    style: TextStyle(
                        fontSize: 18, color: Colors.black.withOpacity(0.8)),
                  )),
              RaisedButton(
                child: Text("Start"),
                onPressed: () {
                  // show the dialog
                  showAlertDialogStart(context);
                },
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
