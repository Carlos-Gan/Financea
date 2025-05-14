import 'package:financea/utils/app_colors.dart';
import 'package:financea/utils/app_str.dart';
import 'package:financea/views/add_tasks/categories_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BackgroundContainer extends StatefulWidget {
  const BackgroundContainer({super.key});

  @override
  State<BackgroundContainer> createState() => _BackgroundContainerState();
}

class _BackgroundContainerState extends State<BackgroundContainer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 240,
          decoration: BoxDecoration(
            color: AppColors.secondaryColorDark,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(
                        FontAwesomeIcons.arrowLeft,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      AppStr.get('add'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => const ManageCategoriesScreen(),
                          ),
                        );
                        setState(() {});
                      },
                      child: const Icon(
                        FontAwesomeIcons.paperclip,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
