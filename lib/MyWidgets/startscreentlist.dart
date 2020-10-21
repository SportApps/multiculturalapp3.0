import 'package:flutter/material.dart';
import 'package:multiculturalapp/MyWidgets/TournamentInfoScr/tournamentinfo.dart';
import 'package:provider/provider.dart';
import 'package:multiculturalapp/Screens/tournamentinfoscreen.dart';
import 'package:multiculturalapp/model/tournament.dart';
import 'package:multiculturalapp/model/tournaments.dart';

class Startscreentlist extends StatelessWidget {
  Startscreentlist(
      {this.date,
      this.description,
        this.genderOnly,
        this.maxParticipants,
      this.fulldate,
      this.startingHour,
      this.finishHour,
      this.location,
      this.name,
      this.niveles,
      this.price,
      this.tournamentId,
      this.organizerName,
      this.whatsAppNR,
      this.userId,
      this.fotoLink,
      this.photoUrl,
      this.googleName});

  final String date;

  final String description;

  final String fulldate;

  final String startingHour;

  final String finishHour;

  final String location;

  final String name;

  final String niveles;

  final String price;

  final String tournamentId;

  final String userId;

  final String photoUrl;

  final String googleName;

  final String fotoLink;

  final String organizerName;

  final String whatsAppNR;

  final String genderOnly;

  final int maxParticipants;

  void changeScreen(BuildContext context) {
    // Add Tournament to Provider list

    Tournament selectedTournament = new Tournament(
        date: date,
        description: description,
        genderOnly: genderOnly,
        maxParticipants: maxParticipants,
        fulldate: fulldate,
        startingHour: startingHour,
        finishHour: finishHour,
        location: location,
        name: name,
        niveles: niveles,
        price: price,
        tournamentid: tournamentId,
        organizerName: organizerName,
        whatsAppNR: whatsAppNR);

    Provider.of<Tournaments>(context, listen: false)
        .addTournament(selectedTournament);


    Navigator.of(context).pushNamed(TournamentinfoScreen.link);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        changeScreen(context);
      },
      child: Container(
        width: MediaQuery.of(context).size.width*0.35,
        height: MediaQuery.of(context).size.width*0.3,
        margin: EdgeInsets.only(
            bottom: 10, left: MediaQuery.of(context).size.width * 0.025, right: MediaQuery.of(context).size.width * 0.025),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 4,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
            borderRadius: BorderRadius.circular(9)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(4),
              width: MediaQuery.of(context).size.width*0.25,
              height: MediaQuery.of(context).size.width*0.25,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(fotoLink), fit: BoxFit.fill)),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
            ),
            Flexible(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: Text(
                        date,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                        width: double.infinity,
                        child: Text(
                          "$startingHour - $finishHour",
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.start,
                        )),
                    Container(
                        width: double.infinity,
                        child: Text(
                          "$niveles lvl and $genderOnly",
                          style: TextStyle(fontSize: 12),
                          textAlign: TextAlign.start,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
