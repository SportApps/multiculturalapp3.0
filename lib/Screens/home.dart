import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as FireUserImport;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:multiculturalapp/MyWidgets/TournamentInfoScr/tournamentinfo.dart';
import 'package:multiculturalapp/MyWidgets/clippingClass.dart';
import 'package:multiculturalapp/MyWidgets/progress.dart';
import 'package:multiculturalapp/MyWidgets/startscreentlist.dart';
import 'package:multiculturalapp/MyWidgets/userInfoStartscreen.dart';
import 'package:multiculturalapp/Screens/addTournamentScreen.dart';
import 'package:multiculturalapp/Screens/ligaRanking.dart';
import 'package:multiculturalapp/Screens/volleyballLevels.dart';
import 'package:multiculturalapp/model/user.dart';
import 'package:multiculturalapp/model/users.dart';
import 'package:provider/provider.dart';

import 'file:///C:/Users/Timkn/Desktop/volleyimport/multiculturalapp/lib/Screens/OrgaInfo/orgaOverview.dart';

import 'Authentication/unAuthStartScreen.dart';
import 'CreateAccount.dart';
import 'changeUserProfile/homeChangeProfile.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final usersRef = FirebaseFirestore.instance.collection('users');
final DateTime timeStamp = DateTime.now();

class Home extends StatefulWidget {
  static const link = "/Home";

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final fbm = FirebaseMessaging();

  ScrollController _scrollController;

  bool _isloading;
  bool firstload;
  bool _isAdmin = false;
  FireUserImport.User currentUser;
  String myUserId;
  String myUserPhotoURL;
  String myUserName;

  String myGender;
  String achievedlvl;
  String myStrength;
  String myFlaws;
  String myBlockDefense;
  String myExpectations;
  int points;
  int myLikes;

  double _deviceHeight;
  double _deviceWidth;
  double winLooseRatio;
  int historyGamesWon;
  int historyGamesLost;

  double _halfCirclediameter;

  // OVERVIEW HOME CLASS
  // I) Checking if user is new and if not make sure he creates a username
  // II) HANDLE GOOGLE LOG IN PROCESS WITH  init STATE
  // III ) BUILD FUNCTIONS TO CREATE SCREENS

  // I) Checking if user is new and if not make sure he creates a username

  // II) HANDLE GOOGLE LOG IN PROCESS WITH  init STATE

  getUserData() async {
    print("Get user data function activated");

    myUserId = await FireUserImport.FirebaseAuth.instance.currentUser.uid;
    print(myUserId);
    await FirebaseFirestore.instance
        .collection("users")
        .doc(myUserId)
        .get()
        .then((doc) {
      if (!doc.exists) {
        print("firstload part activated");
        firstload = true;

        return;
      } else if (doc.exists) {}

      _isAdmin = doc.data()["isAdmin"];
      if (_isAdmin == null) {
        _isAdmin = false;
      }
      firstload = doc.data()["firstload"];
      if (firstload) {
        Navigator.of(context)
            .popAndPushNamed(CreateAccount.link, arguments: myUserId);
      }
      myLikes = doc.data()["likes"];
      myGender = doc.data()["gender"];
      myUserPhotoURL = doc.data()["photo_url"];
      myUserName = doc.data()["username"];
      achievedlvl = doc.data()["achievedlvl"];
      myStrength = doc.data()["myStrength"];
      myFlaws = doc.data()["myFlaws"];
      myBlockDefense = doc.data()["myBlockDefense"];
      myExpectations = doc.data()["myExpectations"];
      points = doc.data()["points"];
      winLooseRatio = doc.data()["winLooseRatio"].toDouble();
      historyGamesWon = doc.data()["historyGamesWon"];
    });

    fbm.requestNotificationPermissions();
    fbm.configure(
      onMessage: (msg) {
        String content = msg["notification"];

        print(msg);
        print(content);
        return;
      },
      onLaunch: (msg) {
        print(msg);
        return;
      },
      onResume: (msg) {
        print(msg);
        return;
      },
    );
    fbm.subscribeToTopic("tournament");
  }

