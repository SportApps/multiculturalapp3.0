import 'package:flutter/material.dart';

class SignedUpGridviewElement extends StatelessWidget {
  final String name;
  final String imageURL;

  SignedUpGridviewElement({this.name, this.imageURL});

  @override
  Widget build(BuildContext context) {
    // Gridtile child takes main content
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: Image.network(imageURL),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          title: Text(
            name,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
