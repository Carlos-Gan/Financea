import 'dart:developer';

import 'package:financea/model/category/category_data.dart';
import 'package:financea/utils/app_icons.dart';
import 'package:financea/utils/app_str.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CategoryDropdown extends StatefulWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onChanged;
  final String hintText;
  final TextStyle? textStyle;
  final Color dropdownColor;

  const CategoryDropdown({
    super.key,
    required this.onChanged,
    required this.hintText,
    required this.selectedCategory,
    this.textStyle,
    this.dropdownColor = Colors.white,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CategoryDropdownState createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  final categoryBox = Hive.box<Category>('categories');
  final TextEditingController _newCategoryController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _initializeCategories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  Future<void> _initializeCategories() async {
    try {
      if (categoryBox.isEmpty) {
        await _addDefaultCategories();
      }
      setState(() {});
    } catch (e) {
      // Manejo de errores si es necesario
      log("Error initializing categories: $e");
    }
  }

  Future<void> _addDefaultCategories() async {
    try {
      final defaultCategories = [
        Category(
          name: 'Food',
          icon: FontAwesomeIcons.burger,
          color: Colors.yellowAccent,
        ),
        Category(
          name: 'Transport',
          icon: FontAwesomeIcons.plane,
          color: Colors.grey,
        ),
        Category(
          name: 'Education',
          icon: FontAwesomeIcons.book,
          color: Colors.blue,
        ),
        Category(
          name: 'Shopping',
          icon: FontAwesomeIcons.bagShopping,
          color: Colors.purple,
        ),
        Category(
          name: 'Bills',
          icon: FontAwesomeIcons.moneyBills,
          color: Colors.red,
        ),
      ];

      await categoryBox.addAll(defaultCategories);
    } catch (e) {
      // Manejo de errores si es necesario
      log("Error adding default categories: $e");
    }
  }

  Future<void> _addNewCategory(String name, IconData icon, Color color) async {
    if (name.trim().isEmpty) return;
    try {
      final newCategory = Category(name: name.trim(), icon: icon, color: color);

      await categoryBox.add(newCategory);
      _newCategoryController.clear();

      setState(() {
        _selectedCategory = newCategory.name;
      });

      widget.onChanged(newCategory.name);
    } catch (e) {
      // Manejo de errores si es necesario
      log("Error adding new category: $e");
    }
  }

  IconData _selectedIcon = FontAwesomeIcons.question;
  Color _selectedColor = Colors.blue;

  void _showAddCategoryDialog() {
    _selectedIcon = FontAwesomeIcons.question;
    _selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDarkMode = theme.brightness == Brightness.dark;
        return StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
                title: Text(
                  AppStr.get('addCategory'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 430,
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      child: DefaultTextStyle(
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _newCategoryController,
                              decoration: InputDecoration(
                                labelText: AppStr.get('name_category'),
                                filled: true,
                                fillColor:
                                    isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.grey[200],
                                labelStyle: theme.textTheme.bodyMedium
                                    ?.copyWith(
                                      color:
                                          isDarkMode
                                              ? Colors.white70
                                              : Colors.black87,
                                    ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Elige un ícono:",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: availableIcons.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 5,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                  ),
                              itemBuilder: (context, index) {
                                final icon = availableIcons[index];
                                final isSelected = _selectedIcon == icon;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() => _selectedIcon = icon);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? _selectedColor.withOpacity(0.2)
                                              : isDarkMode
                                              ? Colors.grey[800]
                                              : Colors.grey[200],
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? _selectedColor
                                                : Colors.transparent,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      icon,
                                      color:
                                          isSelected
                                              ? _selectedColor
                                              : isDarkMode
                                              ? Colors.white70
                                              : Colors.black87,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Color:",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (_) => AlertDialog(
                                        backgroundColor:
                                            isDarkMode
                                                ? Colors.grey[900]
                                                : Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        title: Text(
                                          "Selecciona un color",
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                                color:
                                                    isDarkMode
                                                        ? Colors.white
                                                        : Colors.black,
                                              ),
                                        ),
                                        content: SingleChildScrollView(
                                          child: BlockPicker(
                                            pickerColor: _selectedColor,
                                            onColorChanged: (color) {
                                              setState(
                                                () => _selectedColor = color,
                                              );
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ),
                                );
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.only(top: 5),
                                decoration: BoxDecoration(
                                  color: _selectedColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                actionsPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurface.withOpacity(
                        0.7,
                      ),
                    ),
                    child: Text(AppStr.get('cancel')),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final IconData iconToSave = IconData(
                        _selectedIcon.codePoint,
                        fontFamily: _selectedIcon.fontFamily,
                        fontPackage:
                            _selectedIcon.fontFamily?.contains('FontAwesome') ==
                                    true
                                ? 'font_awesome_flutter'
                                : null,
                      );
                      _addNewCategory(
                        _newCategoryController.text.trim(),
                        iconToSave,
                        _selectedColor,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(AppStr.get('save')),
                  ),
                ],
              ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        width: MediaQuery.of(context).size.width - 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: Colors.grey[300]!),
        ),
        child: ValueListenableBuilder(
          valueListenable: categoryBox.listenable(),
          builder: (context, Box<Category> box, _) {
            final categories = box.values.toList();
            return DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (value) {
                if (value == 'add_new') {
                  _showAddCategoryDialog();
                } else {
                  setState(() {
                    _selectedCategory = value;
                    widget.onChanged(value);
                  });
                }
              },
              items: [
                ...categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.name,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          Icon(category.icon, color: category.color),
                          const SizedBox(width: 10),
                          Text(category.name, style: widget.textStyle),
                        ],
                      ),
                    ),
                  );
                }),
                DropdownMenuItem<String>(
                  value: 'add_new',
                  child: Row(
                    children: [
                      const Icon(Icons.add, size: 30, color: Colors.blue),
                      const SizedBox(width: 10),
                      Text(
                        AppStr.get('addCategory'),
                        style: (widget.textStyle ?? const TextStyle()).copyWith(
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              selectedItemBuilder: (context) {
                return [
                  ...categories.map((category) {
                    return Row(
                      children: [
                        Icon(category.icon, size: 32, color: category.color),
                        const SizedBox(width: 10),
                        Text(
                          category.name,
                          style:
                              widget.textStyle ??
                              TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        ),
                      ],
                    );
                  }),
                  Row(
                    children: [
                      const Icon(Icons.add, size: 32, color: Colors.blue),
                      const SizedBox(width: 10),
                      Text(AppStr.get('addCategory')),
                    ],
                  ),
                ];
              },
              hint: Text(
                widget.hintText,
                style:
                    widget.textStyle ??
                    TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
              dropdownColor: Theme.of(context).scaffoldBackgroundColor,
              isExpanded: true,
              underline: Container(),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }
}
