import 'package:flutter/cupertino.dart';

import 'package:multiculturalapp/model/tournament.dart';

class Tournaments with ChangeNotifier {
  List<Tournament> _items = [];

  List<Tournament> get item {
    return [..._items];
  }

  // With this function we access the local DB
  void addTournament(Tournament yourCurrentTournament) {
    _items.clear();
    _items.add(yourCurrentTournament);

    notifyListeners();


  }
}
