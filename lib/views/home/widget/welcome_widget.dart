import 'dart:developer';
import 'package:financea/utils/app_colors.dart';
import 'package:financea/utils/app_str.dart';
import 'package:financea/views/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Proveedor de configuraciones de usuario;
    final username = Provider.of<UserSettings>(context).username;
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 240,
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 30,
                left: MediaQuery.of(context).size.width - 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: GestureDetector(
                    onTap: () {
                      log("Notification icon tapped");
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      child: Icon(
                        FontAwesomeIcons.bell,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, left: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      //Cambia el mensaje de bienvenida dependiendo de la hora
                      DateTime.now().hour < 12
                          ? AppStr.get("goodMorning")
                          : DateTime.now().hour < 18
                              ? AppStr.get("goodAfternoon")
                              : AppStr.get('goodEvening'),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Colors.grey[400],
                      ),
                    ),
                    //Cambia el nombre en vez de AppStr.
                    Text(
                       username,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 30,
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
