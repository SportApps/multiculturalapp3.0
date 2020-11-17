import 'package:flutter/material.dart';

class SilverWinnerListviewbuilder extends StatelessWidget {
  SilverWinnerListviewbuilder({this.countryList});

  final List countryList;

  @override
  Widget build(BuildContext context) {
    print(countryList);
    List reversedcountryList = countryList.reversed.toList();
    print(reversedcountryList);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: MediaQuery.of(context).size.height * 0.5,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              SizedBox(
                width: 15,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.05,
                child: Text(
                  "R",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.8)),
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                child: Text(
                  "Team",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                "W",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.8)),
              ),
              SizedBox(
                width: 15,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.2,
                child: Text(
                  "AP",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.8)),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          Container(
            height: 3,
            width: double.infinity,
            color: Colors.black,
          ),
          Flexible(
            child: ListView.builder(

                shrinkWrap: true,
                itemCount: countryList.length,
                itemBuilder: (context, i) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: (Row(
                      children: <Widget>[
                        SizedBox(
                          width: 15,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.05,
                          child: Text(
                            (i + 1).toString(),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black.withOpacity(0.8)),
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: Text(
                            countryList[i]["currentTeam"],
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black.withOpacity(0.8)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          countryList[i]["countryWins"].toString(),
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black.withOpacity(0.8)),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: Text(
                              countryList[i]["accumulatedPoints"]
                                  .toString(),
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black.withOpacity(0.8)),
                              textAlign: TextAlign.center),
                        ),
                      ],
                    )),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
