import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:multiculturalapp/Screens/Authentication/unAuthStartScreen.dart';
import 'package:multiculturalapp/Screens/Authentication/user_image_picker.dart';
import 'package:multiculturalapp/Screens/home.dart';
import 'package:multiculturalapp/model/user.dart' as UserProvider;
import 'package:multiculturalapp/model/users.dart';
import 'package:provider/provider.dart';
import 'package:smart_select/smart_select.dart';

class ProfileForm extends StatefulWidget {
  ProfileForm(
    this.submitFn,
  );

  final void Function(
    String myUserId,
    String gender,
    String userName,
    File image,
    BuildContext ctx,
  ) submitFn;

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;

  bool _isloading;
  bool _isAdmin;
  String myUserId;
  String userName;
  String oldUserName;
  String myUserPhotoURL;
  String myGender;
  String achievedlvl;
  int historyGamesWon;
  int historyGamesLost;
  int points;
  int likes;
  double winLooseRatio;

// simple usage

  String myStrength = '';
  String myFlaws = '';
  String myBlockDefense = '';
  String myExpectations = "";
  List<S2Choice<String>> strengthOptions = [
    S2Choice<String>(value: 'Defense', title: 'Defense'),
    S2Choice<String>(value: 'Setting', title: 'Setting'),
    S2Choice<String>(value: 'Shooting', title: 'Shooting'),
    S2Choice<String>(value: 'Spiking', title: 'Spiking'),
    S2Choice<String>(value: 'Blocking', title: 'Blocking'),
  ];

  List<S2Choice<String>> BlockerorDefenseOptions = [
    S2Choice<String>(value: 'Blocker', title: 'I am usually the Blocker'),
    S2Choice<String>(value: 'Defense', title: 'I am usually the Defense'),
    S2Choice<String>(
        value: 'No Idea', title: 'Don´t know how blocking on beach works..'),
  ];

  List<S2Choice<String>> CompetetivenessOptions = [
    S2Choice<String>(value: 'Expect to win', title: 'I come to win.'),
    S2Choice<String>(
        value: 'Enjoy but play', title: 'I come to enjoy good matches. '),
    S2Choice<String>(value: 'Relax', title: "Relax, no expectations.")
  ];

  int _radioValue;

