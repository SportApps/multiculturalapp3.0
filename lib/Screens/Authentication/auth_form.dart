import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import 'user_image_picker.dart';

class AuthForm extends StatefulWidget {
  AuthForm(
    this.submitFn,
    this.isLoading,
  );

  final bool isLoading;
  final void Function(
    String gender,
    String email,
    String password,
    String userName,
    File image,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _userEmail = '';
  var _userName = '';
  var _userPassword = '';
  var _userPasswordConfirm = "";
  bool unvalid;
  bool passwordResetOnce;
  File _userImageFile;
  bool passwordReset;

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

    if (!isValid) {
      unvalid = true;
    }

    if (isValid) {
      unvalid = false;
      _formKey.currentState.save();
      if (!passwordReset) {
      await  widget.submitFn(
          gender,
          _userEmail.trim(),
          _userPassword.trim(),
          _userName.trim(),
          _userImageFile,
          _isLogin,
          context,
        );
        Navigator.of(context).pop();
      }
    }
  }

  int _radioValue;
  String gender = "Male";

  void _handleRadioValueChange(int value) {
    setState(() {
      if (value == null) {
        value = 0;
      }

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    passwordReset = false;
    passwordResetOnce =false;
  }

  Future<void> changePassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                if (!_isLogin) UserImagePicker(_pickedImage, true, "No Photo"),
                if (!_isLogin) buildRadioGenderButton(),
                _isLogin
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15,
                      )
                    : SizedBox(
                        height: 0,
                      ),
                TextFormField(
                  key: ValueKey('email'),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  enableSuggestions: false,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email address.';
                    }

                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email address',
                  ),
                  onSaved: (value) {
                    _userEmail = value;
                  },
                ),
                if (!_isLogin)
                  TextFormField(
                    key: ValueKey('username'),
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
                      _userName = value;
                    },
                  ),
                if (_isLogin)
                  SizedBox(
                    height: 20,
                  ),
                if (!passwordReset)
                  TextFormField(
                    key: ValueKey('password'),
                    validator: (value) {
                      if (value.isEmpty || value.length < 7) {
                        return 'Password must be at least 7 characters long.';
                      }
                      if (value.isEmpty || value.length < 7) {
                        return 'Password must be at least 7 characters long.';
                      }
                      if (value.isNotEmpty) {
                        _userPassword = value;
                      }

                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    onSaved: (value) {
                      _userPassword = value;
                    },
                  ),
                if (!_isLogin)
                  TextFormField(
                    key: ValueKey('confirmPassword'),
                    validator: (value) {
                      if (value.isEmpty || value.length < 7) {
                        return 'Password must be at least 7 characters long.';
                      }
                      if (value != _userPassword) {
                        return 'The passwords do not match.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    onSaved: (value) {
                      _userPasswordConfirm = value;
                    },
                  ),
                SizedBox(height: 40),
                if (widget.isLoading) CircularProgressIndicator(),
                if (!widget.isLoading)
                  Column(
                    children: [
                      if (passwordReset && !passwordResetOnce)
                        RaisedButton(
                            child: Text("Reset password by mail"),
                            color: HexColor("#ffe664"),
                            onPressed: () async {
                              await _trySubmit();
                              print("trysubmit finished successfully");

                              if (!unvalid) {
                                await changePassword(_userEmail);
                                setState(() {
                                  passwordReset = false;
                                  passwordResetOnce =true;
                                });

                              }
                            }),
                      if (!passwordReset)
                        RaisedButton(
                          child: Text(_isLogin ? 'Log in' : 'Sign up'),
                          color: HexColor("#ffe664"),
                          onPressed: _trySubmit,
                        ),
                    ],
                  ),
                if (_isLogin &&!passwordResetOnce)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: FlatButton(
                      textColor: Theme.of(context).primaryColor,
                      child: Text(
                        passwordReset?
                        "I remember my password":"I forgot my password",
                        style: TextStyle(color: Colors.black.withOpacity(0.8)),
                      ),
                      onPressed: () {
                        setState(() {
                          passwordReset = !passwordReset;
                        });
                      },
                    ),
                  ),
                if (!widget.isLoading)
                  Container(
                    padding: EdgeInsets.only(top: 10),
                    child: FlatButton(
                      textColor: Theme.of(context).primaryColor,
                      child: Text(
                        _isLogin
                            ? 'Create new account'
                            : 'I already have an account',
                        style: TextStyle(color: Colors.black.withOpacity(0.8)),
                      ),
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          passwordReset =false;
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
