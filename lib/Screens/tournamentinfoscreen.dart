

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:multiculturalapp/model/tournaments.dart';

import 'package:multiculturalapp/MyWidgets/TournamentInfoScr/tournamentinfo.dart';

class TournamentinfoScreen extends StatelessWidget {
  static const link = "/tournamentinfoscreen";

  @override
  Widget build(BuildContext context) {
    // This is the listener for USER DATA
    //By Adding the <> GENETIC DATA we indicvvate which Provider we listen to.
    final tournamentData = Provider.of<Tournaments>(context, listen: true);
    // here we access the data from the listener.
    final currentTournament = tournamentData.item;
    final String tournamentName = currentTournament[0].name;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.white,
            expandedHeight: 220,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(),
              centerTitle: true,
              title: Text(
                tournamentName,
                style: TextStyle(
                  fontFamily: "Helvetica",
                ),
              ),
              background: Container(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        fit: BoxFit.fitWidth,
                        image: AssetImage(
                          "assets/images/girlplayer.png",
                        ),
                      )),
                    ),
                    Column(
                      children: [
                        SizedBox(
                            height: 200),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              gradient: LinearGradient(
                                  begin: FractionalOffset.topCenter,
                                  end: FractionalOffset.bottomCenter,
                                  
                                  colors: [
                                    Colors.white.withOpacity(0.0),
                                    Colors.white,
                                  ],
                                  stops: [
                                    0.0,
                                    1.0
                                  ])),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Tournamentinfo(),
            ]),
          ),
        ],
      ),
    );
  }
}
