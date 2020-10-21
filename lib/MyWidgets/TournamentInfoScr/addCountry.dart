import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:multiculturalapp/model/tournaments.dart';

import '../clippingClass.dart';
import '../progress.dart';
import 'addPlayer1.dart';

var countryFBInstance = FirebaseFirestore.instance.collection("countries");
String selectedCountry;
String selectedCountryURL;

class addCountry extends StatelessWidget {
  static const link = "/addCountry";

  Container buildCountryContainer(String tournamentId,BuildContext context) {
    return Container(
      color: HexColor("#ffe664"),
      child: ClipPath(
        clipper: ClippingClass(),
        child: Column(
          children: <Widget>[
            Container(height: 30,width: double.infinity,color: Colors.white,),
            Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height*0.8,
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    countryFBInstance.orderBy("name", descending: false).snapshots(),
                builder: (context, countrySnapshot) {
                  if (countrySnapshot.connectionState == ConnectionState.waiting) {
                    return circularProgress();
                  } else {
                    var _loadeddata = countrySnapshot.data.documents;

                    return GridView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: _loadeddata.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemBuilder: (context, index) {

                        var _loadeddataindexcontent = _loadeddata[index];

                        return Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              InkWell(
                                onTap: () {

                                  selectedCountry = _loadeddataindexcontent.data()["name"];
                                  selectedCountryURL =
                                  _loadeddataindexcontent.data()["downloadUrl"];
                                  print(selectedCountry);
                                  Navigator.of(context)
                                      .pushNamed(AddPlayer1.link, arguments: {
                                    "tournamentID": tournamentId,
                                    "selectedCountry": selectedCountry,
                                    "selectedCountryURL": selectedCountryURL
                                  });
                                },
                                child: Container(
                                  width: 90,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                              _loadeddataindexcontent.data()["downloadUrl"]))),
                                ),
                              ),
                              Container(
                                  padding: EdgeInsets.only(top: 5),
                                height: 60,
                                child: Text(
                                  _loadeddataindexcontent.data()["name"],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This is the listener for USER DATA
    //By Adding the <> GENETIC DATA we indicate which Provider we listen to.
    final tournamentData = Provider.of<Tournaments>(context, listen: true);
    // here we access the data from the listener.
    final currentTournament = tournamentData.item;
    final String tournamentId = currentTournament[0].tournamentid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Choose a flag",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: HexColor("#ffe664"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            buildCountryContainer(tournamentId, context),
            Container(height: MediaQuery.of(context).size.height*0.1,
              width: MediaQuery.of(context).size.width,
              color: HexColor("#ffe664"),),
          ],
        ),
      ),
    );
  }
}
