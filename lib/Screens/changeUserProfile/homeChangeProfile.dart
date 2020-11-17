import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multiculturalapp/Screens/changeUserProfile/profileForm.dart';

import '../home.dart';

class HomeChangeProfile extends StatefulWidget {
  static const link = "/HomeChangeProfile";

  @override
  _HomeChangeProfileState createState() => _HomeChangeProfileState();
}

class _HomeChangeProfileState extends State<HomeChangeProfile> {
  var UserFire = FirebaseFirestore.instance.collection('users');

  bool _isLoading;

  String myUserId;
  String myUserName;
  String myUserPhotoURL;
  String myGender;

  static const link = "/homeChangeProfile";

  void _submitAuthForm(
    String myUserId,
    String gender,
    String username,
    File image,
    BuildContext ctx,
  ) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final ref = FirebaseStorage.instance
          .ref()
          .child('user_image')
          .child(myUserId + '.jpg');

      await ref.putFile(image).onComplete;

      String url = await ref.getDownloadURL();

      if (url == null) {
        url = myUserPhotoURL;
      }


      await UserFire.doc(myUserId).update({
        'username': username,
        'gender': gender,
        'photo_url': url,
      });


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
        title: InkWell(
          onTap: () {
            Navigator.of(context).popAndPushNamed(Home.link);
          },
          child: Container(
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
      ),
      backgroundColor: Colors.white,
      body: ProfileForm(
        _submitAuthForm,
      ),
    );
  }
}
