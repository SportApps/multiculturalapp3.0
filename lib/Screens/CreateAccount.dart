import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:multiculturalapp/MyWidgets/clippingClass.dart';
import 'package:multiculturalapp/Screens/home.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  bool showPage2;
  int _radioValue;
  String username;
  String gender;


  Column buildp1ExplainElement(String nr, String explanation) {
    return Column(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.15,
          height: MediaQuery.of(context).size.height * 0.05,
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
          height: 15,
        ),
        Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.2),
            child: Text(
              explanation,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
              ),
            )),
        SizedBox(
          height: 20,
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
            width: MediaQuery.of(context).size.width * 0.08,
            height: MediaQuery.of(context).size.width * 0.1,
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
            width: MediaQuery.of(context).size.width * 0.1,
          ),
          Container(
              width: MediaQuery.of(context).size.width * 0.25,
              child: Text(
                title,
                textAlign: TextAlign.center,
              )),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.1,
          ),
          Container(
              width: MediaQuery.of(context).size.width * 0.2,
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
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: MediaQuery.of(context).size.height * 0.2,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.fitHeight,
                                image: AssetImage(
                                    "assets/images/iniciallogo.png"))),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.225,
                      ),
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.1,
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
                  "You will find a fitting partner the day of the toruanemnt thanks to our point system."),
              buildp1ExplainElement(
                  "3", "Earn points and level up on every event you join"),
            ],
          )
        ],
      ),
    );
  }

  Container buildPage2() {
    return Container(
      height: 900,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.05),
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
              width: MediaQuery.of(context).size.width * 0.13,
              height: MediaQuery.of(context).size.width * 0.13,
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
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Container(
                  width: MediaQuery.of(context).size.width * 0.13,
                  height: MediaQuery.of(context).size.width * 0.13,
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
                height: MediaQuery.of(context).size.height * 0.025,
              ),
              buildp2explainElement("1", "Baby Beginner", "0pts"),
              buildp2explainElement("2", "Amateur", "20vpts"),
              buildp2explainElement("3", "Experienced", "50pts"),
              buildp2explainElement("4", "Volley God", "100pts"),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Flexible(
            child: Stack(
              children: <Widget>[
                Container(
                  color: HexColor("#ffe664"),
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height * 0.1,
                      ),
                      Container(
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.025,
                                  ),
                                  Center(
                                    child: Text(
                                      "Create a username",
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          color: Colors.black.withOpacity(0.8)),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.025,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Container(
                                      child: Form(
                                        key: _formKey,
                                        autovalidate: true,
                                        child: Column(
                                          children: [
                                            TextFormField(
                                              keyboardType: TextInputType.text,
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              validator: (val) {
                                                if (val.trim().length < 3 ||
                                                    val.isEmpty) {
                                                  return "Username too short";
                                                } else if (val.trim().length >
                                                    10) {
                                                  return "Username too long";
                                                } else {
                                                  return null;
                                                }
                                              },

                                              onSaved: (val) => username = val,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: "Username",
                                                labelStyle:
                                                    TextStyle(fontSize: 15.0),
                                                hintText:
                                                    "Must be at least 3 characters",
                                              ),
                                            ),
                                            buildRadioGenderButton(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.025,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.075,
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
            ),
          ),
        ],
      ),
    );
  }



  void _handleRadioValueChange(int value) {
    setState(() {
      if(value == null){value =0;}

      _radioValue = value;

      switch (_radioValue) {
        case 0:
          gender = "Male";
          break;
        case 1:
          gender = "Female";
          break;
        default:
          gender = "Male";
      }
    });
  }

  Row buildRadioGenderButton() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Radio(
          value: 0,
          groupValue: _radioValue,
          onChanged: _handleRadioValueChange,
          activeColor: Colors.red.withOpacity(0.8),
        ),
        Text(
          'Male',
          style: new TextStyle(fontSize: 16.0),
        ),
        Radio(
          value: 1,
          groupValue: _radioValue,
          onChanged: _handleRadioValueChange,
          activeColor: Colors.red.withOpacity(0.8),
        ),
        new Text(
          'Female',
          style: new TextStyle(
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }

  submit() {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      List<String> aditionalUserData = [username, gender];
      SnackBar snackbar = SnackBar(content: Text("Welcome $username!"));
      _scaffoldKey.currentState.showSnackBar(snackbar);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, aditionalUserData);
        Navigator.of(context).pushNamed(Home.link);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    showPage2 = false;
    _radioValue =0;
    gender = "Male";
    super.initState();
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        color: Colors.white,
        child: Container(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  !showPage2 ? buildPage1() : buildPage2(),
                  FlatButton.icon(
                      onPressed: () {
                        setState(() {
                          if (!showPage2) {
                            showPage2 = true;
                            return;
                          } else {
                            submit();
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
                      ))
                ],
              ),
            )),
      ),
    );
  }
}
