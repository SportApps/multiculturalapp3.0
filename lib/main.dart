import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:multiculturalapp/MyWidgets/TournamentInfoScr/teamoverview.dart';
import 'package:multiculturalapp/Screens/Authentication/auth_screen.dart';

import 'package:multiculturalapp/Screens/Authentication/unAuthStartScreen.dart';
import 'package:multiculturalapp/Screens/CreateAccount.dart';
import 'package:multiculturalapp/Screens/CreateTeamsScreen.dart';
import 'package:multiculturalapp/Screens/Final/tournamentFinished.dart';
import 'package:multiculturalapp/Screens/TournOnScreen.dart';
import 'package:multiculturalapp/Screens/addTournamentScreen.dart';
import 'package:multiculturalapp/Screens/groupphaseOverview.dart';
import 'package:multiculturalapp/Screens/home.dart';
import 'package:multiculturalapp/Screens/ligaRanking.dart';
import 'package:multiculturalapp/Screens/tournamentinfoscreen.dart';
import 'package:multiculturalapp/Screens/volleyballLevels.dart';
import 'package:provider/provider.dart';

import 'MyWidgets/TournamentInfoScr/ConfirmTeam.dart';
import 'MyWidgets/TournamentInfoScr/addCountry.dart';
import 'MyWidgets/TournamentInfoScr/addPlayer1.dart';
import 'MyWidgets/TournamentInfoScr/addPlayer2.dart';
import 'Screens/Final/FinalsAdmin.dart';
import 'Screens/Final/finishedPhaseOverview.dart';
import 'Screens/Final/nextGoldMatchUser.dart';
import 'Screens/Final/silverGroupUser.dart';
import 'Screens/NextGameDetails.dart';
import 'Screens/changeUserProfile/homeChangeProfile.dart';
import 'Screens/confirmEndGroupPhase.dart';
import 'Screens/OrgaInfo/orgaOverview.dart';
import 'model/countryInfos.dart';
import 'model/tournaments.dart';
import 'model/userStats.dart';
import 'model/users.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const Color infobackcolor = Color.fromRGBO(242, 241, 239, 100);
  static const Color appBarColor2 = Color.fromRGBO(255, 230, 107, 100);
  static const Color appBarColor = Colors.yellow;
  static const PrimaryColor = const Color(0xFFFFE66B);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> _initialization = Firebase.initializeApp();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return FutureBuilder(
        future: _initialization,
        builder: (context, appSnapshot) {
          return MultiProvider(
            providers: [
// Creates Instance of Provider class to all the class beneath which are interested..
              ChangeNotifierProvider(
                create: (ctx) => Users(),
              ),
              ChangeNotifierProvider(
                create: (ctx) => Tournaments(),
              ),

              ChangeNotifierProvider(
                create: (ctx) => Countryinfos(),
              ),
              ChangeNotifierProvider(
                create: (ctx) => UserStats(),
              )
            ],
            child: MaterialApp(
              builder: (context, child) {
                return MediaQuery(
                  child: child,
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                );
              },
              debugShowCheckedModeBanner: false,
              title: "Tournament2020",
              theme: ThemeData(
                fontFamily: 'Helvetica.ttf',
                primarySwatch: Colors.yellow,
                canvasColor: HexColor("#ffe664"),
                cardColor: Colors.yellow.withOpacity(0.4),
                backgroundColor: Colors.transparent,
                dividerColor: Color.fromRGBO(151, 151, 151, 100),
                accentColor: Colors.white,
                timePickerTheme: TimePickerTheme.of(context).copyWith(
                  backgroundColor: Colors.white,
                ),
                buttonTheme: ButtonTheme.of(context).copyWith(
                  buttonColor: Color.fromRGBO(255, 0, 0, 1),
                  textTheme: ButtonTextTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              home: appSnapshot.connectionState != ConnectionState.done
                  ? CircularProgressIndicator()
                  : StreamBuilder(
                      stream: FirebaseAuth.instance.authStateChanges(),
                      builder: (ctx, userSnapShot) {
                        if (userSnapShot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        // If userSnapshot has Data - FirebaseAuth found a log in Token.
                        if (userSnapShot.hasData) {
                          return Home();
                        } else {
                          return UnAuthStartScreen();
                        }
                      }),
              routes: ({
                TournamentinfoScreen.link: (ctx) => TournamentinfoScreen(),

                //
                // Team Building Screens
                Home.link: (ctx) => Home(),
                AuthScreen.link: (ctx) => AuthScreen(),
                UnAuthStartScreen.link: (ctx) => UnAuthStartScreen(),
                OrgaOverview.link: (ctx) => OrgaOverview(),


                CreateAccount.link: (ctx) => CreateAccount(),
                HomeChangeProfile.link: (ctx) => HomeChangeProfile(),
                Teamoverview.link: (ctx) => Teamoverview(),
                addCountry.link: (ctx) => addCountry(),
                AddPlayer1.link: (ctx) => AddPlayer1(),
                AddPlayer2.link: (ctx) => AddPlayer2(),
                ConfirmTeam.link: (ctx) => ConfirmTeam(),

                TournOnScreen.link: (ctx) => TournOnScreen(),
                CreateTeamScreen.link: (ctx) => CreateTeamScreen(),
                NextGameDetails.link: (ctx) => NextGameDetails(),
                GroupPhaseOverview.link: (ctx) => GroupPhaseOverview(),
                ConfirmedEndGroupPhase.link: (ctx) => ConfirmedEndGroupPhase(),
                FinalsAdmin.link: (ctx) => FinalsAdmin(),

                FinishedPhaseOverview.link: (ctx) => FinishedPhaseOverview(),
                SilverGroupUser.link: (ctx) => SilverGroupUser(),
                NextGoldMatchUser.link: (ctx) => NextGoldMatchUser(),
                TournamentFinished.link: (ctx) => TournamentFinished(),
                LigaRAnking.link: (ctx) => LigaRAnking(),
                AddTournamentScreen.link: (ctx) => AddTournamentScreen(),
                VolleyballLevels.link: (ctx) => VolleyballLevels(),
              }),
            ),
          );
        });
  }
}
