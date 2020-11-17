import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:multiculturalapp/MyWidgets/clippingClass.dart';
import 'package:multiculturalapp/MyWidgets/progress.dart';
import 'package:multiculturalapp/MyWidgets/whatsAppMessageBox.dart';
import 'package:multiculturalapp/Screens/OrgaInfo/organizerElement.dart';
import 'package:url_launcher/url_launcher.dart';

import '../home.dart';

class OrgaOverview extends StatelessWidget {
  static const link = "/orgaOverview";

  String whatsAppName = "Tim Knögel";

  String whatsAppNR = "+34685777303";

  String formatedWhatAppNR = "+34 685 777 303";

  Future<void> _makeWhatsappMessage(String number) async {
    if (await canLaunch("https://wa.me/$number?text=Hello")) {
      if (Platform.isIOS) {
        return "whatsapp://wa.me/${number}?text=Hello $whatsAppName,%0a %0a I would like to organize  Events with Volley World.%0a %0a PLEASE FILL OUT:%0a %0a How many nets you own: %0a %0a How many events/ month you would organize? %0a %0a What is your Beach Volley background? %0a %0a What is your motivation? %0a %0a}";
      } else {
        await launch(
            "https://wa.me/${number}?text=Hello $whatsAppName,%0a %0a I would like to organize  Events with Volley World.%0a %0a PLEASE FILL OUT:%0a %0a How many nets you own: %0a %0aHow many events/ month you would like to organize? %0a %0aWhat is your Beach Volley background? %0a %0aWhat is your motivation? %0a %0a*");
      }
    }
  }

  handleParticipantListSnapshot() {
    var querySnapshot = FirebaseFirestore.instance
        .collection("users")
        .where("isAdmin", isEqualTo: true)
        .snapshots();

    return querySnapshot;
  }

  GestureDetector buildBackButton(
      BuildContext context, double deviceHeight, double deviceWidth) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).popAndPushNamed(Home.link);
        },
        child: Container(
          width: deviceWidth*0.1,
          height: deviceWidth*0.1,
          margin:
              EdgeInsets.only(top: deviceHeight * 0.1, left: deviceWidth * 0.1),
            child: Icon(MdiIcons.chevronLeft, size: 40,),
        ));
  }

  Container buildbecomeOrganizerInfo(
    double deviceHeight,

    double devicWidth,
  ) {
    return Container(
      margin: EdgeInsets.only(top: deviceHeight * 0.63),
      padding: EdgeInsets.only(top: deviceHeight * 0.05),
      color: Colors.white,
      width: double.infinity,
      height: deviceHeight * 0.35,
      child: Column(
        children: [
          Container(
            width: devicWidth*0.1,
            height: devicWidth*0.1,


            decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    "assets/images/paulatrophy.png",
                  ),
                )),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "Do you want to become a",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            "Beach Volley Organizer?",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Container(
            margin: EdgeInsets.symmetric(
                vertical: deviceHeight*0.025,
                horizontal: devicWidth * 0.1),
            child: WhatsappMessageBox(
              organizerName: whatsAppName,
              whatsAppNR: whatsAppNR,
              whatsAppNRFormated: formatedWhatAppNR,
              createWhatsappMessage: _makeWhatsappMessage,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: double.infinity,
              height: deviceHeight * 0.65,
              decoration: BoxDecoration(
                  image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(
                  "assets/images/ourOrganizers.png",
                ),
              )),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: EdgeInsets.only(top: deviceHeight * 0.1),
              child: Column(
                children: [
                  Text(
                    "MEET OUR",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "ORGANIZERS",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: deviceHeight * 0.225),
              height: deviceHeight * 0.4,
              width: double.infinity,
              child: StreamBuilder<QuerySnapshot>(
                stream: handleParticipantListSnapshot(),
                builder: (context, participantssnapshot) {
                  if (participantssnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return circularProgress();
                  } else {
                    var _loadeddata = participantssnapshot.data.documents;

                    print(_loadeddata);
                    return GridView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _loadeddata.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 1 / 0.7,
                      ),
                      itemBuilder: (context, index) {
                        var _loadeddataindexcontent = _loadeddata[index];

                        String ratingBase =
                            _loadeddataindexcontent.data()["base"].toString();

                        String tournamentsOrga = _loadeddataindexcontent
                            .data()["tournamentsOrganized"]
                            .toString();

                        return OrganizerInfoElement(
                          userName: _loadeddataindexcontent.data()["username"],
                          photoUrl: _loadeddataindexcontent.data()["photo_url"],
                          average: _loadeddataindexcontent.data()["average"],
                          ratingBase: _loadeddataindexcontent.data()["base"],
                          tournamentsOrga: _loadeddataindexcontent
                              .data()["tournamentsOrganized"],
                          deviceHeight: deviceHeight,
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: buildbecomeOrganizerInfo(deviceHeight, deviceWidth),
          ),

          // The next two Widget Container create the Clip Effect on the Bottom.
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: deviceHeight * 0.95),
              height: deviceHeight * 0.05,
              width: double.infinity,
              color: HexColor("#ffe664"),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ClipPath(
              clipper: ClippingClass(),
              child: Container(
                margin: EdgeInsets.only(top: deviceHeight * 0.95),
                height: deviceHeight * 0.05,
                width: double.infinity,
                color: Colors.white,
              ),
            ),
          ),

          Align(
            alignment: Alignment.topLeft,
            child: buildBackButton(context, deviceHeight, deviceWidth),
          ),
        ],
      ),
    );
  }
}
