import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class WhatsappMessageBox extends StatelessWidget {
  WhatsappMessageBox(
      {this.organizerName,
      this.whatsAppNR,
      this.whatsAppNRFormated,
      this.createWhatsappMessage});

  final String organizerName;

  final String whatsAppNR;

  final String whatsAppNRFormated;

  final Function createWhatsappMessage;

  @override
  Widget build(BuildContext context) {
    final double deviseWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: -1,
            blurRadius: 8,
            offset: Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: RaisedButton(
        padding: EdgeInsets.all(8),
        color: Colors.white,
        onPressed: () async {
          await createWhatsappMessage(whatsAppNR);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                decoration: BoxDecoration(
                  color: HexColor("4CAF50"),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                width: deviseWidth * 0.125,
                height: deviseWidth * 0.125,
                child: Icon(
                  MdiIcons.whatsapp,
                  color: Colors.white,
                  size: 27,
                )),
            SizedBox(
              width: 10,
            ),
            Column(
              children: [
                Text(
                  "Open Whatsapp",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "$organizerName: $whatsAppNRFormated",
                  style: TextStyle(fontSize: 13),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
