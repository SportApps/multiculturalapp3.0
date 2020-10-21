import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:multiculturalapp/MyWidgets/TournamentInfoScr/tournamentinfo.dart';
import 'package:multiculturalapp/MyWidgets/clippingClass.dart';
import 'package:multiculturalapp/MyWidgets/progress.dart';
import 'package:multiculturalapp/Screens/home.dart';
import 'package:multiculturalapp/model/tournaments.dart';
import 'package:multiculturalapp/model/users.dart';

class AddTournamentScreen extends StatefulWidget {
  static const link = "/addTournamentScreen";

  @override
  _AddTournamentScreenState createState() => _AddTournamentScreenState();
}

class _AddTournamentScreenState extends State<AddTournamentScreen> {
  var tournamentInstance = Firestore.instance.collection("ourtournaments");

  bool _fotoselected = false;

  bool _firstLoad;

  bool _isLoading;

  int maxParticipants;

  String genderOnly;

  String fotoLink =
      "https://firebasestorage.googleapis.com/v0/b/tournament-2020.appspot.com/o/image1.png?alt=media&token=e874525d-9a8c-43bf-b25f-39d9083e4d8c";

  String tournamentName;

  String tournamentId;

  String level;

  String location;

  String startingHour;

  String finishingHour;

  String price;

  String description;

  String organizerName;

  String whatsappNr;

  DateTime selectedDate = DateTime.now();

  String newFormat = "";

  final _nameFocusNote = FocusNode();

  final _maxParticipantsFocusNote = FocusNode();

  final _locationFocusNote = FocusNode();

  final _priceFocusNote = FocusNode();

  final _descriptionFocusNote = FocusNode();

  final _organizerNameFocusNote = FocusNode();

  final _whatsappNRFocusNode = FocusNode();

  final _formkey = GlobalKey<FormState>();

  @override
  // We need to add this dispose Method here to avoid memory leaks
  void dispose() {
    _nameFocusNote.dispose();

    _locationFocusNote.dispose();
    _maxParticipantsFocusNote.dispose();
    _priceFocusNote.dispose();
    _descriptionFocusNote.dispose();
    _organizerNameFocusNote.dispose();
    _whatsappNRFocusNode.dispose();
    super.dispose();
  }

  int _radioValue = 0;

  void _handleRadioValueChange(int value) {
    setState(() {
      _radioValue = value;

      switch (_radioValue) {
        case 0:
          genderOnly = "Male";
          break;
        case 1:
          genderOnly = "Female";
          break;
        case 2:
          genderOnly = "Mixt Sex";
          break;
        case 3:
          genderOnly = "Mixt Sex-Open";
          break;
      }
    });
  }

