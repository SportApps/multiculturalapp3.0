import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:multiculturalapp/MyWidgets/TournamentInfoScr/tournamentinfo.dart';
import 'package:multiculturalapp/MyWidgets/progress.dart';
import 'package:multiculturalapp/MyWidgets/userInfoStartscreen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../whatsAppMessageBox.dart';

// 1.)Handle ParticipantList Container

handleParticipantListSnapshot(String tournamentId) {
  var querySnapshot = FirebaseFirestore.instance
      .collection("ourtournaments")
      .doc(tournamentId)
      .collection("participants")
      .where("hasTeam", isEqualTo: false)
      .snapshots();

  return querySnapshot;
}

class SignedUpGridview extends StatelessWidget {
  SignedUpGridview({this.isloading, this.tournamentId, this.isAdmin,this.organizerName,this.whatsAppNR, this.whatsAppNRformated,this.eventName,this.date,this.time,this.requestUserName});

  var tournamentinstance =
      FirebaseFirestore.instance.collection("ourtournaments");

  final bool isloading;

  final bool isAdmin;

  final String tournamentId;

  final String organizerName;

  final String eventName;

  final String date;

  final String time;

  final String requestUserName;

  final String whatsAppNR;

  final String whatsAppNRformated;




  bool _userPayed;

  String _userPayedString;

  String userId;

  String userName;

  String userPhoto;

  String userlvl;

  String userGamesWon;

  String userGamesLost;

  String userStrength;

  String userFlaws;

  String userBlockDefense;

  String userExpectations;

  String userPoints;

  var userWinLooseRatio;
  String userWinLooseRatioRounded;
  String userLikes;
  double advanceProcent;

  String clickedUser;

  Future<void> _makeWhatsappMessage(String number) async {
    if (await canLaunch("https://wa.me/${number}?text=Hello")) {
      if (Platform.isIOS) {
        return "whatsapp://wa.me/${number}?text=Hello $organizerName,%0a I would like to play with *$userName*. %0a Event: *$eventName*. %0a %0a UserName:%0a *$requestUserName*, %0a %0a date: *$date*, %0a %0a Hour: *$startingHour*, %0a %0a Looking forward to join u guys! %0a *$requestUserName*}";
      } else {
        await launch(
            "https://wa.me/${number}?text=Hello $organizerName,%0a I would like to play with *$userName*. %0a Event: *$eventName*. %0a %0a UserName:%0a *$requestUserName*, %0a %0a date: *$date*, %0a %0a Hour: *$startingHour*, %0a %0a Looking forward to join u guys! %0a *$requestUserName*");
      }
    }
  }


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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
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
                kickOutPlayer(
                    _loadeddataindexcontent.data()["userId"], context);
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
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

  kickOutPlayer(userId, context) async {
    //Is the user currently in a team?

    var userInfoSnap = await tournamentinstance
        .doc(tournamentId)
        .collection("participants")
        .doc(userId)
        .get();

    bool hasteam = userInfoSnap.data()["hasTeam"];

    if (hasteam) {
      couldntKickOut(context);
      return;
    }

    await tournamentinstance
        .doc(tournamentId)
        .collection("participants")
        .doc(userId)
        .delete();
  }

  getUserInfo(String clickedUser) async {
    var fireUser = await FirebaseFirestore.instance
        .collection("users")
        .doc(clickedUser)
        .get();

    userName = fireUser.data()["username"];
    userPhoto = fireUser.data()["photo_url"];
    userlvl = fireUser.data()["achievedlvl"];
    userStrength = fireUser.data()["myStrength"];
    userFlaws = fireUser.data()["myFlaws"];
    userBlockDefense = fireUser.data()["myBlockDefense"];
    userExpectations = fireUser.data()["myExpectations"];
    userPoints = fireUser.data()["points"].toString();
    userGamesWon = fireUser.data()["historyGamesWon"].toString();
    userGamesLost = fireUser.data()["historyGamesLost"].toString();
    userWinLooseRatio = fireUser.data()["winLooseRatio"];
    userWinLooseRatioRounded = userWinLooseRatio.toStringAsFixed(1);
    userLikes = fireUser.data()["likes"].toString();

    if (userlvl == "Baby Beginner") {
      advanceProcent = 0.125;
    } else if (userlvl == "Little Child") {
      advanceProcent = 0.25;
    } else if (userlvl == "Amateur") {
      advanceProcent = 0.5;
    } else if (userlvl == "Grown-Up") {
      advanceProcent = 0.6125;
    } else if (userlvl == "Experienced") {
      advanceProcent = 0.75;
    } else {
      advanceProcent = 1;
    }
  }

