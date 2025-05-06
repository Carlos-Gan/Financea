import 'package:financea/model/card/card_data.dart';
import 'package:financea/model/datas/add_data.dart';
import 'package:financea/views/settings/settings_screen.dart';
import 'package:financea/views/widgets/bottomnavbar.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(AddDataAdapter());
  Hive.registerAdapter(CardDataAdapter());
  await Hive.openBox<AddData>('data');
  await Hive.openBox<CardData>('cardData');

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserSettings(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const BottomNavBar(),
    );
  }
}
