import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hexcolor/hexcolor.dart';

import 'authExceptionHandler.dart';
import 'authResultStatus.dart';
import 'auth_form.dart';
import 'firebaseAuthHelper.dart';

class AuthScreen extends StatefulWidget {
  static const link = "/AuthScreen";

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;
  String logInErrorMessage;

  _loginErrerDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Log In Error"),
          content: new Text(errorMessage),
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

  _login(String email, String password) async {
    try {
      final status =
          await FirebaseAuthHelper().login(email: email, pass: password);
      if (status == AuthResultStatus.successful) {
        // Navigate to success page
      } else {
        final errorMsg = AuthExceptionHandler.generateExceptionMessage(status);
        _loginErrerDialog(errorMsg);
      }
    } on PlatformException catch (error) {
      _loginErrerDialog(error.message);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(error.message),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 3),
      ));
    }
  }

  void _submitAuthForm(
    String gender,
    String email,
    String password,
    String username,
    File image,
    bool isLogin,
    BuildContext ctx,
  ) async {
    UserCredential authResult;

    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        _login(email, password);
      } else {
        authResult = await _auth
            .createUserWithEmailAndPassword(
          email: email,
          password: password,
        )
            .catchError((e) {
          print("Catch error happens");

          Scaffold.of(ctx).showSnackBar(
            SnackBar(
              content: Text(
                  "An Error has occured. Probably the e-mail is already in use."),
              backgroundColor: Theme.of(ctx).errorColor,
            ),
          );

          print(e.details); // code, message, details
        });

        print("Image upload should start...");
        print(authResult.user.uid );

        final ref = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child(authResult.user.uid + '.jpg');

        await ref.putFile(image).onComplete;

        final url = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user.uid)
            .set({
          'username': username,
          'email': email,
          'photo_url': url,

          "gender": gender,
          "firstload": true,
          "achievedlvl": "Baby Beginner",
          "likes":0,
          "points": 0,
          "winLooseRatio": 0,
          "historyGamesLost": 0,
          "historyGamesWon": 0,
          "myStrength":"",
          "myFlaws":"",
          "myBlockDefense":"",
          "myExpectations":"",
        });
        print("User profile created");
      }
    } on PlatformException catch (err) {
      var message = 'An error occurred, pelase check your credentials!';

      if (err.message != null) {
        message = err.message;
      }

      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      print(err);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
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
      ),
      backgroundColor: Colors.white,
      body: AuthForm(
        _submitAuthForm,
        _isLoading,
      ),
    );
  }
}
