import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:multiculturalapp/MyWidgets/TournamentInfoScr/tournamentinfo.dart';

import 'package:multiculturalapp/MyWidgets/clippingClass.dart';
import 'package:multiculturalapp/Screens/home.dart';

class CreateAccount extends StatefulWidget {
  static const link = "/CreateAccount";

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  bool showPage2;
  String myUserId;

  Column buildp1ExplainElement(String nr, String explanation) {
    return Column(
      children: <Widget>[
        Container(
          width: MediaQuery
              .of(context)
              .size
              .width * 0.15,
          height: MediaQuery
              .of(context)
              .size
              .height * 0.05,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 1, color: Colors.grey)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                nr,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 20),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 12,
        ),
        Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery
                    .of(context)
                    .size
                    .width * 0.2),
            child: Text(
              explanation,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
              ),
            )),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }

  Container buildp2explainElement(String nr, String title, String punkte) {
    return Container(
      padding: EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.08,
            height: MediaQuery
                .of(context)
                .size
                .width * 0.1,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 1, color: Colors.grey)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 25,
                  child: Text(
                    nr,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.1,
          ),
          Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.25,
              child: Text(
                title,
                textAlign: TextAlign.center,
              )),
          SizedBox(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.1,
          ),
          Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.2,
              child: Text(
                punkte,
                textAlign: TextAlign.center,
              ))
        ],
      ),
    );
  }

  Container buildPage1() {
    return Container(
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.fitHeight,
                                image: AssetImage(
                                    "assets/images/iniciallogo2.png"))),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      SizedBox(
                        height: 130
                      ),
                      Container(
                        width: double.infinity,
                        height: MediaQuery
                            .of(context)
                            .size
                            .height * 0.1,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Connect with a huge Volleyball commmunity in Barcelona!",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              buildp1ExplainElement(
                  "1", "Join an event in the Next Tournament section."),
              buildp1ExplainElement("2",
                  "You will find a fitting partner the day of the Tournament thanks to our point system."),
              buildp1ExplainElement(
                  "3", "Earn points and level up on every event you join"),

              Expanded(child: SizedBox(height: 20,),),
              Container(
                  height: 80,
                  width: double.infinity,
                  color: HexColor("#ffe664"),
                  child: ClipPath(
                    clipper: ClippingClass(),
                    child: Container(

                      color: Colors.white,
                    ),
                  )),
            ],
          )
        ],
      ),
    );
  }

  Column buildPage2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            padding: EdgeInsets.only(
                top: MediaQuery
                    .of(context)
                    .size
                    .height * 0.05),
            width: double.infinity,
            child: Text(
              "Level up!",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            )),
        SizedBox(
          height: 15,
        ),
        Container(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.13,
            height: MediaQuery
                .of(context)
                .size
                .width * 0.13,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 1, color: Colors.grey)),
            child: Icon(
              Icons.star,
              size: 25,
            )),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,
          child: Text(
            "Points",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              child: Text(
                "Match won - 1pt",
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: double.infinity,
              child: Text(
                "Gold match won - 3pt",
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: double.infinity,
              child: Text(
                "Tournament won - 10pt",
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.05,
            ),
            Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.13,
                height: MediaQuery
                    .of(context)
                    .size
                    .width * 0.13,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 1, color: Colors.grey)),
                child: Icon(
                  MdiIcons.trophyVariantOutline,
                  size: 25,
                )),
            Container(
              padding: EdgeInsets.only(top: 10),
              width: double.infinity,
              child: Text(
                "Ranking system",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            buildp2explainElement("1", "Baby Beginner", "0pts"),
            buildp2explainElement("2", "Amateur", "20vpts"),
            buildp2explainElement("3", "Experienced", "50pts"),
            buildp2explainElement("4", "Volley God", "100pts"),
          ],
        ),

        Expanded(child: SizedBox(height: 20,)),
        Container(

          height: 80,
          width: double.infinity,
          color: HexColor("#ffe664"),
          child: ClipPath(
            clipper: ClippingClass(),
            child: Container(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  changeFirstLoadState() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(myUserId)
        .update({"firstload": false});
  }

  @override
  void initState() {
    // TODO: implement initState

    showPage2 = false;

    super.initState();
  }

  @override
  Widget build(BuildContext parentContext) {
    myUserId = ModalRoute
        .of(context)
        .settings
        .arguments as String;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery
            .of(context)
            .size
            .height,
        width: double.infinity,
        color: Colors.white,
        padding: EdgeInsets.only(top: 30),
        child: Column(
          children: [

            SingleChildScrollView(
              child: Container(height: 620,
                width: double.infinity,
                child: !showPage2 ? buildPage1() : buildPage2(),),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
               
                color: HexColor("#ffe664"),
                child: FlatButton.icon(

                    onPressed: () {
                      setState(() {
                        if (!showPage2) {
                          showPage2 = true;
                          return;
                        } else {
                          changeFirstLoadState();
                          Navigator.of(context).popAndPushNamed(Home.link);
                        }
                      });
                    },
                    icon: Icon(
                      Icons.navigate_next,
                      color: Colors.black,
                    ),
                    label: Text(
                      "Next",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