  Column buildRadioGenderButton2() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            "Choose tournament type",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black.withOpacity(0.8)),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.2),
          width: double.infinity,
          child: Row(
            children: <Widget>[
              Container(
                width: 90,
                child: Row(
                  children: [
                    Radio(
                      value: 0,
                      groupValue: _radioValue,
                      onChanged: _handleRadioValueChange,
                      activeColor: Colors.red.withOpacity(0.8),
                    ),
                    Text(
                      'Male',
                      style: new TextStyle(fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Row(
                children: [
                  Radio(
                    value: 1,
                    groupValue: _radioValue,
                    onChanged: _handleRadioValueChange,
                    activeColor: Colors.red.withOpacity(0.8),
                  ),
                  new Text(
                    'Female',
                    style: new TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.2),
          width: double.infinity,
          child: Row(
            children: [
              Container(
                width: 90,
                child: Row(
                  children: [
                    Radio(
                      value: 2,
                      groupValue: _radioValue,
                      onChanged: _handleRadioValueChange,
                      activeColor: Colors.red.withOpacity(0.8),
                    ),
                    new Text(
                      'Mixt',
                      style: new TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Row(
                children: [
                  Radio(
                    value: 3,
                    groupValue: _radioValue,
                    onChanged: _handleRadioValueChange,
                    activeColor: Colors.red.withOpacity(0.8),
                  ),
                  new Text(
                    'Open',
                    style: new TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  int _radioValue2 = 0;

  void _handleLevelChange(int value) {
    setState(() {
      _radioValue2 = value;

      switch (_radioValue2) {
        case 0:
          level = "Beginner";
          break;
        case 1:
          level = "Amateur+";
          break;
        case 2:
          level = "Experienced+";
          break;
        case 3:
          level = "Open";
          break;
      }
    });
  }

  Column buildLevelChange() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(vertical: 20),
          child: Text(
            "Choose level",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black.withOpacity(0.8)),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.045),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Row(
                  children: [
                    Radio(
                      value: 0,
                      groupValue: _radioValue2,
                      onChanged: _handleLevelChange,
                      activeColor: Colors.red.withOpacity(0.8),
                    ),
                    Text(
                      'Beginner',
                      style: new TextStyle(fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.005,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Row(
                  children: [
                    Radio(
                      value: 1,
                      groupValue: _radioValue2,
                      onChanged: _handleLevelChange,
                      activeColor: Colors.red.withOpacity(0.8),
                    ),
                    new Text(
                      'Amateur+',
                      style: new TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.045),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Row(
                  children: [
                    Radio(
                      value: 2,
                      groupValue: _radioValue2,
                      onChanged: _handleLevelChange,
                      activeColor: Colors.red.withOpacity(0.8),
                    ),
                    new Text(
                      'Experienced+',
                      style: new TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.005,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Row(
                  children: [
                    Radio(
                      value: 3,
                      groupValue: _radioValue2,
                      onChanged: _handleLevelChange,
                      activeColor: Colors.red.withOpacity(0.8),
                    ),
                    Text(
                      'Open',
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  void _saveForm() async {
    // This triggers all the validators in the Form.
    final isvalid = _formkey.currentState.validate();

    if (!isvalid) {
      print("Form is not valid");
      return;
    }
    // If the Formstate is not valid go out of the function without doing anything. Return is exit here.
    if (_firstLoad == false) {
      print("Firstload false case.Data is saved with old Id");
      var routeArgs =
          ModalRoute.of(context).settings.arguments as Map<String, dynamic>;

      tournamentId = routeArgs["tournamentId"];
      print(tournamentId);
      // We refer to the in this class created _form Global KEy Variable.
      _formkey.currentState.save();

      print("Masparticipants are $maxParticipants");
      await FirebaseFirestore.instance
          .collection("ourtournaments")
          .doc(tournamentId)
          .set({
        "name": tournamentName,
        "genderOnly": genderOnly,
        "maxParticipants": maxParticipants,
        "niveles": level,
        "location": location,
        "date": selectedDate,
        "startingHour": timeText,
        "finishHour": timeText2,
        "description": description,
        "fotoLink": fotoLink,
        "price": price,
        "tournamentId": tournamentId,
        "organizerName": organizerName,
        "whatsAppNR": whatsappNr
      }, SetOptions(merge: true));
    } else {
      print("NEW CASE - We are creating a new tournament here.");

      // We refer to the in this class created _form Global KEy Variable.
      _formkey.currentState.save();

      print("Startinghour is $startingHour");
      await FirebaseFirestore.instance
          .collection("ourtournaments")
          .doc(tournamentName + "_" + newFormat + "_" + timeText)
          .set({
        "name": tournamentName,
        "genderOnly": genderOnly,
        "maxParticipants": maxParticipants,
        "niveles": level,
        "location": location,
        "date": selectedDate,
        "startingHour": timeText,
        "finishHour": timeText2,
        "description": description,
        "fotoLink": fotoLink,
        "price": price,
        "tournamentId": tournamentName + "_" + newFormat + "_" + timeText,
        "organizerName": organizerName,
        "whatsAppNR": whatsappNr
      }, SetOptions(merge: true));
    }

    setState(() {});
    Navigator.of(context).popAndPushNamed(Home.link);
  }

  _myselectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate, // Refer step 1
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 15)));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;

        newFormat = DateFormat("dd-MM-yyyy").format(selectedDate);
      });
  }

  TimeOfDay _currentTime = new TimeOfDay.now();

  String timeText;
  String timeText2;

  Future<Null> selectTime(BuildContext ctx) async {
    TimeOfDay selectedTime = await showTimePicker(
      context: ctx,
      initialTime: _currentTime,
      helpText: 'START EVENT AT',
      initialEntryMode: TimePickerEntryMode.input,
    );

    MaterialLocalizations localizations = MaterialLocalizations.of(context);
    if (selectedTime != null) {
      String formattedTime = localizations.formatTimeOfDay(selectedTime,
          alwaysUse24HourFormat: true);
      if (formattedTime != null) {
        setState(() {
          timeText = formattedTime;
        });
      }
    }
  }

  Future<Null> selectedfinishTime(BuildContext context) async {
    TimeOfDay selectedTime2 = await showTimePicker(
      context: context,
      initialTime: _currentTime,
      helpText: 'FINISH EVENT AT',
      initialEntryMode: TimePickerEntryMode.input,
    );

    MaterialLocalizations localizations = MaterialLocalizations.of(context);
    if (selectedTime2 != null) {
      String formattedTime = localizations.formatTimeOfDay(selectedTime2,
          alwaysUse24HourFormat: true);
      if (formattedTime != null) {
        setState(() {
          timeText2 = formattedTime;
        });
      }
    }
  }

  void setCurrentTime() {
    TimeOfDay selectedTime = new TimeOfDay.now();
    MaterialLocalizations localizations = MaterialLocalizations.of(context);
    String formattedTime = localizations.formatTimeOfDay(selectedTime,
        alwaysUse24HourFormat: true);
    if (formattedTime != null) {
      setState(() {
        timeText = formattedTime;
        timeText2 = formattedTime;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    _isLoading = true;
    tournamentName = "";
    maxParticipants = 0;
    level = "";
    location = "";
    newFormat = "";
    startingHour = "";
    finishingHour = "";
    price = "";
    description = "";
    organizerName = "";
    whatsappNr = "";
    genderOnly = "Male";

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final userData = Provider.of<Users>(context, listen: false);

      final userinfo = userData.item;
      organizerName = userinfo[0].displayName;

      //0)Check is admin
      final routearguments =
          ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
      _firstLoad = routearguments["firstLoad"];

      print("First load is $_firstLoad");
      if (_firstLoad == true) {
        print("Firstload is true - no loading");

        timeText = "Beginning";
        timeText2 = "End";
        setState(() {
          _isLoading = false;
        });
      }

      if (_firstLoad == false) {
        //Tournament Provider data
        final tournamentData = Provider.of<Tournaments>(context, listen: false);
        final tournamentInfo = tournamentData.item;
        tournamentName = tournamentInfo[0].name;
        maxParticipants = tournamentInfo[0].maxParticipants;
        genderOnly = tournamentInfo[0].genderOnly;
        if (genderOnly == "Male") {
          _radioValue = 0;
        } else if (genderOnly == "Female") {
          _radioValue = 1;
        } else if (genderOnly == "Mixt") {
          _radioValue = 2;
        } else {
          _radioValue = 3;
        }
        level = tournamentInfo[0].niveles;
        if (level == "Beginner") {
          _radioValue2 = 0;
        } else if (level == "Amateur+") {
          _radioValue2 = 1;
        } else if (level == "Experienced+") {
          _radioValue2 = 2;
        } else {
          _radioValue2 = 3;
        }
        location = tournamentInfo[0].location;
        newFormat = tournamentInfo[0].date;
        startingHour = tournamentInfo[0].startingHour;
        finishingHour = tournamentInfo[0].finishHour;
        timeText = startingHour;
        timeText2 = finishingHour;
        print(finishingHour);
        price = tournamentInfo[0].price;
        description = tournamentInfo[0].description;
        organizerName = tournamentInfo[0].organizerName;
        whatsappNr = tournamentInfo[0].whatsAppNR;
        tournamentId = tournamentInfo[0].tournamentid;

        setState(() {
          _isLoading = false;
        });

        print("Firstload is false -  loading");
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: HexColor("#ffe664"),
          centerTitle: true,
          title: Text(
            "New Tournament",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.8)),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.save,
                size: 30,
                color: Colors.black,
              ),
              onPressed: () {
                _saveForm();
                // do something
              },
            )
          ],
        ),
        body: _isLoading
            ? circularProgress()
            : SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(top: 50),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(bottom: 5),
                        width: double.infinity,
                        child: Text(
                          "Select an image",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.05),
                        height: MediaQuery.of(context).size.height * 0.15,
                        width: double.infinity,
                        // If foto is not selected yet...
                        child: !_fotoselected
                            ? StreamBuilder(
                                stream: Firestore.instance
                                    .collection("images")
                                    .snapshots(),
                                builder: (context, tsnapshot) {
                                  if (tsnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return circularProgress();
                                  }

                                  var _loadeddata = tsnapshot.data.documents;

                                  return GridView.builder(
                                      itemCount: _loadeddata.length,
                                      scrollDirection: Axis.horizontal,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 1,
                                              childAspectRatio: 1),
                                      itemBuilder: (ctx, i) {
                                        var _loadeddataSingle = _loadeddata[i];
                                        print(_loadeddataSingle);

                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              fotoLink = _loadeddataSingle
                                                  .data()["url"];
                                              print(i);
                                              print(fotoLink);
                                              print(_fotoselected);
                                              _fotoselected = !_fotoselected;
                                            });
                                          },
                                          child: Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                        _loadeddataSingle
                                                            .data()["url"]))),
                                          ),
                                        );
                                      });
                                })
                            : Container(
                                width: double.infinity,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: NetworkImage(fotoLink))),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      buildRadioGenderButton2(),
                      buildLevelChange(),
                      // Max Participants Field

                      Container(
                        height: MediaQuery.of(context).size.height * 1.8,
                        width: double.infinity,
                        child: Form(
                          key: _formkey,
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 20),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: Text(
                                          "Max Athlets",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 15),
                                        )),
                                    Flexible(
                                      child: TextFormField(
                                          textAlign: TextAlign.center,
                                          // The return statement of our validator argument is automatically our error message.
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return "Please enter value!";
                                            }
                                            return null;
                                          },
                                          initialValue:
                                              maxParticipants.toString(),
                                          keyboardType: TextInputType.number,
                                          // The textInputAction determines what happens if we finish to fill out the input field. in this case we go to the next field of the form.
                                          textInputAction: TextInputAction.next,
                                          focusNode: _maxParticipantsFocusNote,
                                          //Here we tell the App to Focus Scope on the _pricefocusnote.
                                          onFieldSubmitted: (_) {
                                            FocusScope.of(context)
                                                .requestFocus(_nameFocusNote);
                                          },
                                          //We use the "onSaved argument to
                                          // Here we take the _editProduct (which is an empty product) and overwrite it with a new Product
                                          onSaved: (val) {
                                            maxParticipants = int.parse(val);
                                            print(maxParticipants);
                                          }),
                                    ),
                                  ],
                                ),
                              ),

                              //1.) TournamentName
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 20),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: Text(
                                          "Name",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 15),
                                        )),
                                    Flexible(
                                      child: TextFormField(

                                          // The return statement of our validator argument is automatically our error message.
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return "Please enter value!";
                                            }
                                            if (value.length > 12) {
                                              return "Please enter a title with less than 12 Characters.";
                                            }

                                            return null;
                                          },
                                          initialValue: tournamentName,
                                          keyboardType: TextInputType.text,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          // The textInputAction determines what happens if we finish to fill out the input field. in this case we go to the next field of the form.
                                          textInputAction: TextInputAction.next,
                                          //Here we tell the App to Focus Scope on the _pricefocusnote.
                                          onFieldSubmitted: (_) {
                                            FocusScope.of(context).requestFocus(
                                                _locationFocusNote);
                                          },
                                          //We use the "onSaved argument to
                                          // Here we take the _editProduct (which is an empty product) and overwrite it with a new Product
                                          onSaved: (value) {
                                            tournamentName = value;
                                          }),
                                    ),
                                  ],
                                ),
                              ),

                              //3.) Location Textfield
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 20),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: Text(
                                          "Location",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 15),
                                        )),
                                    Flexible(
                                      child: TextFormField(

                                          // The return statement of our validator argument is automatically our error message.
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return "Please enter value!";
                                            }
                                            if (value.length > 15) {
                                              return "Please enter a location with less than 20 Characters.";
                                            }
                                            return null;
                                          },
                                          initialValue: location,
                                          keyboardType: TextInputType.text,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          // The textInputAction determines what happens if we finish to fill out the input field. in this case we go to the next field of the form.
                                          textInputAction: TextInputAction.next,
                                          focusNode: _locationFocusNote,
                                          //Here we tell the App to Focus Scope on the _pricefocusnote.
                                          onFieldSubmitted: (_) {
                                            FocusScope.of(context)
                                                .requestFocus(_priceFocusNote);
                                          },
                                          //We use the "onSaved argument to
                                          // Here we take the _editProduct (which is an empty product) and overwrite it with a new Product
                                          onSaved: (value) {
                                            location = value;
                                          }),
                                    ),
                                  ],
                                ),
                              ),

