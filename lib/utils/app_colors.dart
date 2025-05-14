import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'user_settings.dart';

class AppColors {
  static Color primaryColor(BuildContext context) {
    return Provider.of<UserSettings>(context, listen: true).primaryColor;
  }

  static Color primaryColorDark(BuildContext context) {
    final primary = primaryColor(context);
    return Color.fromARGB(
      primary.alpha,
      (primary.red * 0.7).toInt(),
      (primary.green * 0.7).toInt(),
      (primary.blue * 0.7).toInt(),
    );
  }

  static const Color grayIcons = Color.fromARGB(117, 5, 5, 5);

  // Método para obtener colores basados en el tema
  static Color textColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }
}