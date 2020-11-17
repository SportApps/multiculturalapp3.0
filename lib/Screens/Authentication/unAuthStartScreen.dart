import 'dart:io';

import 'package:flutter/material.dart';
import 'package:multiculturalapp/Screens/Authentication/auth_screen.dart';

class UnAuthStartScreen extends StatefulWidget {

  static const link ="/UnAuthStartScreen";

  @override
  _UnAuthStartScreenState createState() => _UnAuthStartScreenState();
}

class _UnAuthStartScreenState extends State<UnAuthStartScreen> {





  Container buildUnAuthIconElements(
      String descText, String assetLink, BuildContext ctx) {
    return Container(
      width: MediaQuery.of(ctx).size.width * 0.30,
      child: Column(
        children: <Widget>[
          Text(
            descText,
            style: TextStyle(color: Colors.white),
          ),
          CircleAvatar(
            radius: MediaQuery.of(ctx).size.width * 0.1,
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage(
              assetLink,
            ),
          ),
        ],
      ),
    );
  }

  Scaffold buildUnAuthScreen(BuildContext ctx) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: true,
      body: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: MediaQuery.of(ctx).size.height * 0.8,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fitHeight,
                image: AssetImage(
                  "assets/images/sunlogin.png",
                ),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(ctx).size.height * 0.6,
                  ),
                  Stack(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(ctx).size.height * 0.2,
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
                            width: MediaQuery.of(ctx).size.width * 0.10,
                          ),
                          Text(
                            "Free Register",
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            width: MediaQuery.of(ctx).size.width * 0.095,
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
                            width: MediaQuery.of(ctx).size.width * 0.10,
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
          ),

          // In this layer we visualize the Title of the app.
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.1,
              ),
              Container(
                width: double.infinity,
                height: MediaQuery.of(ctx).size.height * 0.2,
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      child: Text(
                        "Volley World",
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
                          height: 75,
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
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: MediaQuery.of(ctx).size.height * 0.8),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(ctx).size.height * 0.2,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(ctx).pushNamed(AuthScreen.link);
                            },
                            child: Text(
                              "Get started!",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 23),
                            ),
                          ),
                          Icon(
                            Icons.navigate_next,
                            size: 35,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }



  void noInternetDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("No internet connection"),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)),
          content: Text(
              "For the App to work, you need an internet connection."),
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


  tryInternetConnection ()async {
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

    @override
  void initState() {
    // TODO: implement initState
    super.initState();


    tryInternetConnection();


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false, body: buildUnAuthScreen(context));
  }
}
