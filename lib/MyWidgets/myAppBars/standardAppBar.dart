import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class StandardAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,

      title: Container(
        width: MediaQuery.of(context).size.width * 0.35,
        height: MediaQuery.of(context).size.width * 0.25,
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                "assets/images/homeappbar2.png",
              ),
            )),
      ),
    );
  }
}