  File _userImageFile;

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _trySubmit() async {
    await FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState.validate();

    if (_userImageFile == null && !_isLogin) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Please pick an image.'),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }

    if (isValid) {
      _formKey.currentState.save();
      widget.submitFn(
        myUserId,
        myGender,
        userName.trim(),
        _userImageFile,
        context,
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(myUserId)
          .update({
        'username': userName,
        'gender': myGender,
        "myStrength": myStrength,
        "myFlaws": myFlaws,
        "myBlockDefense": myBlockDefense,
        "myExpectations": myExpectations,
      });

      UserProvider.User updatedUser = UserProvider.User();
      updatedUser.isAdmin = _isAdmin;
      updatedUser.id = myUserId;
      updatedUser.username = userName.trim();
      updatedUser.photoUrl = myUserPhotoURL;
      updatedUser.gender = myGender;
      updatedUser.historyGamesWon = historyGamesWon;
      updatedUser.points = points;
      updatedUser.achievedLvl = achievedlvl;
      updatedUser.historyGamesLost = historyGamesLost;
      updatedUser.winLooseRatio = winLooseRatio;
      updatedUser.myStrength = myStrength;
      updatedUser.myFlaw = myFlaws;
      updatedUser.myBlockDefense = myBlockDefense;
      updatedUser.myExpectations = myExpectations;
      updatedUser.myLikes = likes;

      final newUserInfo = Provider.of<Users>(context, listen: false);
      await newUserInfo.addUser(updatedUser);

      setState(() {
        _isloading = true;
      });
      Future.delayed(const Duration(milliseconds: 2000), () async {
        Navigator.of(context).popAndPushNamed(Home.link);
      });
    }
  }

  void _handleRadioValueChange(int value) {
    setState(() {
      if (value == null) {
        value = 0;
      }

      _radioValue = value;

      switch (_radioValue) {
        case 0:
          myGender = "Male";
          break;
        case 1:
          myGender = "Female";
          break;
        default:
          myGender = "Male";
      }
    });
  }

  Column buildRadioGenderButton() {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Radio(
              value: 0,
              groupValue: _radioValue,
              onChanged: _handleRadioValueChange,
              activeColor: HexColor("ffe664"),
            ),
            Text(
              'Male',
              style: new TextStyle(fontSize: 16.0),
            ),
            Radio(
              value: 1,
              groupValue: _radioValue,
              onChanged: _handleRadioValueChange,
              activeColor: HexColor("ffe664"),
            ),
            new Text(
              'Female',
              style: new TextStyle(
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  void _beforeDelteDialog() {
    // flutter defined function

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Log in with password before deliting account"),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          content: Text(
              "This operation is sensitive and requires recent authentication. Log in again before retrying this request."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Log -out"),
              onPressed: () async {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).popAndPushNamed(UnAuthStartScreen.link);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteAlertDialog() {
    // flutter defined function

    bool _proceed = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Delete Account"),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: 120,
            child: Text(
                "If you delete your account, all your user data will be lost."),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
                child: new Text(!_proceed ? "Confirm" : "Go back to Home",
                    style: TextStyle(color: Colors.blue.withOpacity(0.6))),
                onPressed: () async {
                  if (!_proceed) {
                    _proceed = !_proceed;
                    try {
                      // 1.) Delete Firestore Document.

                      FirebaseFirestore.instance
                          .collection("users")
                          .doc(myUserId)
                          .delete()
                          .then((value) async {
                        // 2.) Delete Firestorage Photo.try

                        final ref = FirebaseStorage.instance
                            .ref()
                            .child('user_image')
                            .child(myUserId + '.jpg');

                        await ref.delete().then((value) async {
                          //3.) Deelete Firebase Auth Reference
                          FirebaseAuth.instance.currentUser
                              .delete()
                              .then((value) async {
                            Navigator.of(context)
                                .popAndPushNamed(UnAuthStartScreen.link);
                          });
                        });
                      });
                    } catch (err) {
                      print("Error case");
                      _beforeDelteDialog();
                      Navigator.of(context).pop();
                    }
                  } else {
                    Navigator.of(context)
                        .popAndPushNamed(UnAuthStartScreen.link);
                  }
                  ;
                }),
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _isloading = true;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final userData = Provider.of<Users>(context, listen: false);

      final userinfo = userData.item;

      _isAdmin = userinfo[0].isAdmin;
      myUserId = userinfo[0].id;
      oldUserName = userinfo[0].username;
      myUserPhotoURL = userinfo[0].photoUrl;
      myGender = userinfo[0].gender;
      achievedlvl = userinfo[0].achievedLvl;
      historyGamesWon = userinfo[0].historyGamesWon;
      historyGamesLost = userinfo[0].historyGamesLost;
      points = userinfo[0].points;
      winLooseRatio = userinfo[0].winLooseRatio;
      likes = userinfo[0].myLikes;
      myStrength = userinfo[0].myStrength;
      myFlaws = userinfo[0].myFlaw;
      myBlockDefense = userinfo[0].myBlockDefense;
      myExpectations = userinfo[0].myExpectations;

      print("myStrength is $myBlockDefense");

      print(myStrength);

      if (myGender == "Male") {
        _radioValue = 0;
      } else {
        _radioValue = 1;
      }

      setState(() {
        _isloading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isloading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Updating Profile"),
                Text("this may take some seconds..."),
                SizedBox(
                  height: 20,
                ),
                CircularProgressIndicator(
                  backgroundColor: HexColor("#ffe664"),
                ),
              ],
            ),
          )
        : Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            color: Colors.white,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      UserImagePicker(_pickedImage, false, myUserPhotoURL),
                      buildRadioGenderButton(),
                      SmartSelect<String>.single(
                          title: 'My Best Skill',
                          value: myStrength,
                          choiceItems: strengthOptions,
                          modalType: S2ModalType.bottomSheet,
                          modalStyle:
                              S2ModalStyle(backgroundColor: Colors.white),
                          onChange: (state) =>
                              setState(() => myStrength = state.value)),
                      SmartSelect<String>.single(
                          title: 'My Biggest flaw',
                          value: myFlaws,
                          choiceItems: strengthOptions,
                          modalType: S2ModalType.bottomSheet,
                          modalStyle:
                              S2ModalStyle(backgroundColor: Colors.white),
                          onChange: (state) =>
                              setState(() => myFlaws = state.value)),
                      SmartSelect<String>.single(
                          title: 'Block-Defense',
                          value: myBlockDefense,
                          choiceItems: BlockerorDefenseOptions,
                          modalType: S2ModalType.bottomSheet,
                          modalStyle:
                              S2ModalStyle(backgroundColor: Colors.white),
                          onChange: (state) =>
                              setState(() => myBlockDefense = state.value)),
                      SmartSelect<String>.single(
                          title: 'Expectations',
                          value: myExpectations,
                          choiceItems: CompetetivenessOptions,
                          modalType: S2ModalType.bottomSheet,
                          modalStyle:
                              S2ModalStyle(backgroundColor: Colors.white),
                          onChange: (state) =>
                              setState(() => myExpectations = state.value)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: TextFormField(
                          key: ValueKey('username'),
                          initialValue: oldUserName,
                          autocorrect: true,
                          textCapitalization: TextCapitalization.words,
                          enableSuggestions: false,
                          validator: (value) {
                            if (value.isEmpty || value.length < 3) {
                              return 'Please enter at least 3 characters';
                            }
                            return null;
                          },
                          decoration: InputDecoration(labelText: 'Username'),
                          onSaved: (value) {
                            print(value);

                            userName = value;
                            print("UserName is saved! $userName");
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      if (_isloading) CircularProgressIndicator(),
                      RaisedButton(
                        child: Text("Update Profile Info"),
                        color: HexColor("#ffe664"),
                        onPressed: _trySubmit,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      FlatButton(
                          child: Text("Delete Profile",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.6))),
                          onPressed: () {
                            _deleteAlertDialog();
                          }),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
