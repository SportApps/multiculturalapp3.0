import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:multiculturalapp/MyWidgets/myAppBars/standardAppBar.dart';
import 'package:multiculturalapp/MyWidgets/progress.dart';
import 'package:multiculturalapp/MyWidgets/userInfoStartscreen.dart';
import 'package:multiculturalapp/Screens/home.dart';
import 'package:multiculturalapp/model/users.dart';

class LigaRAnking extends StatefulWidget {
  static const link = "/LigaRanking";

  @override
  _LigaRAnkingState createState() => _LigaRAnkingState();
}

class _LigaRAnkingState extends State<LigaRAnking> {
  bool _isloading;
  bool _isAdmin;
  String userName;
  String userlvl;
  List<List> top10List = [];

  //1.) Is Admin Test Function
  void checkIfAdmin(String lvlInput) {
    if (lvlInput == "Admin") {
      _isAdmin = true;
    } else {
      _isAdmin = false;
    }
  }

  void getTopLigaTop10() async {
    var fireUsers = await FirebaseFirestore.instance
        .collection("users")
        .orderBy("points", descending: true)
        .limit(10)
        .get();

    int NR = 0;

    double advancePorcent;
    for (var i = 0; i < fireUsers.docs.length; i++) {
      var fireUserNRdata = fireUsers.docs[NR];

      if (fireUserNRdata.data()["achievedLvl"] == "Baby Beginner") {
        advancePorcent = 0.125;
      }
      else if (fireUserNRdata.data()["achievedLvl"] == "Little Child") {
        advancePorcent = 0.25;
      }
      else if (fireUserNRdata.data()["achievedLvl"] == "Amateur") {
        advancePorcent = 0.5;
      }
      else if (fireUserNRdata.data()["achievedLvl"] == "Grown-Up") {
        advancePorcent = 0.625;
      }
     else if (fireUserNRdata.data()["achievedLvl"] == "Experienced") {
        advancePorcent = 0.75;
      }

     else if (fireUserNRdata.data()["achievedLvl"] == "Volley God") {
        advancePorcent = 1;
      }

      top10List.add([
        fireUserNRdata.data()["username"],
        fireUserNRdata.data()["points"],
        fireUserNRdata.data()["photoUrl"],
        NR + 1,
        fireUserNRdata.data()["achievedLvl"],
        advancePorcent,
      ]);
      NR++;
    }

    setState(() {
      _isloading = false;
      print(top10List);
    });
  }

  AppBar appBarbuilder() {
    return AppBar(
      backgroundColor: HexColor("ffe664"),
      centerTitle: true,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            child: Image(
              image: AssetImage("assets/images/smalllogo.png"),
            ),
          ),
          Text(
            "MVB",
            style: TextStyle(fontFamily: "Futura", fontSize: 20),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _isloading = true;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //0)Check is admin

      final userData = Provider.of<Users>(context, listen: false);

      userName = userData.item[0].username;
      userlvl = userData.item[0].lvl;
      checkIfAdmin(userlvl);

      getTopLigaTop10();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: appBarbuilder(),
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
                padding: EdgeInsets.symmetric(vertical: 30),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 15),
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image:
                                  AssetImage("assets/images/paulatrophy.png"))),
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          "Top 10",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.normal),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Liga Score",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.normal),
                        )
                      ],
                    ),
                  ],
                )),
            _isloading
                ? circularProgress()
                : Flexible(
                    child: ListView.builder(



                        itemCount: top10List.length,
                        itemBuilder: (context, i) {
                          var listInstance = top10List[i];
                          print(listInstance);

                          return Container(
                            height: MediaQuery.of(context).size.height * 0.2,
                            width: double.infinity,
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 15,
                                ),
                                CircleAvatar(
                                  radius: 25,
                                  backgroundColor:
                                      Colors.black.withOpacity(0.03),
                                  child: Text(
                                    top10List[i][3].toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    CustomPaint(
                                      painter: GradientArcPainter(
                                        startColor: HexColor("#ffe664"),
                                        endColor: Colors.red,
                                        progress: listInstance[5],
                                        width: 10,
                                      ),
                                      size: Size(
                                          MediaQuery.of(context).size.width *
                                              0.3,
                                          MediaQuery.of(context).size.width *
                                              0.3),
                                    ),
                                    CircleAvatar(
                                      radius:
                                          MediaQuery.of(context).size.width *
                                              0.125,
                                      backgroundImage:
                                          NetworkImage(top10List[i][2]),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  width: 40,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      top10List[i][0],
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Icon(Icons.star),
                                        Text(
                                          top10List[i][1].toString(),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      top10List[i][4],
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: HexColor("#ea070a"),
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                  )
          ],
        ),
      ),
    );
  }
}
