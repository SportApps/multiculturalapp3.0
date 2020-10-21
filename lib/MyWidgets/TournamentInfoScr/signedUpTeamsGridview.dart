import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../progress.dart';
import '../userInfoStartscreen.dart';

class SignedUpTeamsGridview extends StatelessWidget {
  SignedUpTeamsGridview({this.isloading, this.tournamentId});

  final bool isloading;

  final String tournamentId;

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
                Text(
                  "Teams registered",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.8),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
                            SizedBox(height: 5,),
                            Text("Whatsapp the organizer to register your team!."),
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

                            return InkWell(
                              onTap: () {
                                print("you clicked on a Country");
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
                                      _loadeddataindexcontent
                                          .data()["CountryName"],
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