  void noInternetDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("No internet connection"),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          content:
              Text("For the App to work, you need an internet connection."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                return;
              },
            ),
          ],
        );
      },
    );
  }

  tryInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
      }
    } on SocketException catch (_) {
      print('not connected');

      noInternetDialog();
    }
  }

  clicONUserInfoDialog(BuildContext context) {
    String nextLevel;
    String nextLevelPoints;
    String nextLevelRatio;
    String assetPath;
    bool _isHighestlvl = false;

    if (achievedlvl == "Baby Beginner") {
      nextLevel = "Little Child";
      nextLevelPoints = "10";
      nextLevelRatio = "-";
      assetPath = "assets/images/babybeginner3.gif";
    } else if (achievedlvl == "Little Child") {
      nextLevel = "Amateur";
      nextLevelPoints = "20";
      nextLevelRatio = "-";
      assetPath = "assets/images/littlechild2.gif";
    } else if (achievedlvl == "Amateur") {
      nextLevel = "Grown-Up";
      nextLevelPoints = "30";
      nextLevelRatio = "-";
      assetPath = "assets/images/amateur.gif";
    } else if (achievedlvl == "Grown-Up") {
      nextLevel = "Experienced";
      nextLevelPoints = "50";
      nextLevelRatio = ">1";
      assetPath = "assets/images/gownup.gif";
    } else if (achievedlvl == "Experienced") {
      nextLevel = "Volley God";
      nextLevelPoints = "100";
      nextLevelRatio = ">2";
      assetPath = "assets/images/experienced.gif";
    } else if (achievedlvl == "Volley God") {
      nextLevel = "-";
      nextLevelPoints = "-";
      nextLevelRatio = "-";
      assetPath = "assets/images/volleygod.gif";
      _isHighestlvl = true;
    }

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      contentPadding: EdgeInsets.only(top: _deviceHeight * 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      content: Container(
        height: _deviceHeight * 0.8,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                  child: Text("You are a $achievedlvl",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      top: _deviceHeight * 0.05,
                    ),
                    height: _deviceHeight * 0.3,
                    width: _deviceHeight * 0.5,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                      assetPath,
                    ))),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                        color: HexColor("#ffe664"),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: EdgeInsets.only(top: _deviceHeight * 0.4),
                child: !_isHighestlvl
                    ? Column(
                        children: [
                          Text(
                            "Level up to: $nextLevel",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          SizedBox(
                            height: _deviceHeight * 0.02,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 30,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "$nextLevelPoints Points",
                                    style: TextStyle(fontSize: 18),
                                  )
                                ],
                              ),
                              SizedBox(
                                width: _deviceWidth * 0.1,
                              ),
                              Column(
                                children: [
                                  Icon(
                                    MdiIcons.trendingUp,
                                    size: 30,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "$nextLevelRatio Ratio",
                                    style: TextStyle(fontSize: 18),
                                  )
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            height: _deviceHeight * 0.07,
                          ),
                          Text("Win points by joining a game")
                        ],
                      )
                    : Column(
                        children: [
                          SizedBox(height: _deviceHeight*0.025,),
                          Text(
                            "You are amazing!",
                            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
                          ),

                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 15,
                                horizontal: 15),
                              child: Text(
                                  "You won full access to our High Level Events! Climp up to Rank 1 of Volley World and get a gift every month!",textAlign: TextAlign.center,))
                        ],
                      ),
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease);
                  },
                  child: Container(
                    child: CustomPaint(
                      painter: halfCirclePainerClass(),
                      size: Size(_halfCirclediameter, _halfCirclediameter),
                    ),
                  ),
                )),
            Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease);
                  },
                  child: Container(
                    height: _deviceWidth * 0.2,
                    child: Column(
                      children: [
                        Text(
                          "START NOW",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: _deviceWidth * 0.025,
                        ),
                        Icon(
                          MdiIcons.arrowDownBold,
                          size: 35,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return alert;
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();

    print("Init Sate of home is initalized");
    _isloading = true;
    firstload = true;
    _scrollController = ScrollController();

    // Cloud Messaging Test

    tryInternetConnection();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _deviceHeight = MediaQuery.of(context).size.height;
      _deviceWidth = MediaQuery.of(context).size.width;
      _halfCirclediameter = _deviceWidth * 0.6;
      Future.delayed(const Duration(milliseconds: 0), () async {
        await getUserData();
// Here you can write your code

        User myUser = User();
        myUser.isAdmin = _isAdmin;
        myUser.id = myUserId;
        myUser.username = myUserName;
        myUser.myStrength = myStrength;
        myUser.myFlaw = myFlaws;
        myUser.myBlockDefense = myBlockDefense;
        myUser.myExpectations = myExpectations;
        myUser.myLikes = myLikes;
        myUser.photoUrl = myUserPhotoURL;
        myUser.gender = myGender;
        myUser.historyGamesWon = historyGamesWon;
        myUser.points = points;
        myUser.achievedLvl = achievedlvl;
        myUser.historyGamesLost = historyGamesLost;
        myUser.winLooseRatio = winLooseRatio;

        final userInfo = Provider.of<Users>(context, listen: false);
        userInfo.addUser(myUser);

        setState(() {
          print("Init State finished");
          _isloading = false;
          // Here you can write your code for open new view
        });
      });

      //0)Check is admin
    });
  }

  // III ) BUILD FUNCTIONS TO CREATE SCREENS

  // AUTH SCREEN CONTENT
  // 1.) APP BAR BUILDER
  AppBar appBarbuilder() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Container(
        width: MediaQuery.of(context).size.width * 0.35,
        height: MediaQuery.of(context).size.width * 0.25,
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage(
            "assets/images/homeappbar2.png",
          ),
        )),
      ),
      actions: <Widget>[
        DropdownButton(
          onChanged: (itemIdentifier) {
            if (itemIdentifier == "logoutID") {
              setState(() {
                Navigator.of(context).maybePop();
                Navigator.of(context).pushNamed(UnAuthStartScreen.link);
                FireUserImport.FirebaseAuth.instance.signOut();
              });
            }
            if (itemIdentifier == "AboutUs") {
              Navigator.of(context).pushNamed(VolleyballLevels.link);
            }
            if (itemIdentifier == "LigaScore") {
              Navigator.of(context).pushNamed(LigaRAnking.link);
            }
            if (itemIdentifier == "Organizers") {
              Navigator.of(context).pushNamed(OrgaOverview.link);
            }
            if (itemIdentifier == "HomeChangeProfile") {
              Navigator.of(context).popAndPushNamed(HomeChangeProfile.link);
            }
          },
          items: [
            DropdownMenuItem(
              //The value serves as Itendifier.
              value: "LigaScore",

              child: Container(
                  child: Row(
                children: <Widget>[
                  Icon(
                    MdiIcons.trophyVariant,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Liga Score",
                    style: TextStyle(
                      fontFamily: "Helvetica",
                    ),
                  )
                ],
              )),
            ),
            DropdownMenuItem(
              //The value serves as Itendifier.
              value: "AboutUs",

              child: Container(
                  child: Row(
                children: <Widget>[
                  Icon(
                    MdiIcons.volleyball,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "About us",
                    style: TextStyle(
                      fontFamily: "Helvetica",
                    ),
                  )
                ],
              )),
            ),
            DropdownMenuItem(
              //The value serves as Itendifier.
              value: "HomeChangeProfile",

              child: Container(
                  child: Row(
                children: <Widget>[
                  Icon(
                    MdiIcons.faceProfileWoman,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Profile",
                    style: TextStyle(
                      fontFamily: "Helvetica",
                    ),
                  )
                ],
              )),
            ),
            DropdownMenuItem(
              //The value serves as Itendifier.
              value: "Organizers",

              child: Container(
                  child: Row(
                children: <Widget>[
                  Icon(
                    MdiIcons.star,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Organizers",
                    style: TextStyle(
                      fontFamily: "Helvetica",
                    ),
                  )
                ],
              )),
            ),
            DropdownMenuItem(
              //The value serves as Itendifier.
              value: "logoutID",
              child: Container(
                  child: Row(
                children: <Widget>[
                  Icon(
                    Icons.exit_to_app,
                  ),
                  SizedBox(width: 8),
                  Text("Log Out")
                ],
              )),
            )
          ],
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).primaryIconTheme.color,
            size: 35,
          ),
        )
      ],
    );
  }

