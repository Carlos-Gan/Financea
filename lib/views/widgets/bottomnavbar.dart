import 'package:financea/utils/app_colors.dart';
import 'package:financea/views/add_tasks/add_screen.dart';
import 'package:financea/views/cards/cards_view.dart';
import 'package:financea/views/home/home_view.dart';
import 'package:financea/views/settings/settings_screen.dart';
import 'package:financea/views/statistics/statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BottomNavigationBarState createState() => _BottomNavigationBarState();
}

class _BottomNavigationBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  List Screen = [HomeView(), StatisticsView(), CardsView(), SettingsScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Screen[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => AddScreen()));
        },
        backgroundColor: AppColors.secondaryColor,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
              child: Icon(
                FontAwesomeIcons.house,
                size: 30,
                color:
                    _selectedIndex == 0
                        ? AppColors.secondaryColor
                        : Colors.amberAccent,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
              child: Icon(
                FontAwesomeIcons.chartPie,
                size: 30,
                color:
                    _selectedIndex == 1
                        ? AppColors.secondaryColor
                        : Colors.amberAccent,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 2;
                });
              },
              child: Icon(
                FontAwesomeIcons.creditCard,
                size: 30,
                color:
                    _selectedIndex == 2
                        ? AppColors.secondaryColor
                        : Colors.amberAccent,
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 3;
                });
              },
              child: Icon(
                FontAwesomeIcons.person,
                size: 30,
                color:
                    _selectedIndex == 3
                        ? AppColors.secondaryColor
                        : Colors.amberAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
