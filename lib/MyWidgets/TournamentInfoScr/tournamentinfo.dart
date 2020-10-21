import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:multiculturalapp/MyWidgets/TournamentInfoScr/assignedTeamWidget.dart';
import 'package:multiculturalapp/MyWidgets/TournamentInfoScr/signedUpTeamsGridview.dart';
import 'package:provider/provider.dart';

import 'package:multiculturalapp/MyWidgets/TournamentInfoScr/teamoverview.dart';

import 'package:multiculturalapp/MyWidgets/progress.dart';
import 'package:multiculturalapp/MyWidgets/TournamentInfoScr/SignedUpGridview.dart';
import 'package:multiculturalapp/Screens/Final/FinalsAdmin.dart';
import 'package:multiculturalapp/Screens/addTournamentScreen.dart';
import 'package:multiculturalapp/Screens/home.dart';
import '../clippingClass.dart';

import 'package:multiculturalapp/Screens/TournOnScreen.dart';
import 'package:multiculturalapp/model/tournaments.dart';
import 'package:multiculturalapp/model/users.dart';

bool _isgoing;
bool _isAdmin;
bool _isEventOrg;

bool _isloading = false;
bool userHasTeam;
bool _userhasPayed;
bool reservationBlocked;
bool reservationMaleBlocked;
bool reservationFemaleBlocked;

bool _notStarted;
bool _isMale;
bool _isFemale;
bool _isMixt;
bool _isOpenSex;

int maxParticipants;
int maxGenderParticipants;

int totalParticipants;
int totalMaleParticipants;
int totalFemaleParticipants;

int remainingSpots;
int remainingMaleSpots;
int remainingFemaleSports;

String lvl;
String achievedlvl;
String ranking;
String points;
String genderOnly;
String tournamentId;
String userId;
String userName;
String photoUrl;
String googleName;
String date;
String startingHour;
String finishHour;
String niveles;
String location;
String price;
String description;
String organizerName;
String whatsAppNR;
String myGender;
String reservationDeniedString;

var tournamentinstance =
    FirebaseFirestore.instance.collection("ourtournaments");
var userInstance = FirebaseFirestore.instance.collection("users");

//Inedex

// 1.)buildContainer for titleText

// 2.) Function setExtraPlayerData to get players Level

// 3.) _eventFullDialog which appears to user if Event is full

// 4.) chekisAdmin Function to see if User is an Admin.

// 5.) handleDocExist function to check if user is already signed in the event. in.

// 6.) checkHasTeam Function to see if User already has a Team.

// 7.) checkTournamentStarts to see if Tournament already started.

//1.) buildContainer for titleText
Container buildContainer(Icon Icontype, String titleText, double containerhight,
    BuildContext context) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: <Widget>[
        SizedBox(width: 20),
        Icontype,
        SizedBox(
          width: 10,
        ),
        Container(
          height: containerhight,
          child: Text(
            titleText,
            style:
                TextStyle(fontSize: 18, color: Colors.black.withOpacity(0.8)),
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
          ),
        ),
      ],
    ),
  );
}

// 2.) Function setExtraPlayerData to get players Level
Future setExtraPlayerData(String userId) async {
  userInstance
      .doc(userId)
      .get()
      .then(
        (docData) => {
          if (docData.exists)
            {
              lvl = docData.data()["lvl"],

              // document exists (online/offline)
            }
          else
            {
              print("User Document does not exist"),

              // document does not exist (only on online)
            }
        },
      )
      .catchError(
        (fail) => {
          print(fail)
          // Either
          // 1. failed to read due to some reason such as permission denied ( online )
          // 2. failed because document does not exists on local storage ( offline )
        },
      );
}

class Tournamentinfo extends StatefulWidget {
  @override
  _TournamentinfoState createState() => _TournamentinfoState();
}