  Row createDescriptionAlertElement(
      IconData myicon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            margin: EdgeInsets.only(right: 19),
            width: 20,
            height: 20,
            child: Icon(
              myicon,
              size: 22,
            )),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: double.infinity,
                  child: Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text(description)),
            ],
          ),
        ),
      ],
    );
  }

  createInfoPlayerAlert(BuildContext context) {
    // flutter defined function
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return Scrollbar(
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            scrollable: true,
            contentPadding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: 10),
            title: Container(
              width: double.infinity,
              child: Column(
                children: [
                  Text(
                    "Meet",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15, color: Colors.black.withOpacity(0.8)),
                  ),
                  Text(
                    userName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20, color: Colors.black.withOpacity(0.8)),
                  ),
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
                              endColor: Colors.black,
                              progress: advanceProcent,
                              width: 10,
                            ),
                            size: Size(
                              MediaQuery.of(context).size.width * 0.36,
                              MediaQuery.of(context).size.width * 0.36,
                            )),
                        CircleAvatar(
                          backgroundImage: NetworkImage(userPhoto),
                          radius: MediaQuery.of(context).size.width * 0.15,
                        ),
                      ],
                    ),
                    Container(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          userlvl,
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black.withOpacity(0.6)),
                        )),
                    Container(
                        padding: EdgeInsets.only(top: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$userLikes Likes ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black.withOpacity(0.8)),
                            ),
                            Icon(
                              MdiIcons.heart,
                              color: Colors.black,
                            )
                          ],
                        )),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text("Ratios",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16))),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                padding: EdgeInsets.symmetric(vertical: 7),
                                child: Row(
                                  children: [
                                    Icon(MdiIcons.star,
                                        size: 25,
                                        color: Colors.black.withOpacity(0.6)),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text("Points:"),
                                  ],
                                )),
                            Container(
                                padding: EdgeInsets.symmetric(vertical: 7),
                                child: Row(
                                  children: [
                                    Icon(
                                      MdiIcons.chartLineVariant,
                                      size: 25,
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text("Win - Loose Ratio:"),
                                  ],
                                )),
                            Container(
                                padding: EdgeInsets.symmetric(vertical: 7),
                                child: Row(
                                  children: [
                                    Icon(MdiIcons.trophyAward,
                                        size: 25,
                                        color: Colors.black.withOpacity(0.6)),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text("Games Won:"),
                                  ],
                                )),
                            Container(
                                padding: EdgeInsets.symmetric(vertical: 7),
                                child: Row(
                                  children: [
                                    Icon(MdiIcons.thumbDownOutline,
                                        size: 25,
                                        color: Colors.black.withOpacity(0.6)),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text("Games Lost:"),
                                  ],
                                )),
                          ],
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.1,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 12,
                            ),
                            Container(
                                height: 40,
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Text(userPoints)),
                            Container(
                                height: 40,
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Text(userWinLooseRatioRounded)),
                            Container(
                                height: 40,
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Text(userGamesWon)),
                            Container(
                                height: 40,
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Text(userGamesLost)),
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Text("Description",
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        createDescriptionAlertElement(
                            MdiIcons.checkboxMarkedCircleOutline,
                            "Strength",
                            userStrength),
                        SizedBox(
                          height: 15,
                        ),
                        createDescriptionAlertElement(
                            MdiIcons.checkboxMarkedCircleOutline,
                            "Flaw",
                            userFlaws),
                        SizedBox(
                          height: 15,
                        ),
                        createDescriptionAlertElement(
                            MdiIcons.checkboxMarkedCircleOutline,
                            "Blocker or Defense",
                            userBlockDefense),
                        SizedBox(
                          height: 15,
                        ),
                        createDescriptionAlertElement(
                            MdiIcons.checkboxMarkedCircleOutline,
                            "Expectations",
                            userExpectations),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                    Container(
                        padding: EdgeInsets.only(top: 15),
                        width: double.infinity,
                        child: Text(
                          "Contact organizer to play with $userName",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              ),
                        )),
                    SizedBox(
                      height: 20,
                    ),
              WhatsappMessageBox(
                organizerName: organizerName,
                whatsAppNR: whatsAppNR,
                whatsAppNRFormated: whatsAppNRformated,
                createWhatsappMessage: _makeWhatsappMessage,
              ),

                    SizedBox(
                      height: 20,
                    ),
                    FlatButton(
                      child: Text("Close",style: TextStyle(color:HexColor("4CAF50")),),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  dynamic _buildImage(String imagelink) {
    try {
      return FadeInImage.assetNetwork(
          fit: BoxFit.cover,
          width: 78,
          height: 78,
          fadeInDuration: Duration(seconds: 1),
          placeholder: 'assets/images/volleychild.png',
          imageErrorBuilder: (context, url, error) =>
              new Image.asset("assets/images/volleychild.png"),
          image: imagelink);
    } catch (e) {
      return Icon(Icons.error);
    }
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Participants without partner",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.8),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Choose your partner!",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                  ],
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
                              "All registered participants have a partner.",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.8),
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 25),
                              child: Text(
                                "Make yourself visible by clicing the participation buttom on the top!.",
                                textAlign: TextAlign.center,
                              ),
                            ),
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
                              onTap: () async {
                                clickedUser = _loadeddataindexcontent.id;
                                await getUserInfo(clickedUser);
                                createInfoPlayerAlert(context);
                              },
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
                                        ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(40.0),
                                            child: _buildImage(
                                              _loadeddataindexcontent
                                                  .data()["photoUrl"],
                                            ))
                                      ],
                                    ),
                                    Text(
                                      _loadeddataindexcontent
                                          .data()["username"],
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
