import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class StandardAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: HexColor("ffe664"),
        title: Container(
          width: 40,
          height: 30,
          child: Image(
            image: AssetImage("/assets/images/logo"),
          ),
        ));
  }
}
