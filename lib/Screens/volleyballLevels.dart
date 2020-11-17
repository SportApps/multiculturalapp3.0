import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import "package:hexcolor/hexcolor.dart";
import 'package:multiculturalapp/MyWidgets/userInfoStartscreen.dart';
import 'package:multiculturalapp/model/users.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class VolleyballLevels extends StatelessWidget {
  final String babyBeginnerFoto =
      "https://firebasestorage.googleapis.com/v0/b/multiculturalapp-5b7e3.appspot.com/o/levels%2Fbaby2.png?alt=media&token=9fda8004-1f1f-4e77-8f4b-bd28f348132c";
  final String littleChildFoto =
      "https://firebasestorage.googleapis.com/v0/b/multiculturalapp-5b7e3.appspot.com/o/levels%2Famateur.png?alt=media&token=2a44647d-f28d-4047-8b92-89135bc501cd";
  final String teenFoto =
      "https://firebasestorage.googleapis.com/v0/b/multiculturalapp-5b7e3.appspot.com/o/levels%2Fexperienced2.png?alt=media&token=f97853a0-7c26-4c3c-904f-89cc0040d208";
  final String grownUpFoto =
      "https://firebasestorage.googleapis.com/v0/b/multiculturalapp-5b7e3.appspot.com/o/god.png?alt=media&token=5d4e06e9-4e7c-4d5d-8042-adb57711a56f";

  final String instaLink =
      "https://www.instagram.com/multiculturalvolleyballbcn/";

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

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
              Builder(
                builder: (context) => GestureDetector(
                  onLongPress: () async {
                    final userData = Provider.of<Users>(context, listen: false);

                    String myuserID = userData.item[0].id;

                    try {
                      // Secret Director function
                      // If you are a director, recalculate the admins Ratings.
                      // 1.) Check is is Director.
                      var FireUser = await FirebaseFirestore.instance
                          .collection("users")
                          .doc(myuserID)
                          .get();

                      bool isdirector = FireUser.data()["director"];

                      if (isdirector) {
                        // Inform the Direcotr that the Ratings are being calculated.
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text('Recalculating new Orga Rankings'),
                        ));

                        // Get a list of tournaments where the Rating of the organizer have not been included yet.

                        var fireTournament = await FirebaseFirestore.instance
                            .collection("ourtournaments")
                            .where("ratingIncluded", isEqualTo: false)
                            .get();

                        // In orgaIdList we will store the Id List of organizers.
                        List<String> orgaIdList = [];

                        orgaIdList.clear();

                        // For each FireTournament that is not included in the Rating, we will take the organzierId and add it to the list.
                        fireTournament.docs.forEach((element) async {
                          orgaIdList.add(element.data()["organizerId"]);

                          //Furthermore we need to change the ResultAdded property in the tournamentId to True
                          String tournamentId = element.id;

                          await FirebaseFirestore.instance
                              .collection("ourtournaments")
                              .doc(tournamentId)
                              .update({"ratingIncluded": true});
                        });

                        print("This is the list with possible dublicates");
                        print(orgaIdList);

                        // Delete possible dublicates (for example if a organizer did several events since last calculation.
                        List<String> orgaIdListnoDub = [];
                        orgaIdListnoDub.clear();
                        orgaIdListnoDub = orgaIdList.toSet().toList();

                        print("This is the list without  dublicates");
                        print(orgaIdListnoDub);

                        // Recalculate Ratings of the Organizers in the orgaIdListnoDub.

                        int currentOrgaNR = 0;
                        ;
                        String currentOrgaId;
                        double currentPreviousAverage;
                        int currentBasisOld;
                        int currentNewtoBasis;
                        for (var i = 0; i < orgaIdListnoDub.length; i++) {
                          currentOrgaId = orgaIdListnoDub[currentOrgaNR];

                          print("This is the currentorgaId $currentOrgaId");
                          // 1.0) First we get the previous Rating data.
                          var FireRatings = await FirebaseFirestore.instance
                              .collection("orgaRatings")
                              .doc(currentOrgaId)
                              .get();

                          currentPreviousAverage =
                              FireRatings.data()["average"];
                          print(
                              "This is the currentpreviousaverage $currentPreviousAverage");
                          currentBasisOld = FireRatings.data()["base"];
                          print("This is the $currentBasisOld");

                          // 2.Then we check the new Rating Data.
                          var FireRatingsNew = await FirebaseFirestore.instance
                              .collection("orgaRatings")
                              .doc(currentOrgaId)
                              .collection("userRatings")
                              .get();

                          int newRatingtotal = 0;
                          double newAverage;
                          // 2.1) currentNewtoBasis = How many RAtings did the organizer get?
                          currentNewtoBasis = FireRatingsNew.docs.length;

                          // 2.2) newRatings = List of all new Ratings
                          FireRatingsNew.docs.forEach((element) {
                            newRatingtotal =
                                newRatingtotal + element.data()["rating"];
                          });
                          // 2.3)  Average of new Ratings
                          newAverage = newRatingtotal / currentNewtoBasis;

                          // 3.) Calculate new Ratios
                          //3.1) The to Upload currentBasisNew is how many RAtings the organizer has now.
                          int currentBasisNew =
                              currentBasisOld + currentNewtoBasis;

                          //3.2) The to Upload currentAberageNew is the new average of the organizer.

                          // Gewichteter Durchschnitt

                          double oldBasis_And_Average =
                              currentBasisOld * currentPreviousAverage;

                          double newBasis_And_Average =
                              currentNewtoBasis * newAverage;

                          double uploadNewAverage =
                              (oldBasis_And_Average + newBasis_And_Average) /
                                  currentBasisNew;

                          await FirebaseFirestore.instance
                              .collection("orgaRatings")
                              .doc(currentOrgaId)
                              .set({
                            "average": uploadNewAverage,
                            "base": currentBasisNew
                          },SetOptions(merge:true));


                          // Copy the info aswell into the users Collection to have it available there.
                          await FirebaseFirestore.instance
                              .collection("users")
                              .doc(currentOrgaId)
                              .set({
                            "average": uploadNewAverage,
                            "base": currentBasisNew
                          },SetOptions(merge:true));




                          await FirebaseFirestore.instance
                              .collection("orgaRatings")
                              .doc(currentOrgaId)
                              .collection("userRatings")
                              .get()
                              .then((value) => value.docs.forEach((element) {
                                    element.reference.delete();
                                  }));

                          currentOrgaNR++;
                        }
                      }
                    }
                    // if you are not a direcotr, throw error.
                    catch (e) {
                      print("You are not a director.");
                      print(e);
                    }
                  },
                  child: Container(
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
              Container(
                padding: EdgeInsets.only(bottom: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      child: Text(
                        "Follow us!",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Builder(
                      builder: (context) => GestureDetector(
                        onTap: () async {
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text('Opening Instagram...'),
                              duration: Duration(seconds: 3)));

                          await _launchInBrowser(instaLink);
                        },
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(
                            "assets/images/insta.png",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
