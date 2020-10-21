import 'package:flutter/material.dart';

class flagAppBar extends StatelessWidget {
  flagAppBar({this.myFlag, this.screenHeightPercentage});

  final String myFlag;

  final double screenHeightPercentage;

  double appBarHeight;

  @override
  Widget build(BuildContext context) {
    appBarHeight = MediaQuery.of(context).size.height * screenHeightPercentage;

    return Stack(
      children: <Widget>[
        Container(
          height: appBarHeight,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              border: Border.all(width: 3),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(myFlag),
              )),
        ),
        Container(
          height: appBarHeight,
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
        )
      ],
    );
    ;
  }
}
