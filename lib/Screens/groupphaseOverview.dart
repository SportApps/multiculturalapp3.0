import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:multiculturalapp/MyWidgets/clippingClass.dart';
import 'package:multiculturalapp/MyWidgets/progress.dart';
import 'package:multiculturalapp/Screens/confirmEndGroupPhase.dart';

import 'home.dart';

class GroupPhaseOverview extends StatefulWidget {
  static const link = "/GroupHaseoverview";

  @override
  _GroupPhaseOverviewState createState() => _GroupPhaseOverviewState();
}

class _GroupPhaseOverviewState extends State<GroupPhaseOverview> {
  String currentCountry;

  String Wins;
  String Lost;
  String AC;
  String player1ID;
  String player2ID;

  List countryList;
  bool _isLoading;
  bool _isGold;
  List<Map> goldGroup;
  List<Map> silverGroup;

  createEliminationGroups(List countryList) {
    int NR = 0;
    bool currentCountryIsGold;
    goldGroup = [];
    silverGroup = [];
    for (var i = 0; i < countryList.length; i++) {
      if (countryList[NR]["goldGroup"] == true) {
        currentCountryIsGold = true;
      } else {
        currentCountryIsGold = false;
      }

      var test = countryList[NR];

      if (currentCountryIsGold) {
        goldGroup.add(countryList[NR]);
      } else
        (silverGroup).add(countryList[NR]);

      NR++;
    }


  }

  initState() {
    // TODO: implement initState
    super.initState();
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final routeargs =
          ModalRoute.of(context).settings.arguments as List<dynamic>;

      countryList = routeargs;

      print(countryList);

      /// sort List<Map<String,dynamic>>

      setState(() {
        _isLoading = false;
      });
    });

    // If we are not an Admin we set CountrySelected to true so the athlet can see his/her result (Streambuilder List)
  }




  //0.) Is Admin AppBarbuilder
  Container appBarbuilder() {
    return Container(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.width * 0.1, bottom: 10),
      color: HexColor("#ffe664"),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
          ),
          Text(
            "Group Overview",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
          SizedBox(
            width: 45,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).popAndPushNamed(Home.link);
            },
            child: Container(
              height: 45,
              width: 45,
              padding: EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/smalllogo.png"))),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int i = 0;

    return Scaffold(

      body: _isLoading
          ? circularProgress()
          : Column(
              children: <Widget>[
                appBarbuilder(),
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  height: MediaQuery.of(context).size.height * 0.65,
                  width: MediaQuery.of(context).size.width,
                  child: GroupedListView<dynamic, String>(
                      groupBy: (element) => element['currentTeamGroup'],
                      elements: countryList,
                      order: GroupedListOrder.ASC,
                      useStickyGroupSeparators: true,
                      groupSeparatorBuilder: (String value) => Container(
                            width: double.infinity,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Group $value",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: HexColor("#ea070a").withOpacity(0.8)
                                ),
                              ),
                            ),
                          ),
                      itemBuilder: (c, element) {
                        i++;

                        currentCountry = element["currentTeam"].toString();
                        player1ID = element["player1ID"].toString();
                        player2ID = element["player2ID"].toString();
                        Wins = element["countryWins"].toString();
                        Lost = element["countryLost"].toString();
                        AC = element["accumulatedPoints"].toString();

                        _isGold = element["goldGroup"];

                        return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.05,
                            ),
                            child: Container(
                                height: 80,
                                margin: EdgeInsets.all(10),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      width: 1,
                                      color: HexColor("#979797"),
                                    )),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(right: 20),
                                      color: HexColor("#ea070a"),
                                      width: 80,
                                      child: Center(
                                        child: Text("$Wins W",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(currentCountry,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            )),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "$AC ACP",
                                          style: TextStyle(
                                              color: HexColor("#ea070a"),
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    InkWell(
                                      onTap: () {
                                        countryList[element["runningNR"]] = {
                                          "runningNR": element["runningNR"],
                                          "currentTeam": element["currentTeam"],
                                          "currentTeamGroup":
                                              element["currentTeamGroup"],
                                          "player1ID": element["player1ID"],
                                          "player2ID": element["player2ID"],
                                          "countryWins": element["countryWins"],
                                          "countryLost": element["countryLost"],
                                          "accumulatedPoints":
                                              element["accumulatedPoints"],
                                          "goldGroup": !element["goldGroup"],
                                        };
                                        print(countryList);
                                        setState(() {});
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        width: 80,
                                        height: 60,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                          image: _isGold
                                              ? AssetImage(
                                                  "assets/images/goldtrophy.png")
                                              : AssetImage(
                                                  "assets/images/silvergroup.png"),
                                        )),
                                      ),
                                    )
                                  ],
                                )));
                      }),
                ),
                Stack(
                  children: [
                    ClipPath(
                      clipper: ClippingClass(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.075,
                        width: double.infinity,
                       color: Colors.white,

                      ),
                    ),
                    Container(
                      color: Colors.transparent,
                      width: double.infinity,
                      child: Builder(builder: (context) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.1),
                          child: Column(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.125,
                              ),
                              RaisedButton(
                                  onPressed: () {
                                    createEliminationGroups(countryList);

                                    if (goldGroup.length >= 2) {
                                      Navigator.of(context).pushNamed(
                                          ConfirmedEndGroupPhase.link,
                                          arguments: {
                                            "gold": goldGroup,
                                            "silver": silverGroup,
                                            "countryList": countryList,
                                          });
                                    } else {
                                      Scaffold.of(context).openDrawer();
                                      Scaffold.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                "Before finishing - add 2 - 4 - 8 or 16 Teams to the Gold Group",
                                                textAlign: TextAlign.center,
                                              ),
                                              duration: Duration(seconds: 3)));
                                    }
                                  },
                                  color: HexColor("#ea070a"),
                                  child: Text("Finish Group Phase")),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                )
              ],
            ),
    );
  }
}
