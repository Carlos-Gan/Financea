import 'package:flutter/cupertino.dart';

class UserSettings extends ChangeNotifier {
  String _username = 'Usuario';
  String _selectedLanguage = 'Español';

  String get username => _username;
  String get selectedLanguage => _selectedLanguage;

  void setUsername(String newUsername) {
    _username = newUsername;
    notifyListeners();
  }

  void setLanguage(String newLanguage) {
    _selectedLanguage = newLanguage;
    notifyListeners();
  }
}