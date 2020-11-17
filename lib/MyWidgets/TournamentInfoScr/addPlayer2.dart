import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:multiculturalapp/MyWidgets/TournamentInfoScr/ConfirmTeam.dart';

import '../progress.dart';

var tournamentInstance = Firestore.instance.collection("ourtournaments");
String player2;
String player2photo;
String player2ID;
String player2lvl;

class AddPlayer2 extends StatelessWidget {
  static const link = "/addPlayer2";

  // 1.) PARTICIPANTS STREAMBUILDER
  handleParticipantListSnapshot(String tournamentId) {
    var querySnapshot = tournamentInstance
        .doc(tournamentId)
        .collection("participants")
        .where("hasTeam", isEqualTo: false)
        .snapshots();

    return querySnapshot;
  }

  Flexible buildPlayer2(
      String _tournamentID,
      String selectedCountry,
      String selectedCountryURL,
      String player1Name,
      String player1Photo,
      String player1lvl,
      String player1ID) {
    return Flexible(
      child: StreamBuilder<QuerySnapshot>(
        stream: handleParticipantListSnapshot(_tournamentID),
        builder: (context, participantssnapshot) {
          if (participantssnapshot.connectionState == ConnectionState.waiting) {
            return circularProgress();
          } else {
            var _loadeddata = participantssnapshot.data.documents;

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
                          onTap: () {
                            player2 = _loadeddataindexcontent.data()["username"];
                            player2photo = _loadeddataindexcontent.data()["photoUrl"];
                            player2ID = _loadeddataindexcontent.data()["userId"];
                            player2lvl = _loadeddataindexcontent.data()["achievedlvl"];
                            print(player1lvl);
                            print(player2lvl);
                            Navigator.of(context)
                                .pushNamed(ConfirmTeam.link, arguments: {
                              "tournamentId": _tournamentID,
                              "selectedCountry": selectedCountry,
                              "selectedCountryURL": selectedCountryURL,
                              "player1Name": player1Name,
                              "player1Photo": player1Photo,
                              "player1lvl": player1lvl,
                              "player2Name": player2,
                              "player2Photo": player2photo,
                              "player1ID": player1ID,
                              "player2ID": player2ID,
                              "player2lvl": player2lvl,
                            });
                          },
                          child:                         ClipRRect(
                            borderRadius: BorderRadius.circular(MediaQuery.of(context)
                                .size
                                .width *
                                0.2,),
                            child: FadeInImage.assetNetwork(
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context)
                                    .size
                                    .width *
                                    0.24,
                                height: MediaQuery.of(context)
                                    .size
                                    .width *
                                    0.24,
                                fadeInDuration: Duration(seconds: 1),
                                placeholder:
                                'assets/images/volleychild.png',
                                imageErrorBuilder: (context, url,
                                    error) =>
                                new Image.asset(

                                    "assets/images/volleychild.png"),
                                image:_loadeddataindexcontent.data()["photoUrl"]),
                          ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Column(
                          children: <Widget>[
                            Text(
                              _loadeddataindexcontent.data()["username"],
                              textAlign: TextAlign.center,
                              style: TextStyle( fontSize: 18,
                                color: Colors.black.withOpacity(0.6),),
                              softWrap: true,
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              _loadeddataindexcontent.data()["achievedlvl"],
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: HexColor("#ea070a").withOpacity(0.8)),
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
    final String tournamentId = routearguments["tournamentId"];
    final String selectedCountry = routearguments["selectedCountry"];
    final String selectedCountryURL = routearguments["selectedCountryURL"];
    final String player1Name = routearguments["player1Name"];
    final String player1Photo = routearguments["player1photo"];
    final String player1ID = routearguments["player1ID"];
    final String player1lvl =routearguments["player1lvl"];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor("#ffe664"),
        title: Text("Player 2",style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.05,
                  bottom: MediaQuery.of(context).size.height * 0.05,),
                child: Text("Choose an athlete!",textAlign: TextAlign.center , style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.black.withOpacity(0.8)),)),
            buildPlayer2(tournamentId, selectedCountry, selectedCountryURL,
                player1Name, player1Photo, player1lvl,player1ID),
          ],
        ),
      ),
    );
  }
}
