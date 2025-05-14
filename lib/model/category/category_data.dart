import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category_data.g.dart';

@HiveType(typeId: 3)
class Category extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int iconCodePoint;

  @HiveField(2)
  String fontFamily;

  @HiveField(3)
  int colorValue;

  Category({required this.name, required IconData icon, required Color color})
    : iconCodePoint = icon.codePoint,
      fontFamily = icon.fontFamily ?? 'MaterialIcons',
      // ignore: deprecated_member_use
      colorValue = color.value;

  IconData get icon => IconData(
    iconCodePoint,
    fontFamily: fontFamily,
    fontPackage: _getFontPackage(),
  );
  Color get color => Color(colorValue);

  String? _getFontPackage() {
    // Ajusta esto si usas otras familias también
    if (fontFamily.contains('FontAwesome')) {
      return 'font_awesome_flutter';
    }
    return null;
  }
}
