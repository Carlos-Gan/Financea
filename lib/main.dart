import 'package:financea/model/card/card_data.dart';
import 'package:financea/model/category/category_data.dart';
import 'package:financea/model/datas/add_data.dart';
import 'package:financea/utils/app_str.dart';
import 'package:financea/utils/user_settings.dart';
import 'package:financea/views/new_user/new_user_screen.dart';
import 'package:financea/views/widgets/bottomnavbar.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(AddDataAdapter());
  Hive.registerAdapter(CardDataAdapter());
  Hive.registerAdapter(CategoryAdapter());
  await Hive.openBox<AddData>('data');
  await Hive.openBox<CardData>('cardData');
  await Hive.openBox<Category>('categories');
  //await Hive.deleteBoxFromDisk('categories');

  // Initialize UserSettings early to avoid any initialization issues
  final userSettings = UserSettings();
  await userSettings.loadPreferences();

  AppStr.setLang(userSettings.selectedLanguage);

  runApp(
    ChangeNotifierProvider(create: (_) => userSettings, child: const MainApp()),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkFirstTimeUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        bool isFirstTime = snapshot.data ?? true;

        return Consumer<UserSettings>(
          builder: (context, settings, child) {
            return MaterialApp(
              theme: _buildLightTheme(context, settings),
              darkTheme: _buildDarkTheme(context, settings),
              debugShowCheckedModeBanner: false,
              themeMode: settings.thememode,
              title: 'Financea',
              home: isFirstTime ? const NewUserScreen() : const BottomNavBar(),
            );
          },
        );
      },
    );
  }

  ThemeData _buildLightTheme(BuildContext context, UserSettings settings) {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: settings.primaryColor,
      colorScheme: ColorScheme.light(
        primary: settings.primaryColor,
        secondary: settings.primaryColor,
        onPrimary: Colors.black, // Color del texto sobre el color primario
        onSurface: Colors.black, // Color del texto principal
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
        displayLarge: TextStyle(color: Colors.black87),
        displayMedium: TextStyle(color: Colors.black87),
        // Agrega más estilos según necesites
      ),
      appBarTheme: AppBarTheme(
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme(BuildContext context, UserSettings settings) {
    return ThemeData.dark().copyWith(
      brightness: Brightness.dark,
      primaryColor: settings.primaryColor,
      colorScheme: ColorScheme.dark(
        primary: settings.primaryColor,
        secondary: settings.primaryColor,
        onPrimary: Colors.white,
        onSurface: Colors.white, // Texto principal en modo oscuro
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.white70),
        bodyMedium: TextStyle(color: Colors.white70),
        displayLarge: TextStyle(color: Colors.white),
        displayMedium: TextStyle(color: Colors.white),
      ),
      appBarTheme: AppBarTheme(
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<bool> _checkFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstTime') ?? true;
  }
}
