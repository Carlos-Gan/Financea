import 'package:financea/utils/app_colors.dart';
import 'package:financea/utils/app_str.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Clase para manejar las configuraciones de usuario
class UserSettings extends ChangeNotifier {
  String _username = 'User123';
  String _selectedLanguage = 'English';

  String get username => _username;
  String get selectedLanguage => _selectedLanguage;

  void setUsername(String newUsername) {
    _username = newUsername;
    notifyListeners();
  }

  void setLanguage(String newLanguage) {
    _selectedLanguage = newLanguage;
    notifyListeners();
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Opciones de idioma disponibles
  final List<String> _languages = ['Español', 'English', 'Français', 'Deutsch'];

  @override
  Widget build(BuildContext context) {
    // Proveedor de configuraciones de usuario;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title:  Text(AppStr.get('settings')),
          backgroundColor: AppColors.secondaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStr.get("getsettingsProfile"),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Sección para cambiar el nombre de usuario
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStr.get('userName'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Consumer<UserSettings>(
                        builder: (context, settings, child) {
                          return Row(
                            children: [
                              Expanded(child: Text(settings.username)),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showUsernameDialog();
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                AppStr.get('settingsLang'),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Sección para cambiar el idioma
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStr.get('language'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Consumer<UserSettings>(
                        builder: (context, settings, child) {
                          return DropdownButton<String>(
                            value: settings.selectedLanguage,
                            isExpanded: true,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                AppStr.setLang(newValue);
                                Provider.of<UserSettings>(
                                  context,
                                  listen: false,
                                ).setLanguage(newValue);
                              }
                            },
                            items:
                                _languages.map<DropdownMenuItem<String>>((
                                  String value,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botón para guardar cambios
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppStr.get('configSavedMessage')),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    AppStr.get('save'),
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para mostrar el diálogo de cambio de nombre de usuario
  void _showUsernameDialog() {
    final userSettings = Provider.of<UserSettings>(context, listen: false);
    final TextEditingController _usernameController = TextEditingController(
      text: userSettings.username,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title:  Text(AppStr.get("changeUsername")),
            content: TextField(
              controller: _usernameController,
              decoration:  InputDecoration(
                hintText: AppStr.get("inputUsername"),
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(AppStr.get("cancel")),
              ),
              ElevatedButton(
                onPressed: () {
                  userSettings.setUsername(_usernameController.text);
                  Navigator.pop(context);
                },
                child:  Text(AppStr.get("save")),
              ),
            ],
          ),
    );
  }
}
