import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:multiculturalapp/MyWidgets/TournamentInfoScr/addPlayer1.dart';

import '../progress.dart';
import '../userInfoStartscreen.dart';

class SignedUpTeamsGridview extends StatelessWidget {
  SignedUpTeamsGridview({this.isloading, this.tournamentId});

  final bool isloading;

  final String tournamentId;

  String player1Name;
  String player1Photo;
  String player1lvl;

  String player2Name;
  String player2Photo;
  String player2lvl;

  String countryName;
  String countryFlag;

  var tournamentinstance =
      FirebaseFirestore.instance.collection("ourtournaments");

// 1.)Handle ParticipantList Container

  handleCountrySnap(String tournamentId) {
    var querySnapshot = FirebaseFirestore.instance
        .collection("ourtournaments")
        .doc(tournamentId)
        .collection("countries")
        .snapshots();

    return querySnapshot;
  }

  getCountryInfo(String clickedCountry) async {
    var fireCountry = await FirebaseFirestore.instance
        .collection("ourtournaments")
        .doc(tournamentId)
        .collection("countries")
        .doc(clickedCountry)
        .get();

    countryName = fireCountry.id;
    countryFlag = fireCountry.data()["CountryURL"];

    player1Name = fireCountry.data()["player1Name"];
    player1Photo = fireCountry.data()["player1Photo"];
    player1lvl = fireCountry.data()["player1lvl"];

    player2Name = fireCountry.data()["player2Name"];
    player2Photo = fireCountry.data()["player2Photo"];
    player2lvl = fireCountry.data()["player2lvl"];
  }

  createInfoPlayerAlert(BuildContext context) {
    // flutter defined function
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          scrollable: true,
          title: Container(
            width: double.infinity,
            child: Text(
              countryName,
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 20, color: Colors.black.withOpacity(0.8)),
            ),
          ),
          content: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  countryPlayerInfoElement(player1Photo, player1Name,player1lvl),
                  countryPlayerInfoElement(player2Photo, player2Name,player2lvl),
                ],
              ),
            ],
          ),
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

  Column countryPlayerInfoElement(String playerPhoto, String playerName,String playerLvl) {
    return Column(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(playerPhoto),
          radius: 40,
        ),
        Container(
            padding: EdgeInsets.only(top: 5),
            child: Text(
              playerName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: Colors.black.withOpacity(0.8)),
            )),
        Container(
            padding: EdgeInsets.only(top: 5),
            child: Text(
              playerLvl,
              style: TextStyle( fontSize: 14),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 30,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            child: Row(
              children: [
                Icon(MdiIcons.accountGroup),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Teams registered",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.8),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Whatsapp organizer to create team!",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          isloading
              ? circularProgress()
              : Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  height: 140,
                  color: Colors.white.withOpacity(0.7),
                  width: double.infinity,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: handleCountrySnap(tournamentId),
                    builder: (context, countrysnap) {
                      if (countrysnap.connectionState ==
                          ConnectionState.waiting) {
                        return circularProgress();
                      } else if (countrysnap.data.size == 0) {
                        return Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "No Teams registered yet",
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.8),
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                                "Whatsapp the organizer to register your team!."),
                          ],
                        ));
                      } else {
                        var _loadeddata = countrysnap.data.docs;

                        return GridView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _loadeddata.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1, childAspectRatio: 1.25),
                          itemBuilder: (context, index) {
                            var _loadeddataindexcontent = _loadeddata[index];

                            countryName = _loadeddataindexcontent.id;

                            return InkWell(
                              onTap: () async {
                                print("you clicked on a Country");
                                await getCountryInfo(
                                    _loadeddataindexcontent.id);
                                createInfoPlayerAlert(context);
                              },
                              child: Container(
                                padding: EdgeInsets.only(top: 5),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                        margin: EdgeInsets.only(
                                            top: 20, bottom: 10),
                                        width: 90,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(
                                                  _loadeddataindexcontent
                                                      .data()["CountryURL"])),
                                        )),
                                    Text(
                                      countryName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.black.withOpacity(0.8)),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
