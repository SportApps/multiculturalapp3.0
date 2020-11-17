import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';


class OrganizerInfoElement extends StatelessWidget {

  final double deviceHeight;

  final double average;

  final int tournamentsOrga;

  final int ratingBase;

  final String photoUrl;

  final String userName;


  OrganizerInfoElement(
      {this.deviceHeight, this.photoUrl, this.userName, this.average, this.ratingBase, this.tournamentsOrga,});


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          child: FadeInImage.assetNetwork(
              fit: BoxFit.cover,
              height: deviceHeight * 0.2,
              width: deviceHeight * 0.2,
              fadeInDuration: Duration(seconds: 1),
              placeholder: 'assets/images/volleychild.png',
              imageErrorBuilder: (context, url, error) =>
              new Image.asset(
                  "assets/images/volleychild.png"),
              image: photoUrl),
        ),
        Container(
          width: deviceHeight * 0.2,
          height: deviceHeight * 0.2,
          decoration: BoxDecoration(
            border: Border.all(
                width: 1,
                color:
                HexColor("979797").withOpacity(0.93)),
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
          ),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: deviceHeight * 0.015,
              ),
              Text(
                userName,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                softWrap: true,
              ),
              SizedBox(
                height: deviceHeight * 0.005,
              ),
              SmoothStarRating(
                  allowHalfRating: false,
                  onRated: (v) {},
                  starCount: 5,
                  rating: average,
                  size: 18.0,
                  isReadOnly: true,
                  color: HexColor("#0909EB"),
                  borderColor: HexColor("#0909EB"),
                  spacing: 0.0),
              Text(
                "Ratings $ratingBase",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 14,
                ),
                softWrap: true,
              ),
              SizedBox(
                height: deviceHeight * 0.02,
              ),
              Text(
                "$tournamentsOrga organized",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                softWrap: true,
              ),
              Text(
                "Tournaments",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );;
  }
}
