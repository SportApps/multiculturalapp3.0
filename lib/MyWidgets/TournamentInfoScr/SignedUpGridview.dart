

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:multiculturalapp/MyWidgets/userInfoStartscreen.dart';
import '../SignedUpGridviewElement.dart';
import 'package:multiculturalapp/MyWidgets/progress.dart';

// 1.)Handle ParticipantList Container

handleParticipantListSnapshot(String tournamentId) {
  var querySnapshot = FirebaseFirestore.instance
      .collection("ourtournaments")
      .doc(tournamentId)
      .collection("participants")
      .snapshots();

  return querySnapshot;
}

class SignedUpGridview extends StatelessWidget {
  SignedUpGridview({this.isloading, this.tournamentId, this.isAdmin});

  var tournamentinstance =
      FirebaseFirestore.instance.collection("ourtournaments");

  final bool isloading;

  final bool isAdmin;

  final String tournamentId;

  bool _userPayed;

  String _userPayedString;

  userPayedFunction(var _loadeddataindexcontent) async {
    _userPayed = !_userPayed;

    print(_userPayed);
    String userId;

    userId = await _loadeddataindexcontent.data()["userId"];

    tournamentinstance
        .doc(tournamentId)
        .collection("participants")
        .doc(userId)
        .update(
      {
        "paymentStatus": _userPayed,
      },
    );
  }

  void kickoutDialog(BuildContext context, var _loadeddataindexcontent) {
    // flutter defined function

    showDialog(
      context: context,
      builder: (context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Borrow player?"),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Are you sure that you want to eliminate this player?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Confirm"),
              onPressed: () {
                kickOutPlayer(_loadeddataindexcontent.data()["userId"],context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void couldntKickOut(BuildContext context) {
    // flutter defined function

    showDialog(
      context: context,
      builder: (context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Did not work"),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "The athlet is asigned to a team. Please delete the team first.",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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



  kickOutPlayer(userId,context) async {

    //Is the user currently in a team?

   var userInfoSnap = await tournamentinstance
        .doc(tournamentId)
        .collection("participants")
        .doc(userId).get();

    bool hasteam = userInfoSnap.data()["hasTeam"];


    if (hasteam){

      couldntKickOut(context);
      return;

    }

    await tournamentinstance
        .doc(tournamentId)
        .collection("participants")
        .doc(userId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HexColor("#ffe664"),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 30,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            child: Row(
              children: [
                Icon(
                  MdiIcons.genderMaleFemale,
                  size: 30,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Participants",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.8),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          isloading
              ? circularProgress()
              : Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  height: 170,
                  color: Colors.white.withOpacity(0.7),
                  width: double.infinity,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: handleParticipantListSnapshot(tournamentId),
                    builder: (context, participantssnapshot) {
                      if (participantssnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return circularProgress();
                      } else if (participantssnapshot.data.size == 0) {
                        return Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "No athlet registered yet",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.8),
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                                "To join clic the participation buttom on the top!."),
                          ],
                        ));
                      } else {
                        var _loadeddata = participantssnapshot.data.docs;

                        return GridView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _loadeddata.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1, childAspectRatio: 1.25),
                          itemBuilder: (context, index) {
                            var _loadeddataindexcontent = _loadeddata[index];
                            double advanceProcent;

                            if (_loadeddataindexcontent.data()["achievedlvl"] ==
                                "Baby Beginner") {
                              advanceProcent = 0.125;
                            } else if (_loadeddataindexcontent
                                    .data()["achievedlvl"] ==
                                "Little Child") {
                              advanceProcent = 0.25;
                            } else if (_loadeddataindexcontent
                                    .data()["achievedlvl"] ==
                                "Amateur") {
                              advanceProcent = 0.5;
                            } else if (_loadeddataindexcontent
                                    .data()["achievedlvl"] ==
                                "Grown-Up") {
                              advanceProcent = 0.6125;
                            } else if (_loadeddataindexcontent
                                    .data()["achievedlvl"] ==
                                "Experienced") {
                              advanceProcent = 0.75;
                            } else {
                              advanceProcent = 1;
                            }

                            _userPayed =
                                _loadeddataindexcontent.data()["paymentStatus"];

                            if (_userPayed) {
                              _userPayedString = "Payment Confirmed";
                            } else {
                              _userPayedString = "Due for payment";
                            }

                            return InkWell(
                              onDoubleTap: () {
                                if (isAdmin) {
                                  print("You are an admin!");
                                  userPayedFunction(_loadeddataindexcontent);
                                }
                              },
                              onLongPress: () {
                                if (isAdmin) {
                                  print("You are an admin!");
                                  kickoutDialog(
                                      context, _loadeddataindexcontent);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.only(top: 5),
                                child: Column(
                                  children: <Widget>[
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CustomPaint(
                                          painter: GradientArcPainter(
                                            startColor: HexColor("#ffde03"),
                                            endColor: Colors.red,
                                            progress: advanceProcent,
                                            width: 8,
                                          ),
                                          size: Size(95, 95),
                                        ),
                                        CircleAvatar(
                                          radius: 40,
                                          backgroundImage: NetworkImage(
                                              _loadeddataindexcontent
                                                  .data()["photoUrl"]),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      _loadeddataindexcontent
                                          .data()["googleName"],
                                      style: TextStyle(fontSize: 20),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      _loadeddataindexcontent
                                          .data()["achievedlvl"],
                                      style: TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      _userPayedString,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          color: _userPayed
                                              ? Colors.green.withOpacity(0.8)
                                              : Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
