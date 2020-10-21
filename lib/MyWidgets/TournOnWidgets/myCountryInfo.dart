import 'package:flutter/material.dart';

class MyCountryInfo extends StatelessWidget {
  MyCountryInfo({
    @required this.groupNR,
    @required this.myCountry,
    @required this.myWins,
    @required this.myLost,
    @required this.phase,
  });

  final String groupNR;

  final String myCountry;

  final String myWins;

  final String myLost;

  final String phase;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.width*0.05),
      child: Column(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Text(
                  "Team $myCountry",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                SizedBox(height: 5,),
                Text(
                  "$phase - Group $groupNR",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(
                  height:  MediaQuery.of(context).size.height*0.05,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(
                          "Won",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black.withOpacity(0.8)
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          myWins,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black.withOpacity(0.8)
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          height: 3,
                          width: 20,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: Colors.green.withOpacity(0.8),),

                        )
                      ],
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          "Lost",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black.withOpacity(0.8)
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          myLost,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black.withOpacity(0.8)
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                          height: 3,
                          width: 20,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: Colors.red.withOpacity(0.8),),

                        )
                      ],
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