// 2.) USER INFO BUILDER

  ClipPath UserinfoBuilder() {
    if (achievedlvl == null) {
      achievedlvl = "Baby Beginner";
    }
    if (myUserPhotoURL == null) {
      firstload = true;
      photoUrl =
          "https://images.unsplash.com/photo-1491013516836-7db643ee125a?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1525&q=80";
    }

    return ClipPath(
      clipper: ClippingClass(),
      child: Column(
        children: <Widget>[
          firstload
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : InkWell(
                  onTap: () {
                    clicONUserInfoDialog(context);
                  },
                  child: UserInfoStartscreen(
                    name: myUserName,
                    likes: myLikes,
                    skill: achievedlvl,
                    heightContainer: MediaQuery.of(context).size.height * 0.1,
                    imageUrl: myUserPhotoURL,
                    points: points.toString(),
                    gamesWon: historyGamesWon.toString(),
                    winLooseRatioDouble: winLooseRatio,
                  ),
                ),
          Container(
            height: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

// 3.) TOURNAMENTOVERVIEWBUILDER
  Column tournamentoverviewbuilder() {
    final double _heightTournC = MediaQuery.of(context).size.height * 0.5;
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            "Next Tournaments",
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.8)),
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 10),
          height: _heightTournC,
          width: double.infinity,
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("ourtournaments")
                  .orderBy("date")
                  .orderBy("startingHour")
                  .snapshots(),
              builder: (context, tsnapshot) {
                if (tsnapshot.connectionState == ConnectionState.waiting) {
                  return circularProgress();
                }
                //Data Snapshot
                var _loadeddata = tsnapshot.data.documents;
                var _loadeddataIndex;
                return ListView.builder(
                  itemCount: tsnapshot.data.documents.length,
                  itemBuilder: (ctx, index) {
                    _loadeddataIndex = _loadeddata[index];
                    Timestamp t = _loadeddataIndex.data()["date"];
                    DateTime d = t.toDate();
                    var convertedDate = DateFormat("dd-MMM-yyyy").format(d);

                    return Startscreentlist(
                      genderOnly: _loadeddataIndex.data()["genderOnly"],
                      maxParticipants:
                          _loadeddataIndex.data()["maxParticipants"],
                      date: convertedDate.toString(),
                      description: _loadeddataIndex.data()["description"],
                      fulldate: _loadeddataIndex.data()["fulldate"],
                      startingHour: _loadeddataIndex.data()["startingHour"],
                      finishHour: _loadeddataIndex.data()["finishHour"],
                      location: _loadeddataIndex.data()["location"],
                      locationUrl: _loadeddataIndex.data()["locationUrl"],
                      name: _loadeddataIndex.data()["name"],
                      niveles: _loadeddataIndex.data()["niveles"],
                      price: _loadeddataIndex.data()["price"],
                      tournamentId: _loadeddataIndex.data()["tournamentId"],
                      fotoLink: _loadeddataIndex.data()["fotoLink"],
                      organizerName: _loadeddataIndex.data()["organizerName"],
                      whatsAppNR: _loadeddataIndex.data()["whatsAppNR"],
                      userId: myUserId,
                      photoUrl: myUserPhotoURL,
                      googleName: userName,
                      organizerPhoto: _loadeddataIndex.data()["organizerPhoto"],
                      organizerId: _loadeddataIndex.data()["organizerId"],
                    );
                  },
                );
              }),
        ),
      ],
    );
  }

  // RESUMEN BUILD AUTH SCREE
  Scaffold buildAuthScreen() {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _isAdmin
            ? FloatingActionButton.extended(
                icon: Icon(
                  Icons.add,
                  size: 20,
                ),
                label: Text(
                  "Add Tournament",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(AddTournamentScreen.link,
                      arguments: {"firstLoad": true});
                },
              )
            : SizedBox(
                height: 0,
              ),
        bottomNavigationBar: BottomAppBar(
          color: Theme.of(context).bottomAppBarTheme.color,
          child: _isAdmin
              ? Container(
                  color: HexColor("#ffe664"),
                  height: MediaQuery.of(context).size.height * 0.065,
                )
              : Container(
                  height: 0,
                  color: Colors.transparent,
                ),
        ),
        body: _isloading
            ? Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                child: Center(
                    child: Column(
                  children: [
                    Text("Loading Home Screen..."),
                    CircularProgressIndicator(),
                  ],
                )))
            : Container(
                color: HexColor("#ffe664"),
                child: ListView(
                  controller: _scrollController,
                  children: <Widget>[
                    appBarbuilder(),
                    Stack(
                      children: <Widget>[
                        UserinfoBuilder(),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    tournamentoverviewbuilder()
                  ],
                ),
              ));
  }

  @override
  Widget build(BuildContext context) {
    return buildAuthScreen();
  }
}

class halfCirclePainerClass extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.white;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.height / 2, size.width),
        height: size.height,
        width: size.width,
      ),
      pi,
      pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
