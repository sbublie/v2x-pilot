import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings with ChangeNotifier, DiagnosticableTreeMixin {
  AppSettings() {
    _getStatusFromStorage();
  }

  String _serverURL = "http://127.0.0.1:5000/graphql";
  String get serverURL => _serverURL;
  void setServerURL(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('serverURL', value);
    _serverURL = value;
    notifyListeners();
  }

  void _getStatusFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _serverURL =
        prefs.getString('serverURL') ?? 'http://127.0.0.1:5000/graphql';
    notifyListeners();
  }
}
