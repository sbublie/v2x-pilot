import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings with ChangeNotifier, DiagnosticableTreeMixin {
  AppSettings() {
    //_getStatusfromStorage();
  }

  //void _getStatusfromStorage() async {
  //  final prefs = await SharedPreferences.getInstance();
  //  notifyListeners();
  //}

  String _serverURL = "http://127.0.0.1:5000/graphql";
  String get serverURL => _serverURL;
  void setServerURL(String value) {
    _serverURL = value;
    notifyListeners();
  }
}