//4.) Date Textfieldv
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 20),
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: Text(
                                          "Date",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 15),
                                        )),
                                    Flexible(
                                      child: InkWell(
                                        onTap: () {
                                          _myselectDate(context);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border(
                                            bottom: BorderSide(
                                                width: 1.0,
                                                color: Colors.black45),
                                          )),
                                          width: double.infinity,
                                          child: Text(newFormat.toString()),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              //5.) Starting Hou and Finishing Hour Textfields
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 20),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: Text(
                                          "Time",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 15),
                                        )),
                                    InkWell(
                                      onTap: () {
                                        selectTime(context);
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                        child: Text(timeText),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.1,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        selectedfinishTime(context);
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                        child: Text(timeText2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                margin: EdgeInsets.symmetric(vertical: 20),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        child: Text(
                                          "Price",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 15),
                                        )),
                                    Flexible(
                                      child: TextFormField(

                                          // The return statement of our validator argument is automatically our error message.
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return "Please enter value!";
                                            }
                                            return null;
                                          },
                                          initialValue: price,
                                          keyboardType:
                                              TextInputType.numberWithOptions(),
                                          // The textInputAction determines what happens if we finish to fill out the input field. in this case we go to the next field of the form.
                                          textInputAction: TextInputAction.next,
                                          focusNode: _priceFocusNote,
                                          //Here we tell the App to Focus Scope on the _pricefocusnote.
                                          onFieldSubmitted: (_) {
                                            FocusScope.of(context).requestFocus(
                                                _descriptionFocusNote);
                                          },
                                          //We use the "onSaved argument to
                                          // Here we take the _editProduct (which is an empty product) and overwrite it with a new Product
                                          onSaved: (value) {
                                            price = value;
                                          }),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.05),
                                child: TextFormField(

                                    // The return statement of our validator argument is automatically our error message.
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return "Please enter value!";
                                      }
                                      return null;
                                    },
                                    initialValue: description,
                                    decoration: InputDecoration(
                                        labelText: "Description"),
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    keyboardType: TextInputType.multiline,
                                    // The textInputAction determines what happens if we finish to fill out the input field. in this case we go to the next field of the form.
                                    textInputAction: TextInputAction.next,
                                    focusNode: _descriptionFocusNote,
                                    maxLines: 4,
                                    //Here we tell the App to Focus Scope on the _pricefocusnote.
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context).requestFocus(
                                          _organizerNameFocusNote);
                                    },
                                    //We use the "onSaved argument to
                                    // Here we take the _editProduct (which is an empty product) and overwrite it with a new Product
                                    onSaved: (value) {
                                      description = value;
                                    }),
                              ),
                              Flexible(
                                child: Container(
                                  color: HexColor("#ffe664"),
                                  child: Stack(
                                    children: <Widget>[
                                      ClipPath(
                                        clipper: ClippingClass(),
                                        child: Container(
                                          width: double.infinity,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.1,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Column(
                                        children: <Widget>[
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.15),
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical: 20),
                                            width: double.infinity,
                                            child: Text(
                                              "Organizer",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3,
                                                  child: Text(
                                                    "Name",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        TextStyle(fontSize: 15),
                                                  )),
                                              Flexible(
                                                child: TextFormField(

                                                    // The return statement of our validator argument is automatically our error message.
                                                    validator: (value) {
                                                      if (value.isEmpty) {
                                                        return "Please enter value!";
                                                      }
                                                      if (value.length > 10) {
                                                        return "Please enter a name with less than 35 Characters.";
                                                      }
                                                      return null;
                                                    },
                                                    initialValue: organizerName,
                                                    enabled: false,
                                                    keyboardType:
                                                        TextInputType.text,
                                                    textCapitalization:
                                                        TextCapitalization
                                                            .words,
                                                    // The textInputAction determines what happens if we finish to fill out the input field. in this case we go to the next field of the form.
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    focusNode:
                                                        _organizerNameFocusNote,
                                                    //Here we tell the App to Focus Scope on the _pricefocusnote.
                                                    onFieldSubmitted: (_) {
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              _whatsappNRFocusNode);
                                                    },
                                                    //We use the "onSaved argument to
                                                    // Here we take the _editProduct (which is an empty product) and overwrite it with a new Product
                                                    onSaved: (value) {
                                                      organizerName = value;
                                                    }),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3,
                                                  child: Text(
                                                    "WhatsApp",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        TextStyle(fontSize: 15),
                                                  )),
                                              Flexible(
                                                child: TextFormField(

                                                    // The return statement of our validator argument is automatically our error message.
                                                    validator: (value) {
                                                      if (value.isEmpty) {
                                                        return "Please enter value!";
                                                      }
                                                      if (value.length > 12) {
                                                        return "Please enter a number with less than 12 Characters.";
                                                      }
                                                      return null;
                                                    },
                                                    initialValue: whatsappNr,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    textCapitalization:
                                                        TextCapitalization
                                                            .words,
                                                    // The textInputAction determines what happens if we finish to fill out the input field. in this case we go to the next field of the form.
                                                    textInputAction:
                                                        TextInputAction.done,
                                                    focusNode:
                                                        _whatsappNRFocusNode,
                                                    //Here we tell the App to Focus Scope on the _pricefocusnote.
                                                    onFieldSubmitted: (_) {
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                    },
                                                    //We use the "onSaved argument to
                                                    // Here we take the _editProduct (which is an empty product) and overwrite it with a new Product
                                                    onSaved: (value) {
                                                      whatsappNr = value;
                                                    }),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.05,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ));
  }
}