class _TournamentinfoState extends State<Tournamentinfo> {
  // 3.) _eventFullDialog which appears to user if Event is full
  void _eventFullDialog() {
    // flutter defined function

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Reservation not possible"),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  reservationDeniedString,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                _isMixt
                    ? Column(
                        children: [
                          Text(
                              "Males ($totalMaleParticipants / $maxGenderParticipants)"),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                              "Females ($totalFemaleParticipants / $maxGenderParticipants)"),
                        ],
                      )
                    : Text("Maximum Participants: $maxParticipants"),
                SizedBox(
                  height: 5,
                ),
                Text("Please try again later."),
              ],
            ),
          ),
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

  // 3.) _eventFullDialog which appears when the user reserves and comes for the first time.
  void welcomeDialog() {
    // flutter defined function

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("You´re going!!"),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  child: Text("Next Steps"),
                ),
                SizedBox(
                  height: 5,
                ),
                Text("Whatsapp the organizer"),
                Text("$organizerName: $whatsAppNR"),
                Text("Secure your place by paying in advance."),
              ],
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // 4.) chekisAdmin Function to see if User is an Admin.
  checkIsAdmin() async {
    var userFire = await userInstance.doc(userId).get();

    String lvl = userFire.data()["lvl"];

    if (lvl == "Admin") {
      _isAdmin = true;
      userName = userFire.data()["displayName"];

      print(userName);
      print(organizerName);
      if (organizerName == userName) {
        _isEventOrg = true;
        print("We are event organizer");
      }
    }
  }

  // 5.) handleDocExist function to check if user is already signed in the event. in.

  Future handleDocExist(String tournamentId, String userId) {
    tournamentinstance
        .doc(tournamentId)
        .collection("participants")
        .doc(userId)
        .get()
        .then(
          (docData) => {
            if (docData.exists)
              {
                _isgoing = true,
              }
            else
              {
                _isgoing = false,
                _isloading = false,
              }
          },
        )
        .then((value) {
      checkHasTeam(tournamentId, userId);
    }).then((value) {
      setState(() {
        _isloading = false;
        print(userHasTeam);
      });
    }).catchError(
      (fail) => {
        print(fail)
        // Either
        // 1. failed to read due to some reason such as permission denied ( online )
        // 2. failed because document does not exists on local storage ( offline )
      },
    );
  }

  // 6.) checkHasTeam Function to see if User already has a Team.
  checkHasTeam(String tournamentID, String myUserId) async {
    if (_isgoing == true) {
      await tournamentinstance
          .doc(tournamentID)
          .collection("participants")
          .doc(userId)
          .get()
          .then((participantdata) {
        if (participantdata.data()["paymentStatus"] == true) {
          _userhasPayed = true;
        } else {
          _userhasPayed = false;
        }

        if (participantdata.data()["hasTeam"] == true) {
          setState(() {
            userHasTeam = true;
          });
        } else {
          setState(() {
            userHasTeam = false;
          });
        }
      });
    }
  }

  // 8.) checkGameStatus Function to redirect the user to the FinalsAdmin or Teamoverview screen depending on the Games Advance.
  void checkGameStatus() async {
    tournamentinstance
        .doc(tournamentId)
        .collection("Status")
        .doc("Finals")
        .get()
        .then(
      (doc) {
        if (doc.exists) {
          Navigator.of(context).popAndPushNamed(FinalsAdmin.link);
        } else {
          Navigator.of(context).pushNamed(Teamoverview.link,
              arguments: {"tournamentId": tournamentId});
        }
      },
    );
  }

  checkBlockReservation() async {
    // First we check if you are of the right Sex.

    if (_isMale && myGender == "Female") {
      reservationBlocked = true;
      reservationDeniedString = "This is a Male Tournament.";
      return;
    }

    if (_isFemale && myGender == "Male") {
      reservationBlocked = true;
      reservationDeniedString = "This is a Female Tournament.";
      return;
    }

    // Then we check if the tournament is already full.

    if (_isMale || _isFemale || _isOpenSex) {
      var FireParticipants = await tournamentinstance
          .doc(tournamentId)
          .collection("participants")
          .get();

      totalParticipants = FireParticipants.docs.length;

      remainingSpots = maxParticipants - totalParticipants;
      if (remainingSpots <= 0 && _isgoing == false) {
        reservationBlocked = true;
        reservationDeniedString = "The tournament is full.";
        return;
      }
    } else if (_isMixt) {
      var fireMaleParticipants = await tournamentinstance
          .doc(tournamentId)
          .collection("participants")
          .where("gender", isEqualTo: "Male")
          .get();

      var fireFemaleParticipants = await tournamentinstance
          .doc(tournamentId)
          .collection("participants")
          .where("gender", isEqualTo: "Female")
          .get();

      totalMaleParticipants = fireMaleParticipants.docs.length;
      totalFemaleParticipants = fireFemaleParticipants.docs.length;

      remainingMaleSpots = maxGenderParticipants - totalMaleParticipants;

      remainingFemaleSports = maxGenderParticipants - totalFemaleParticipants;
      print("These are the remainingFemaleSpots $remainingFemaleSports");

      if (remainingMaleSpots <= 0 && _isgoing == false && myGender == "Male") {
        reservationBlocked = true;
        reservationDeniedString = "There are no more Male Spots available.";
        return;
      }

      if (remainingFemaleSports <= 0 &&
          _isgoing == false &&
          myGender == "Female") {
        reservationBlocked = true;
        reservationDeniedString = "There are no more Female Spots available.";
        return;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _isgoing = false;
    userHasTeam = false;
    _isloading = true;
    _isAdmin = false;
    _isEventOrg = false;
    _notStarted = false;
    _userhasPayed = false;

    reservationBlocked = false;

    setState(() {
      setExtraPlayerData(userId);
    });
    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        // This is the listener for Tournament DATA
        //By Adding the <> GENETIC DATA we indicate which Provider we listen to.
        final tournamentData = Provider.of<Tournaments>(context, listen: false);
        final currentTournament = tournamentData.item;
        tournamentId = currentTournament[0].tournamentid;
        maxParticipants = currentTournament[0].maxParticipants;
        maxGenderParticipants = (maxParticipants / 2).toInt();
        genderOnly = currentTournament[0].genderOnly;
        date = currentTournament[0].date;
        startingHour = currentTournament[0].startingHour;
        finishHour = currentTournament[0].finishHour;
        niveles = currentTournament[0].niveles;
        location = currentTournament[0].location;
        price = currentTournament[0].price;
        description = currentTournament[0].description;
        organizerName = currentTournament[0].organizerName;
        whatsAppNR = currentTournament[0].whatsAppNR;

        _isMale = false;
        _isFemale = false;
        _isMixt = false;
        _isOpenSex = false;

        if (genderOnly == "Male") {
          _isMale = true;
        } else if (genderOnly == "Female") {
          _isFemale = true;
        } else if (genderOnly == "Mixt Sex") {
          _isMixt = true;
        } else {
          _isOpenSex = true;
        }

        // This is the listener for USER DATA
        //By Adding the <> GENETIC DATA we indicate which Provider we listen to.
        final userData = Provider.of<Users>(context, listen: false);
        // here we access the data from the listener.
        final currentUser = userData.item;
        userId = currentUser[0].id;
        googleName = currentUser[0].username;
        photoUrl = currentUser[0].photoUrl;
        achievedlvl = currentUser[0].achievedLvl;
        myGender = currentUser[0].gender;
        checkIsAdmin();

        handleDocExist(tournamentId, userId);
        checkBlockReservation();

        _isloading = false;
      });
    });
  }

  showCancelDialog(BuildContext context) {
    // set up the AlertDialog

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
          tournamentinstance.document(tournamentId).delete();
          Navigator.of(context).popAndPushNamed(Home.link);
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Cancel Tournament"),
      content: Text(
          "Are you sure? The tournament will be deleted and will not be available anymore."),
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

  @override
  Widget build(BuildContext context) {
    double standardContainerhight = 20;

    double descriptionContainerHeigt = MediaQuery.of(context).size.height * 0.1;

    double iconSize = 23;

    double infofontSize = 15;

    // 1.) Handle Sign In Event
    // 1.1) Create User Document inside of participants collection in the tournament collection
    handleSignInEvent(
      String tournamentId,
      String userId,
      String photoUrl,
      String googleName,
    ) async {
      tournamentinstance
          .doc(tournamentId)
          .collection("participants")
          .doc(userId)
          .set(
        {
          "userId": userId,
          "photoUrl": photoUrl,
          "googleName": googleName,
          "achievedlvl": achievedlvl,
          "gender": myGender,
          "hasTeam": false,
          "paymentStatus": false,
        },
      );
    }

    // 1.) Handle Sign In Event
    // Borrow the participant Document with the userId of the CurrentUser
    handleSignOutEvent(String tournamentId, String userId) async {
      // Reservationblocked is put to false for the following case:
      // User is last one to get a spot and unreserves and wants to reserve again...
      // In this case init State detected before change that event is full and puts reservationblocked to true...
      // Here we put it to false again so user can reserve again.
      reservationBlocked = false;
      _userhasPayed = false;

      tournamentinstance.doc(tournamentId)
        ..collection("participants").doc(userId).delete();
    }

    //00) AlertDialog to confirm sign out
    void signOutDialog(String tournamentId, String userId) {
      // flutter defined function
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: Text("Confirm Sign Out"),
            content: Text(
                "You have already payed. Are you sure you want to cancel? You will loose the amount payed. For questions please contact in time the organizer."),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              FlatButton(
                child: new Text("Back"),
                onPressed: () {
                  Navigator.of(context).pop();
                  return;
                },
              ),
              FlatButton(
                child: Text("Confirm cancelation"),
                onPressed: () {
                  setState(() {
                    _isgoing = !_isgoing;
                  });

                  handleSignOutEvent(tournamentId, userId);

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return _isloading
        ? Container(
            height: MediaQuery.of(context).size.height * 0.9,
            width: double.infinity,
            color: Colors.white,
            child: Center(child: circularProgress()))
        :
            Container(
                color: HexColor("#ffe664"),
                child: Column(
                  children: <Widget>[
                    !userHasTeam ? Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                      width: double.infinity,
                      color: Colors.white,
                      child:
                          // Case that Player is assigned to team and ready to Start Tournament.

                          // Case that Player is not assigned to team and can still edit his reservation.
                          Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          _isgoing
                              ? Text(
                                  "You are going",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color:
                                          HexColor("#206601").withOpacity(0.8),
                                      fontWeight: FontWeight.bold),
                                )
                              : Text(
                                  "You are not going",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          HexColor("ea070a").withOpacity(0.8),
                                      fontWeight: FontWeight.bold),
                                ),
                          _isgoing
                              ? Text(
                                  "CHANGE",
                                  style: TextStyle(
                                    color: HexColor("#206601").withOpacity(0.8),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Text(
                                  "CHANGE",
                                  style: TextStyle(
                                    color: HexColor("#ea070a").withOpacity(0.8),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          _isgoing
                              ? IconButton(
                                  iconSize: 50,
                                  icon: Icon(
                                    Icons.check_circle,
                                    color: HexColor("#206601").withOpacity(0.8),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (userHasTeam == false ||
                                          userHasTeam == null) {
                                        if (_userhasPayed) {
                                          signOutDialog(tournamentId, userId);
                                        } else {
                                          handleSignOutEvent(
                                              tournamentId, userId);
                                          _isgoing = !_isgoing;
                                        }
                                      } else {
                                        print(
                                            "Else Case. Isogoing is $_isgoing and userHasTeam is $userHasTeam");
                                      }
                                    });
                                  },
                                )
                              : IconButton(
                                  iconSize: 50,
                                  icon: Icon(Icons.check_circle,
                                      color:
                                          HexColor("ea070a").withOpacity(0.8)),
                                  onPressed: () {
                                    setState(
                                      () {
                                        if (reservationBlocked) {
                                          print(
                                              "Event is full, reservation was not possible.");
                                          _eventFullDialog();
                                        } else {
                                          _isgoing = !_isgoing;
                                          handleSignInEvent(tournamentId,
                                              userId, photoUrl, googleName);
                                          welcomeDialog();
                                        }
                                      },
                                    );
                                  },
                                )
                        ],
                      ),
                    ) : SizedBox(height:0),
                    // If athlet is going, we make a seperation line between isgoing button and Event Info.
                    _isgoing
                        ? Stack(
                            children: [
                              Container(
                                  width: double.infinity,
                                  height: 2,
                                  color: Colors.white),
                              Container(
                                color: Colors.black.withOpacity(0.05),
                                height: 2,
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(horizontal: 40),
                              ),
                            ],
                          )
                        : SizedBox(
                            height: 0,
                          ),
                    Container(height: 20, color: Colors.white),
                    // Aditional Info that appears if athlet goes.
                    _isgoing &&!userHasTeam
                        ? Column(children: <Widget>[
                            // Info Part
                            Container(
                              color: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 40),
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    "Great!",
                                    style: TextStyle(
                                        fontSize: infofontSize,
                                        fontWeight: FontWeight.bold,
                                        color: HexColor("#40c903")),
                                  ),
                                  Text(
                                    "We are looking forward to play with you! If you don´t have a partner, we can find one for you at the tourmant..",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        height: 1.5,
                                        fontSize: infofontSize,
                                        fontWeight: FontWeight.bold,
                                        color: HexColor("#40c903")),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                   Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.only(bottom: 10),
                                          child: Text(
                                            "Important:",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )),
                                      Text(
                                        "Please arrive on time and",
                                        textAlign: TextAlign.center,
                                        style:
                                            TextStyle(fontSize: infofontSize),
                                      ),
                                      Text(
                                        "bring the money fitting",
                                        style:
                                            TextStyle(fontSize: infofontSize),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ) ,
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Contact the organizer 4 hours before the start of the Tournament for exact location info.",
                                        style:
                                            TextStyle(fontSize: infofontSize),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ])
                        : SizedBox(
                            height: 0,
                          ),
                    userHasTeam? AssignedTeamWidget(googleName: googleName,context: context,tournamentId: tournamentId,):SizedBox(height:0),
                    ClipPath(
                      clipper: ClippingClass(),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.1),
                            color: Colors.white,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    color: _isgoing
                                        ? HexColor("#000000").withOpacity(0.05)
                                        : Colors.white,
                                    child: Column(
                                      children: <Widget>[
                                        _isAdmin
                                            ? Container(
                                                margin: EdgeInsets.only(
                                                    left: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.3),
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: HexColor("#ffde03"),
                                                  borderRadius:
                                                      BorderRadius.circular(19),
                                                  border: Border.all(
                                                      width: 1,
                                                      color: Colors.black12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: HexColor("#000000")
                                                          .withOpacity(0.5),
                                                      offset: Offset(
                                                          0.0, 2.0), //(x,y)
                                                      blurRadius: 4.0,
                                                      spreadRadius: 0,
                                                    ),
                                                  ],
                                                ),
                                                child: FlatButton.icon(
                                                  onPressed: () {
                                                    checkGameStatus();
                                                  },
                                                  label: Text(
                                                    "Add Teams",
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                  icon: Icon(
                                                    MdiIcons.accountPlus,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              )
                                            : SizedBox(
                                                height: 0,
                                              ),
                                        buildContainer(
                                            Icon(
                                              MdiIcons.arrowTopRight,
                                              size: iconSize,
                                            ),
                                            niveles,
                                            standardContainerhight,
                                            context),
                                        buildContainer(
                                            Icon(
                                              Icons.place,
                                              size: iconSize,
                                            ),
                                            location,
                                            standardContainerhight,
                                            context),
                                        buildContainer(
                                            Icon(
                                              Icons.credit_card,
                                              size: iconSize,
                                            ),
                                            "$price€",
                                            standardContainerhight,
                                            context),
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              SizedBox(width: 20),
                                              Icon(
                                                MdiIcons.clockOutline,
                                                size: iconSize,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        bottom: 5),
                                                    child: Text(
                                                      date,
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.8)),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 3,
                                                    ),
                                                  ),
                                                  Container(
                                                    height:
                                                        standardContainerhight,
                                                    child: Text(
                                                      "$startingHour - $finishHour",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.6)),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 3,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          color: _isgoing
                                              ? HexColor("#000000")
                                                  .withOpacity(0.05)
                                              : Colors.white,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 19),
                                            height: descriptionContainerHeigt,
                                            width: double.infinity,
                                            child: Text(
                                              description,
                                              style: TextStyle(
                                                  fontSize: infofontSize,
                                                  color: Colors.black
                                                      .withOpacity(0.8)),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Description
                                  _isEventOrg
                                      ? Container(
                                          margin: EdgeInsets.only(bottom: 20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Container(
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: HexColor("#F5F4F4"),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                      width: 1,
                                                      color: Colors.black12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: HexColor("#000000")
                                                          .withOpacity(0.5),
                                                      offset: Offset(
                                                          0.0, 2.0), //(x,y)
                                                      blurRadius: 4.0,
                                                      spreadRadius: 0,
                                                    ),
                                                  ],
                                                ),
                                                child: FlatButton.icon(
                                                  label: Text(
                                                    "Edit",
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                  icon: Icon(
                                                    Icons.edit,
                                                    color: Colors.black,
                                                  ),
                                                  onPressed: () {
                                                    print(tournamentId);
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                            AddTournamentScreen
                                                                .link,
                                                            arguments: {
                                                          "firstLoad": false,
                                                          "tournamentId":
                                                              tournamentId
                                                        });
                                                  },
                                                ),
                                              ),
                                              Container(
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: HexColor("#F5F4F4"),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                      width: 1,
                                                      color: Colors.black12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: HexColor("#000000")
                                                          .withOpacity(0.5),
                                                      offset: Offset(
                                                          0.0, 2.0), //(x,y)
                                                      blurRadius: 4.0,
                                                      spreadRadius: 0,
                                                    ),
                                                  ],
                                                ),
                                                child: FlatButton.icon(
                                                  label: Text(
                                                    "Cancel",
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                  icon: Icon(
                                                    Icons.cancel,
                                                    color: Colors.black,
                                                  ),
                                                  onPressed: () {
                                                    showCancelDialog(context);
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      : SizedBox(
                                          height: 0,
                                        ),
                                  Container(
                                    height: 2,
                                    width: double.infinity,
                                    color: Colors.black.withOpacity(0.05),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 50),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(
                                        top:
                                            MediaQuery.of(context).size.height *
                                                0.04),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          MdiIcons.accountCircle,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.125,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.025,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  "Organizer: ",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black
                                                          .withOpacity(0.8)),
                                                ),
                                                Text(
                                                  organizerName,
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black
                                                          .withOpacity(0.8)),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "WhatsApp: ",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  whatsAppNR,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),

                                  SizedBox(
                                    height: 70,
                                  )
                                ]),
                          ),
                        ],
                      ),
                    ),
                    SignedUpGridview(
                      tournamentId: tournamentId,
                      isloading: _isloading,
                      isAdmin: _isAdmin,
                    ),

                    SignedUpTeamsGridview(
                      tournamentId: tournamentId,
                      isloading: _isloading,
                    ),
                  ],
                ),
              );

  }
}
