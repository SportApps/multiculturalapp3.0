import 'package:flutter/cupertino.dart';
import 'package:multiculturalapp/model/countryInfo.dart';



class Countryinfos with ChangeNotifier {
  List<CountryInfo> _items = [];

  List<CountryInfo> get item {
    return [..._items];
  }

  // With this function we access the local DB
  void addCountryInfo(CountryInfo yourCurrentCountryInfo) {
    _items.clear();
    _items.add(yourCurrentCountryInfo);

    notifyListeners();
  }
}
