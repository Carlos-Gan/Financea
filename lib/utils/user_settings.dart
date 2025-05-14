import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettings extends ChangeNotifier {
  String _username = '';
  String _selectedLanguage = 'English';
  final bool _isLoading = false;

  bool get isLoading => _isLoading;
  String get username => _username;
  String get selectedLanguage => _selectedLanguage;

  UserSettings() {
    loadPreferences();
  }

  Future<void> setUsername(String newUsername) async {
    _username = newUsername;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', newUsername);
    notifyListeners();
  }

  Future<void> setLanguage(String newLanguage) async {
    _selectedLanguage = newLanguage;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', newLanguage);
    notifyListeners();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('userName') ?? '';
    _selectedLanguage = prefs.getString('language') ?? 'English';
    notifyListeners();
  }
}