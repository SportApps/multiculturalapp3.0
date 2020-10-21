import 'package:flutter/cupertino.dart';

import 'package:multiculturalapp/model/userStat.dart';

class UserStats with ChangeNotifier {
  List<UserStat> _items = [];

  List<UserStat> get item {
    return [..._items];
  }

  // With this function we access the local DB
  void addUserStat(UserStat yourcurrentUserStat) {
    _items.clear();
    _items.add(yourcurrentUserStat);

    notifyListeners();


  }
}
