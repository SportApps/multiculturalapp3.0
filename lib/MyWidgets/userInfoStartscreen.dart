import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'dart:math';

import 'package:multiculturalapp/Screens/home.dart';
import 'package:multiculturalapp/Screens/volleyballLevels.dart';

class UserInfoStartscreen extends StatefulWidget {
  UserInfoStartscreen({
    this.name,
    this.skill,
    this.heightContainer,
    this.imageUrl,
    this.userUrl,
    this.points,
    this.gamesWon,
    this.winLooseRatioDouble,
  });

  final String name;

  final String skill;

  final double heightContainer;

  final String imageUrl;

  final String userUrl;

  final String points;

  final String gamesWon;

  final double winLooseRatioDouble;

  final double diameter = 180;

  @override
  _UserInfoStartscreenState createState() => _UserInfoStartscreenState();
}

class _UserInfoStartscreenState extends State<UserInfoStartscreen> {
  double advancePorcent;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.skill == "Baby Beginner") {
      advancePorcent = 0.125;
    }
    else if (widget.skill == "Little Child") {
      advancePorcent = 0.25;
    }
   else if (widget.skill == "Amateur") {
      advancePorcent = 0.5;
    }
    else if (widget.skill == "Grown-Up") {
      advancePorcent = 0.6125;
    }
    else if (widget.skill == "Experienced") {
      advancePorcent = 0.75;
    }

    else if (widget.skill == "Volley God" || widget.skill == "Admin") {
      advancePorcent = 1;
    }

  }

  @override
  Widget build(BuildContext context) {
    String _imagelink = widget.imageUrl;


    return Container(
      height: 500,
      width: double.infinity,
      padding:EdgeInsets.only(top:10),
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              CustomPaint(
                painter: GradientArcPainter(
                  startColor: HexColor("#ffde03"),
                  endColor: Colors.red,
                  progress: advancePorcent,
                  width: 10,
                ),
                size: Size(widget.diameter, widget.diameter),
              ),
              CircleAvatar(
                radius: MediaQuery.of(context).size.width*0.225,
                backgroundImage: NetworkImage(_imagelink),
              )
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            widget.skill,
            style: TextStyle(color: Colors.red),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.name,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 10,
              ),

            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              userInfoW(
                textinfo: "Points",
                variable: widget.points,
                myColor: HexColor("#ffde03"),
                textColor: Colors.black,
                myIcon: MdiIcons.star,
              ),
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 40,
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.black.withOpacity(0.09),
                      ),
                      CustomPaint(
                        painter: GradientArcPainter(
                          startColor: HexColor("#ffde03"),
                          endColor: Colors.red,
                          progress: widget.winLooseRatioDouble / 4,
                          width: 10,
                        ),
                        size: Size(100, 100),
                      ),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                      ),
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: HexColor("#ffe664"),
                        child: Text(
                          widget.winLooseRatioDouble.toStringAsFixed(2),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      "Win Loose Ratio",
                      style: TextStyle(fontSize: 14),
                    ),
                  )
                ],
              ),
              userInfoW(
                  myIcon: MdiIcons.trophyAward,
                  textinfo: "Games Won",
                  variable: widget.gamesWon,
                  myColor: HexColor("#ffde03"),
                  textColor: Colors.black),
            ],
          ),
        ],
      ),
    );

    ;
  }
}

class userInfoW extends StatelessWidget {
  const userInfoW(
      {Key key,
      @required this.textinfo,
      this.myColor,
      this.variable,
      this.textColor,
      this.myIcon})
      : super(key: key);

  final String textinfo;
  final String variable;
  final Color myColor;
  final Color textColor;
  final IconData myIcon;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: myColor,
      radius: MediaQuery.of(context).size.width*0.16,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[

          Icon(
            myIcon,
            size: 28,
            color: textColor,
          ),
          Text(
            textinfo,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            variable,
            style: TextStyle(fontSize: 18, color: textColor),
          ),
        ],
      ),
    );
  }
}

class GradientArcPainter extends CustomPainter {
  const GradientArcPainter({
    @required this.progress,
    @required this.startColor,
    @required this.endColor,
    @required this.width,
  })  : assert(progress != null),
        assert(startColor != null),
        assert(endColor != null),
        assert(width != null),
        super();

  final double progress;
  final Color startColor;
  final Color endColor;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0.0, 0.0, size.width, size.height);
    final gradient = SweepGradient(
      startAngle: 3 * pi / 2,
      endAngle: 7 * pi / 2,
      tileMode: TileMode.repeated,
      colors: [startColor, startColor],
    );

    final paint = new Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.butt // StrokeCap.round is not recommended.
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    final center = new Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - (width / 2);
    final startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(new Rect.fromCircle(center: center, radius: radius), 1.6,
        sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
