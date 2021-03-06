
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:multiculturalapp/MyWidgets/TournamentInfoScr/teamoverview.dart';
import 'package:multiculturalapp/MyWidgets/clippingClass.dart';
import 'package:multiculturalapp/MyWidgets/myAppBars/flagAppBar.dart';

var tournamentInstance =
    FirebaseFirestore.instance.collection("ourtournaments");

class ConfirmTeam extends StatelessWidget {
  static const link = "/ConfirmTeam";

  //1.) Function that adds team info to the tournament
  handleAddTeam(
    String tournamentId,
    String CountryName,
    String CountryURL,
    String player1Name,
    String player1Photo,
    String player2Name,
    String player2Photo,
    String player1ID,
    String player2ID,
    String player1lvl,
    String player2lvl,
  ) async {
    // 1.) Add Team to Team Collection with the Country NAME being its document name.
    await tournamentInstance
        .doc(tournamentId)
        .collection("countries")
        .doc(CountryName)
        .set({
      "CountryName": CountryName,
      "CountryURL": CountryURL,
      "player1ID": player1ID,
      "player1Name": player1Name,
      "player1Photo": player1Photo,
      "player2ID": player2ID,
      "player2Name": player2Name,
      "player2Photo": player2Photo,
      "player1lvl": player1lvl,
      "player2lvl": player2lvl,
      "Disqualified": false,
    });

    //2.) Change field "hasTeam" of the players of the team.

    // Player 1
    tournamentInstance
        .doc(tournamentId)
        .collection("participants")
        .doc(player1ID)
        .set({
      "hasTeam": true,
      "hasRated":false,
    },SetOptions(merge : true));

//player2
    tournamentInstance
        .doc(tournamentId)
        .collection("participants")
        .doc(player2ID)
        .set({
      "hasTeam": true,
      "hasRated":false,
    },SetOptions(merge : true));
  }

  // I Build Player Info Container
  Container playerInfo(BuildContext ctx, String playerName, String playerPhoto,
      String playerNr) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(ctx).size.width * 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(
              MediaQuery.of(ctx).size.width * 0.2,
            ),
            child: FadeInImage.assetNetwork(
                fit: BoxFit.cover,
                width: MediaQuery.of(ctx).size.width * 0.28,
                height: MediaQuery.of(ctx).size.width * 0.28,
                fadeInDuration: Duration(seconds: 1),
                placeholder: 'assets/images/volleychild.png',
                imageErrorBuilder: (context, url, error) =>
                    new Image.asset("assets/images/volleychild.png"),
                image: playerPhoto),
          ),
          Column(
            children: <Widget>[
              SizedBox(
                height: 5,
              ),
              Text(
                "Player $playerNr",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.red.withOpacity(0.8),
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: MediaQuery.of(ctx).size.height*0.009,
              ),
              Text(
                playerName,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.6)),
              ),
              SizedBox(
                height: MediaQuery.of(ctx).size.height*0.005,
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routearguments =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    final String tournamentId = routearguments["tournamentId"];
    final String CountryName = routearguments["selectedCountry"];
    final String selectedCountryURL = routearguments["selectedCountryURL"];
    final String player1Name = routearguments["player1Name"];
    final String player1Photo = routearguments["player1Photo"];
    final String player2Name = routearguments["player2Name"];
    final String player2Photo = routearguments["player2Photo"];
    final String player1ID = routearguments["player1ID"];
    final String player2ID = routearguments["player2ID"];
    final String player1lvl = routearguments["player1lvl"];
    final String player2lvl = routearguments["player2lvl"];
    return Scaffold(
      body: Container(
        color: HexColor("#ffe664"),
        child: Column(
          children: <Widget>[
            flagAppBar(
              myFlag: selectedCountryURL,
              screenHeightPercentage: 0.3,
            ),

            Container(
              color: Colors.white,
              width: double.infinity,
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.05),
              height: MediaQuery.of(context).size.height * 0.2,
              child: Text(
                "Team $CountryName",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            // Player 1
            Container(width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                  ),
                  playerInfo(context, player1Name, player1Photo, "1"),
                  playerInfo(context, player2Name, player2Photo, "2"),
                ],
              ),
            ),

            Stack(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.07,
                  width: double.infinity,
                  color: HexColor("#ffe664"),
                ),
                ClipPath(
                    clipper: ClippingClass(),
                    child: Container(
                      color: Colors.white,
                      height: MediaQuery.of(context).size.height * 0.07,
                      width: double.infinity,
                    )),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.07,
                    ),
                    Container(padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.05,),
                      color: HexColor("#ffe664"),
                      child: Center(
                          child: RaisedButton(
                        child: Text("Confirm Team"),
                        onPressed: () {
                          handleAddTeam(
                              tournamentId,
                              CountryName,
                              selectedCountryURL,
                              player1Name,
                              player1Photo,
                              player2Name,
                              player2Photo,
                              player1ID,
                              player2ID,
                              player1lvl,
                              player2lvl);
                          Navigator.of(context).popAndPushNamed(
                            Teamoverview.link,
                          );
                        },
                      )),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
