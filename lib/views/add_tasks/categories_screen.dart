import 'package:financea/model/category/category_data.dart';
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

  void _editCategory(Category category) {
    final TextEditingController nameController = TextEditingController(text: category.name);
    Color selectedColor = category.color;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text("Editar Categoría")),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Nombre"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Selecciona un color"),
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
                            child: const Text("Listo"),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      ),
                    );
                  },
                  child: const Text("Cambiar Color"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    category.name = nameController.text.trim();
                    category.colorValue = selectedColor.value;
                    category.save();
                    Navigator.pop(context); // Cierra pantalla de edición
                    setState(() {}); // Refresca lista
                  },
                  child: const Text("Guardar Cambios"),
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
      builder: (_) => AlertDialog(
        title: const Text("¿Eliminar Categoría?"),
        content: const Text("Esto no se puede deshacer."),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Eliminar"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              categoryBox.deleteAt(index);
              Navigator.pop(context); // Cierra diálogo
              setState(() {}); // Refresca lista
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Administrar Categorías")),
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
