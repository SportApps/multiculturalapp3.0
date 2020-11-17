import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:multiculturalapp/MyWidgets/TournamentInfoScr/addPlayer2.dart';

import '../progress.dart';

var tournamentInstance = Firestore.instance.collection("ourtournaments");
String player1;
String player1photo;
String player1ID;
String player1lvl;

class AddPlayer1 extends StatelessWidget {
  static const link = "/addPlayer1";

  //0.) Player is in Team

  handlePlayerOnTeamChange(String tournamentId, String photoUrl) {
    tournamentInstance
        .doc(tournamentId)
        .collection("participants")
        .where("photoUrl", isEqualTo: photoUrl)
        .get()
        .then((value) => value.documents.elementAt(0));
  }

  // 1.) PARTICIPANTS STREAMBUILDER
  handleParticipantListSnapshot(String tournamentId) {
    var querySnapshot = tournamentInstance
        .document(tournamentId)
        .collection("participants")
        .where("hasTeam", isEqualTo: false)
        .snapshots();

    return querySnapshot;
  }

  Flexible buildPlayer1(String _tournamentID, String _selectedCountry,
      String selectedCountryURL, BuildContext ctx) {
    print("This is the tourament ID $_tournamentID");
    return Flexible(
      child: StreamBuilder<QuerySnapshot>(
        stream: handleParticipantListSnapshot(_tournamentID),
        builder: (context, participantssnapshot) {
          if (participantssnapshot.connectionState == ConnectionState.waiting) {
            return circularProgress();
          } else {
            var _loadeddata = participantssnapshot.data.documents;

            print(_loadeddata);
            return GridView.builder(
              scrollDirection: Axis.vertical,
              itemCount: _loadeddata.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1 / 1.5,
              ),
              itemBuilder: (context, index) {
                var _loadeddataindexcontent = _loadeddata[index];
                return Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                          highlightColor: HexColor("#ffde03").withOpacity(0.3),
                          onTap: () {
                            player1 =
                                _loadeddataindexcontent.data()["username"];
                            player1photo =
                                _loadeddataindexcontent.data()["photoUrl"];
                            player1ID =
                                _loadeddataindexcontent.data()["userId"];
                            player1lvl =
                                _loadeddataindexcontent.data()["achievedlvl"];

                            print(player1lvl);
                            Navigator.of(context)
                                .pushNamed(AddPlayer2.link, arguments: {
                              "tournamentId": _tournamentID,
                              "selectedCountry": _selectedCountry,
                              "selectedCountryURL": selectedCountryURL,
                              "player1Name": player1,
                              "player1photo": player1photo,
                              "player1lvl": player1lvl,
                              "player1ID": player1ID
                            });
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              MediaQuery.of(context).size.width * 0.2,
                            ),
                            child: FadeInImage.assetNetwork(
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width * 0.24,
                                height:
                                    MediaQuery.of(context).size.width * 0.24,
                                fadeInDuration: Duration(seconds: 1),
                                placeholder: 'assets/images/volleychild.png',
                                imageErrorBuilder: (context, url, error) =>
                                    new Image.asset(
                                        "assets/images/volleychild.png"),
                                image:
                                    _loadeddataindexcontent.data()["photoUrl"]),
                          )),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Column(
                          children: <Widget>[
                            Text(
                              _loadeddataindexcontent.data()["username"],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black.withOpacity(0.6),
                                  fontSize: 18),
                              softWrap: true,
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              _loadeddataindexcontent.data()["achievedlvl"],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: HexColor("#ea070a").withOpacity(0.8)),
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routearguments =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    String tournamentId = routearguments["tournamentID"];
    String selectedCountry = routearguments["selectedCountry"];
    String selectedCountryURL = routearguments["selectedCountryURL"];

    print(tournamentId);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor("#ffe664"),
        centerTitle: true,
        title: Text(
          "Player 1",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.05,
                  bottom: MediaQuery.of(context).size.height * 0.05,
                ),
                child: Text(
                  "Choose an athlete!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.8)),
                )),
            buildPlayer1(
                tournamentId, selectedCountry, selectedCountryURL, context),
          ],
        ),
      ),
    );
  }
}
