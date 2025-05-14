import 'dart:developer';

import 'package:financea/utils/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettings extends ChangeNotifier {
  String _username = '';
  String _selectedLanguage = 'English';
  bool _isLoading = false;

  //Configuracion de tema
  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = const Color.fromARGB(255, 241, 137, 0);
  final List<Color> _availableColors = [
    const Color.fromARGB(255, 241, 137, 0),
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.teal,
  ];

  bool get isLoading => _isLoading;
  String get username => _username;
  String get selectedLanguage => _selectedLanguage;
  //Configuracion de tema
  ThemeMode get thememode => _themeMode;
  Color get primaryColor => _primaryColor;
  List<Color> get availableColors => _availableColors;

  UserSettings() {
    loadPreferences();
  }

  //Configuracon nombre de usuario
  Future<void> setUsername(String newUsername) async {
    _username = newUsername;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', newUsername);
    notifyListeners();
  }

  //Configuracion del idioma
  Future<void> setLanguage(String newLanguage) async {
    _selectedLanguage = newLanguage;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', newLanguage);
    notifyListeners();
  }

  //Configuracion de tema
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  //Configuracion de color primario
  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    // ignore: deprecated_member_use
    await prefs.setInt('primaryColor', color.value);
    notifyListeners();
  }

  //Metodo obtener tema actual
  ThemeData getCurrentTheme(BuildContext context) {
    final brightness =
        _themeMode == ThemeMode.system
            ? MediaQuery.of(context).platformBrightness
            : _themeMode == ThemeMode.light
            ? Brightness.light
            : Brightness.dark;

    return ThemeData(
      brightness: brightness,
      primarySwatch: _createMaterialColor(_primaryColor),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: _createMaterialColor(_primaryColor),
        brightness: brightness,
      ),
    );
  }

  Future<void> loadPreferences() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      _username = prefs.getString('userName') ?? '';
      _selectedLanguage = prefs.getString('language') ?? 'English';

      //Configuracion de tema
      final themeIndex = prefs.getInt('themeMode') ?? ThemeMode.system.index;
      _themeMode = ThemeMode.values[themeIndex];

      final colorValue = prefs.getInt('primaryColor') ?? Colors.blue.value;
      _primaryColor = Color(colorValue);
    } catch (e) {
      log('Error loading preferences: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //Convertir color a MaterialColor
  MaterialColor _createMaterialColor(Color color) {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final r = color.red, g = color.green, b = color.blue;

    for (var i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (final strength in strengths) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.value, swatch);
  }
}
