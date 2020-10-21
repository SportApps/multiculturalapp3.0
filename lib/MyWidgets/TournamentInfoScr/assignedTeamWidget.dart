import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:multiculturalapp/Screens/TournOnScreen.dart';

import '../clippingClass.dart';


class AssignedTeamWidget extends StatefulWidget {

  AssignedTeamWidget({this.googleName,this.tournamentId,this.context});


  final String googleName;

  final String tournamentId;

  final BuildContext context;



  @override
  _AssignedTeamWidgetState createState() => _AssignedTeamWidgetState();
}

class _AssignedTeamWidgetState extends State<AssignedTeamWidget> {
  var tournamentinstance =
  FirebaseFirestore.instance.collection("ourtournaments");
  bool _notStarted;
  void checkTournamentStarts() async {
    tournamentinstance
        .doc(widget.tournamentId)
        .collection("Status")
        .doc("Beginn")
        .get()
        .then(
          (doc) {
        if (doc.exists) {
          Navigator.of(context).popAndPushNamed(TournOnScreen.link);
        } else {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("We are setting up the teams :)"),
            duration: Duration(seconds: 2),
          ));

          setState(() {
            _notStarted = true;
          });
        }
      },
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    _notStarted =false;


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HexColor("#ffe664"),
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Container(

              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Column(children: <Widget>[

                Text(
                  widget.googleName,
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.8),
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "You found a partner!",
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.8),
                      fontSize: 20),
                ),
                Text(
                  "Remember to arrive on time!!",
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.8),
                      fontSize: 20),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.all(Radius.circular(5)),
                      border: Border.all(
                          width: 1, color: HexColor("#ea070a"))),
                  child: RaisedButton(
                    elevation: 0,
                    color: Colors.white,
                    onPressed: () {
                      checkTournamentStarts();
                    },
                    child: Text(
                      "Get started",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: HexColor("#ea070a").withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
                _notStarted
                    ? Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    CircularProgressIndicator(
                        backgroundColor: HexColor("#ea070a")
                            .withOpacity(0.8)),
                    Container(
                      margin: EdgeInsets.only(top: 25),
                      width: 200,
                      child: Text(
                        "Waiting for other teams. Please try again when the tournament started.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w300,
                            color: HexColor("#ea070a")
                                .withOpacity(0.8)),
                      ),
                    ),
                    SizedBox(height: 20,)
                  ],
                )
                    : SizedBox(height: 20)
              ])),

        ],
      ),
    );
  }
}
