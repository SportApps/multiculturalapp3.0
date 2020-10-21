import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:multiculturalapp/Screens/home.dart';
import 'package:multiculturalapp/model/user.dart';


class Users with ChangeNotifier {
  List<User> _items = [];

  List<User> get item {
    return [..._items];
  }

  // With this function we access the local DB
  void addUser(User yourCurrentUser) {
    _items.clear();
    _items.add(yourCurrentUser);

    notifyListeners();
  }
}
