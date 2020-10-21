import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class FinishTournamentAppBar extends StatelessWidget {
  FinishTournamentAppBar({
    this.myFlag,
    this.mycontext,
    this.imageUrl,
    this.userName,
    this.userlvl,
  });

  final String myFlag;

  final String imageUrl;

  final String userName;

  final String userlvl;

  final BuildContext mycontext;

  static double appBarHeight;

  @override
  Widget build(BuildContext context) {
    appBarHeight = MediaQuery.of(mycontext).size.height * 0.5;
    return Stack(
      children: <Widget>[
        // This Column defines the flag.
        Column(
          children: <Widget>[
            // Here we define how much space betwwen upperscreen and Flag.
            SizedBox(
              height: appBarHeight * 0.3,
            ),
            // This Stack contains the flag. We have 2 more containers which help to give Opacity to the Flag on its Corners. One of them is in a Column to make it possible that there is this white gradient border.
            Stack(
              children: <Widget>[
                Container(
                  height: appBarHeight * 0.7,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(myFlag),
                  )),
                ),
                Container(
                  height: appBarHeight * 0.35,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: FractionalOffset.topCenter,
                          end: FractionalOffset.bottomCenter,
                          colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.00),
                      ],
                          stops: [
                        0.0,
                        1.0
                      ])),
                ),
                Column(
                  children: [
                    SizedBox(
                      height: appBarHeight * 0.35,
                    ),
                    Container(
                      height: appBarHeight * 0.35,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: FractionalOffset.topCenter,
                              end: FractionalOffset.bottomCenter,
                              colors: [
                            Colors.white.withOpacity(0.00),
                            Colors.white
                          ],
                              stops: [
                            0.0,
                            1.0
                          ])),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),

        // This Container adds us the Trophy in the background.
        Container(
          width: double.infinity,
          height: appBarHeight,
          decoration: BoxDecoration(
              image: DecorationImage(
            fit: BoxFit.fitWidth,
            colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.15), BlendMode.dstATop),
            image: AssetImage(
              "assets/images/goldtrophy.png",
            ),
          )),
        ),
        // Add Circular Foto of our player.
        Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: appBarHeight * 0.3,
              ),
              Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 5, color: HexColor("#f2f1ef"))),
                child: CircleAvatar(
                  radius: 90,
                  backgroundImage: NetworkImage(imageUrl),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                userName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(userlvl),
            ],
          ),
        )
      ],
    );
    ;
  }
}
