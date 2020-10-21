import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
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

import 'package:multiculturalapp/Screens/ligaRanking.dart';
import 'package:multiculturalapp/Screens/addTournamentScreen.dart';
import 'package:multiculturalapp/Screens/volleyballLevels.dart';

import 'package:multiculturalapp/model/user.dart';

import 'CreateAccount.dart';

import 'package:provider/provider.dart';
import 'package:multiculturalapp/model/users.dart';
import 'package:multiculturalapp/model/userStat.dart';
import "package:multiculturalapp/model/userStats.dart";
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final usersRef = FirebaseFirestore.instance.collection('users');
final DateTime timeStamp = DateTime.now();
final FirebaseMessaging _fcm = FirebaseMessaging();

class Home extends StatefulWidget {
  static const link = "/Home";

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool firstload = true;
  String testimage =
      "https://lh3.googleusercontent.com/a-/AOh14Gj9awToFyC1y6XtBB6b4PDnETL0hI4UaoZB8dfLsw=s96-c";

  bool _isAuth = false;
  bool _isAdmin = false;
  User currentUser;
  String myUserId;
  int points;
  String achievedLvl;
  double winLooseRatio;
  int historyGamesWon;
  int historyGamesLost;

  final DateTime timestamp = DateTime.now();

  // OVERVIEW HOME CLASS
  // I) Checking if user is new and if not make sure he creates a username
  // II) HANDLE GOOGLE LOG IN PROCESS WITH  init STATE
  // III ) BUILD FUNCTIONS TO CREATE SCREENS

  // I) Checking if user is new and if not make sure he creates a username
  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount user = _googleSignIn.currentUser;
    DocumentSnapshot doc = await usersRef.doc(user.id).get();

