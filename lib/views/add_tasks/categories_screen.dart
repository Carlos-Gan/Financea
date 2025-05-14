import 'package:financea/model/category/category_data.dart';
import 'package:financea/utils/app_str.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive/hive.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final categoryBox = Hive.box<Category>('categories');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
    categoryBox.values.toList();
  }

  void _editCategory(Category category) {
    final TextEditingController nameController = TextEditingController(
      text: category.name,
    );
    Color selectedColor = category.color;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => Scaffold(
              appBar: AppBar(title: Text(AppStr.get('editarCategory'))),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: AppStr.get("name_category"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: Text(AppStr.get("selectColor")),
                                content: SingleChildScrollView(
                                  child: ColorPicker(
                                    pickerColor: selectedColor,
                                    onColorChanged: (color) {
                                      setState(() => selectedColor = color);
                                    },
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: Text(AppStr.get("listo")),
                                    onPressed: () => Navigator.pop(context, true),
                                  ),
                                ],
                              ),
                        );
                      },
                      child: Text(AppStr.get("changeColor")),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        category.name = nameController.text.trim();
                        // ignore: deprecated_member_use
                        category.colorValue = selectedColor.value;
                        category.save();
                        Navigator.pop(context, true); // Cierra pantalla de edición
                        setState(() {}); // Refresca lista
                      },
                      child: Text(AppStr.get('save')),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  void _deleteCategory(int index) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(AppStr.get("eliminarCategoria")),
            content: Text(AppStr.get("noSePuedeDeshacer")),
            actions: [
              TextButton(
                child: Text(AppStr.get('cancel')),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  categoryBox.deleteAt(index);
                  Navigator.pop(context); // Cierra diálogo
                  setState(() {}); // Refresca lista
                },
                child: Text(
                  AppStr.get('delete'),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStr.get('administrarCategory')
      )
      
      ),
      body: ListView.builder(
        itemCount: categoryBox.length,
        itemBuilder: (context, index) {
          final category = categoryBox.getAt(index)!;

          return ListTile(
            leading: Icon(category.icon, color: category.color),
            title: Text(category.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editCategory(category),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCategory(index),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
