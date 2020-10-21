import 'package:flutter/material.dart';
import "package:hexcolor/hexcolor.dart";
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:multiculturalapp/MyWidgets/clippingClass.dart';
import 'package:multiculturalapp/MyWidgets/userInfoStartscreen.dart';

class VolleyballLevels extends StatelessWidget {
  final String babyBeginnerFoto =
      "https://images.unsplash.com/photo-1491013516836-7db643ee125a?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1525&q=80";
  final String littleChildFoto =
      "https://images.unsplash.com/photo-1594243898371-4c847623c723?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=3024&q=80";
  final String teenFoto =
      "https://images.unsplash.com/photo-1567880436222-3aff507a05a0?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1650&q=80";
  final String grownUpFoto =
      "https://images.unsplash.com/photo-1553451310-1416336a3cca?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2308&q=80rmat&fit=crop&w=1650&q=80";

  Row buildLevelContainer(BuildContext ctx, String fotolink, String lvlName,
      String lvlConditions, String winLooseRatioString, double advance) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.only(
              left: MediaQuery.of(ctx).size.width * 0.05,
              top: MediaQuery.of(ctx).size.width * 0.025,
              bottom: MediaQuery.of(ctx).size.width * 0.025),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              CustomPaint(
                painter: GradientArcPainter(
                  startColor: HexColor("#ffde03"),
                  endColor: Colors.red,
                  progress: advance,
                  width: 8,
                ),
                size: Size(MediaQuery.of(ctx).size.width * 0.3,
                    MediaQuery.of(ctx).size.width * 0.3),
              ),
              CircleAvatar(
                radius: MediaQuery.of(ctx).size.width * 0.125,
                backgroundImage: NetworkImage(fotolink),
              )
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lvlName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(lvlConditions, style: TextStyle(fontSize: 14)),
              Text(
                winLooseRatioString,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static const link = "/volleyballlevel";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Volleyball Levels"),
          backgroundColor: HexColor("#ffe664"),
          elevation: 0,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(

            children: [
              Container(
                width: double.infinity,
                height: 680,
                padding: EdgeInsets.only(top: 15, left: 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(66)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildLevelContainer(context, babyBeginnerFoto,
                        "Baby Beginner", "0 pts", "", 0.25),
                    buildLevelContainer(
                        context, littleChildFoto, "Amateur", "20 pts", "", 0.5),
                    buildLevelContainer(context, teenFoto, "Experienced",
                        "50 pts", "Win-Loose Ratio +1.00", 0.75),
                    buildLevelContainer(context, grownUpFoto, "Volley-God",
                        "100 pts", "Win-Loose Ratio +2.00", 1),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 25),
                width: double.infinity,
                child: Text(
                  "How to achieve points?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.8),
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10, bottom: 30),
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      "Match won - 1 pt",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.8),
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "Gold match won - 3 pts",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.8),
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "Tournament won - 10 pts",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.8),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    MdiIcons.instagram,
                    size: 40,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "@multiculturalvolleyballbcn",
                      style: TextStyle(fontSize: 20,fontFamily: "Futura" ),
                    ),
                  )
                ],
              )
            ],
          ),
        ));
  }
}