    if (!doc.exists) {
      print("Doc does not exist!!!");
      // 2) if the user doesn't exist, then we want to take them to the create account page
      //AditionalDatalist has in position 0 the Username and in postion 2 the lvl
      var aditionalUserData = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));
      firstload = false;
      try {
        usersRef.doc(user.id).set({
          "id": user.id,
          "username": aditionalUserData[0],
          "gender": aditionalUserData[1],
          "photoUrl": _googleSignIn.currentUser.photoUrl,
          "email": user.email,
          "displayName": user.displayName,

          "timestamp": timestamp,
          "points": 0,
          "achievedLvl": "Baby Beginner",
          "winLooseRatio": 0.00,
          "historyGamesWon": 0,
          "historyGamesLost": 0,
        }).then((value) {
          setState(() {
            firstload = false;
          });
        }).catchError((error) {
          print("ERROR CASE");
          print(error);
          print(
              "An error has occured pls restart app.!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        });
      } catch (err) {
        print("ERROR HAPPED OMG");
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text("An Error returned"),
                  content: Text(
                      "An error occurred as the registration process has been interupted. Please restart the App to try again."),
                ));
      }
      ;

      // 3) get username from create account, use it to make new user document in users collection

      doc = await usersRef.doc(user.id).get();
    } else {
      setState(() {
        firstload = false;
      });
    }
    currentUser = User.fromDocument(doc);

    Provider.of<Users>(context, listen: false).addUser(currentUser);
  }

  // II) HANDLE GOOGLE LOG IN PROCESS WITH  init STATE
  logIn() {
    _googleSignIn.signIn();
  }

  @override
  void initState() {
    super.initState();
    firstload = true;

    Firebase.initializeApp().whenComplete(() {
      print("INITIALIZE APP COMPLETED");
      setState(() {});
    });
    // Detects when user signed in
    _googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
      print("NO INTERNET!!!");
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Sign-In Error"),
          actions: <Widget>[
            FlatButton(
              child: Text("Done"),
            )
          ],
          content: Text("Please check your Internet connection."),
        ),
      );
    });
    // Reauthenticate user when app is opened
    _googleSignIn.signInSilently(suppressErrors: false).then((account) {
      print("Silent Sign In");
      handleSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });

    // get Foto Lvl and other data.
  }

  handleSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      await createUserInFirestore();

      await Provider.of<Users>(context, listen: false).addUser(currentUser);

      final GoogleSignInAccount user = _googleSignIn.currentUser;
      myUserId = await user.id;

      var fireUser = await userInstance.doc(myUserId).get();
      points = await fireUser.data()["points"];
      achievedLvl = await fireUser.data()["achievedLvl"];

      if (achievedLvl == "Admin") {
        _isAdmin = true;
      }

      historyGamesWon = await fireUser.data()["historyGamesWon"];
      ;
      historyGamesLost = await fireUser.data()["historyGamesLost"];

      if (historyGamesWon > 0 && historyGamesLost > 0) {
        winLooseRatio = historyGamesWon / historyGamesLost;
        print("Win - Loose Ratio is at $winLooseRatio");
      } else {
        winLooseRatio = 1;
      }
      // Here we fill in the provider data with of the current Stat.
      UserStat myUserStat = UserStat();

      myUserStat.userId = userId;
      myUserStat.totalPoints = points;
      myUserStat.achievedLvl = achievedLvl;
      myUserStat.winLooseRatio = winLooseRatio;
      myUserStat.historyGamesWon = historyGamesWon;
      myUserStat.historyGamesLost = historyGamesLost;

      final userStatsInfo = Provider.of<UserStats>(context, listen: false);
      userStatsInfo.addUserStat(myUserStat);

      setState(() {
        _isAuth = true;
      });
    } else {
      setState(() {
        firstload = true;
        _isAuth = false;
      });
    }
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
            "assets/images/homeappbar.png",
          ),
        )),
      ),
      actions: <Widget>[
        DropdownButton(
          onChanged: (itemIdentifier) {
            if (itemIdentifier == "logoutID") {
              _googleSignIn.signOut().then((value) => _isAuth = false);
            }
            if (itemIdentifier == "AboutUs") {
              Navigator.of(context).pushNamed(VolleyballLevels.link);
            }
            if (itemIdentifier == "LigaScore") {
              Navigator.of(context).pushNamed(LigaRAnking.link);
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
                    MdiIcons.faceProfileWoman,
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

  // 2.1) Future for FutureBuilder
  Future<List<dynamic>> getUsername() async {
    var firestore = FirebaseFirestore.instance;

    try {
      var useridGoogle = await _googleSignIn.currentUser.id;

      var querySnap = await firestore
          .collection('users')
          .where("id", isEqualTo: useridGoogle)
          .get();

      return querySnap.docs;
    } catch (err) {
      print(err);
    }
  }

  ClipPath UserinfoBuilder() {
    return ClipPath(
      clipper: ClippingClass(),
      child: Column(
        children: <Widget>[
          firstload
              ? circularProgress()
              : FutureBuilder(
                  future: getUsername(),
                  builder: (context, futuresnap) {
                    if (!futuresnap.hasData ||
                        futuresnap == null ||
                        futuresnap.hasError) {
                      return circularProgress();
                    }

                    final futuresnapData = futuresnap.data[0];
                    final username = futuresnapData.data()["username"];
                    final photoUrl = _googleSignIn.currentUser.photoUrl;

                    final int points = futuresnapData.data()["points"];
                    final int gamesWon =
                        futuresnapData.data()["historyGamesWon"];

                    return UserInfoStartscreen(
                      name: username,
                      skill: achievedLvl,
                      heightContainer: MediaQuery.of(context).size.height * 0.1,
                      imageUrl: photoUrl,
                      userUrl: "",
                      points: points.toString(),
                      gamesWon: gamesWon.toString(),
                      winLooseRatioDouble: winLooseRatio,
                    );
                  }),
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
                      name: _loadeddataIndex.data()["name"],
                      niveles: _loadeddataIndex.data()["niveles"],
                      price: _loadeddataIndex.data()["price"],
                      tournamentId: _loadeddataIndex.data()["tournamentId"],
                      fotoLink: _loadeddataIndex.data()["fotoLink"],
                      organizerName: _loadeddataIndex.data()["organizerName"],
                      whatsAppNR: _loadeddataIndex.data()["whatsAppNR"],
                      userId: _googleSignIn.currentUser.id,
                      photoUrl: _googleSignIn.currentUser.photoUrl,
                      googleName: _googleSignIn.currentUser.displayName,
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
        body: Container(
          color: HexColor("#ffe664"),
          child: ListView(
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

  // UNAUTH CONTENT

  // buildUnAuthIconElements

  Container buildUnAuthIconElements(String descText, String assetLink) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.30,
      child: Column(
        children: <Widget>[
          Text(
            descText,
            style: TextStyle(color: Colors.white),
          ),
          CircleAvatar(
            radius: MediaQuery.of(context).size.width * 0.1,
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage(
              assetLink,
            ),
          ),
        ],
      ),
    );
  }

  WillPopScope buildUnAuthScreen() {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                  fit: BoxFit.fitHeight,
                  image: AssetImage(
                    "assets/images/sunlogin.png",
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                  ),
                  Stack(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          image: AssetImage(
                            "assets/images/iconsconnect.png",
                          ),
                        )),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.10,
                          ),
                          Text(
                            "Free Register",
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.095,
                          ),
                          Column(
                            children: <Widget>[
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Weekly",
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                "Tournaments",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.10,
                          ),
                          Text(
                            "All Levels",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),

            // In this layer we visualize the Title of the app.
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        child: Text(
                          "Multicultural",
                          style: TextStyle(
                            fontSize: 60,
                            fontFamily: "Futura",
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          SizedBox(
                            height: 62,
                          ),
                          Container(
                            width: double.infinity,
                            child: Text(
                              "Barcelonas Amateur League",
                              style: TextStyle(fontSize: 18.5),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // In this layer we overlay the Google Button and White space in the down part.
            Column(
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * 0.8),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.2,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "To get stated use your Google Account",
                        style: TextStyle(fontSize: 13),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      GoogleSignInButton(
                        onPressed: () {
                          logIn();
                        },

                        splashColor: Colors.white,

                        // setting splashColor to Colors.transparent will remove button ripple effect.
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return _isAuth == true ? buildAuthScreen() : buildUnAuthScreen();
  }
}
