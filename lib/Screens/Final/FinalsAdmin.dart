import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:multiculturalapp/MyWidgets/TournamentInfoScr/tournamentinfo.dart';
import 'package:multiculturalapp/MyWidgets/progress.dart';
import 'package:multiculturalapp/Screens/Final/silverOnlyMatches.dart';
import 'package:multiculturalapp/Screens/NextGameDetails.dart';
import 'package:multiculturalapp/model/tournaments.dart';
import 'package:multiculturalapp/model/users.dart';

import 'goldOnlyAdmin.dart';

class FinalsAdmin extends StatefulWidget {
  static const link = "/AdminFinals";

  @override
  _FinalsAdminState createState() => _FinalsAdminState();
}

class _FinalsAdminState extends State<FinalsAdmin> {
  List<String> silverTeams = [];

  PageController pageController;

  var tournamentInstance =
      FirebaseFirestore.instance.collection("ourtournaments");
  bool _isloading;
  String tournamentId;
  String matchProgress;
  int pageIndex = 0;

  getSilverTeams() async {
    var fireSilver = await tournamentInstance
        .doc(tournamentId)
        .collection("countries")
        .where("FinalGroup", isEqualTo: "Silver")
        .get();
    int NR = 9;
    for (var i = 0; i < fireSilver.docs.length; i++) {
      var fireSilverdocNR = fireSilver.docs[NR];

      silverTeams.add(fireSilverdocNR.data()["CountryName"]);
      NR++;
    }
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.jumpToPage(pageIndex);
  }

  Scaffold buildPageView() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          GoldOnlyAdmin(),
          SilverOnlyMatches(),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Colors.amberAccent,
        items: [
          BottomNavigationBarItem(
            title: Text(
              "GOLD",
              style: TextStyle(fontSize: 15),
            ),
            icon: Icon(
              Icons.looks_one,
            ),
          ),
          BottomNavigationBarItem(
            title: Text(
              "SILVER",
              style: TextStyle(fontSize: 15),
            ),
            icon: Icon(
              Icons.looks_two,
            ),
          )
        ],
      ),
    );
  }

  initState() {
    // TODO: implement initState
    super.initState();

    _isloading = true;

    pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      print("check Case");

      final userData = Provider.of<Users>(context, listen: false);

      final userinfo = userData.item;
      final String userId = userinfo[0].id;

      final tournamentInfo = Provider.of<Tournaments>(context, listen: false);

      final tournamentiform = tournamentInfo.item;
      tournamentId = tournamentiform[0].tournamentid;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose

    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Admin Finals"),
          backgroundColor: HexColor("#ffe664"),
        ),
        body: buildPageView());
  }
}
