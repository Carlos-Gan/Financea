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
    ChangeNotifierProvider(
      create: (_) => userSettings,
      child: const MainApp(),
    ),
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
        
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Financea',
          home: isFirstTime ? const NewUserScreen() : const BottomNavBar(),
        );
      },
    );
  }

  Future<bool> _checkFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstTime') ?? true;
  }
}