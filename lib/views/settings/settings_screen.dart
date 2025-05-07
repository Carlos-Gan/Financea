import 'package:financea/utils/app_colors.dart';
import 'package:financea/utils/app_str.dart';
import 'package:financea/utils/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<String> _languages = ['English', 'Español', 'Français', 'Deutsch'];

  @override
  Widget build(BuildContext context) {
    // Use Consumer pattern for more reliable provider access
    return Consumer<UserSettings>(
      builder: (context, userSettings, child) {
        if (userSettings.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: AppColors.secondaryColor,
            statusBarIconBrightness: Brightness.light,
          ),
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                AppStr.get('settings'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: AppColors.secondaryColor,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: _buildBodyContent(),
          ),
        );
      },
    );
  }

  Widget _buildBodyContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionTitle(AppStr.get("settingsProfile")),
          const SizedBox(height: 12),
          _buildUsernameCard(),
          const SizedBox(height: 24),
          _buildSectionTitle(AppStr.get("settingsLang")),
          const SizedBox(height: 12),
          _buildLanguageCard(),
          const SizedBox(height: 32),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildUsernameCard() {
    return Consumer<UserSettings>(
      builder: (context, settings, _) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                AppStr.get('userName'),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              subtitle: Text(
                settings.username.isEmpty
                    ? AppStr.get('notSet')
                    : settings.username,
                style: const TextStyle(color: Colors.black),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.black54),
                onPressed: () => _showUsernameDialog(context),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageCard() {
    return Consumer<UserSettings>(
      builder: (context, settings, _) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStr.get('language'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: settings.selectedLanguage,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                  isExpanded: true,
                  items:
                      _languages.map((String lang) {
                        return DropdownMenuItem<String>(
                          value: lang,
                          child: Text(lang),
                        );
                      }).toList(),
                  onChanged: (String? newValue) async {
                    if (newValue != null) {
                      await settings.setLanguage(newValue);
                      AppStr.setLang(newValue);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.save, color: Colors.white),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStr.get('configSavedMessage')),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        label: Text(
          AppStr.get('save'),
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _showUsernameDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _usernameController = TextEditingController(
          text: Provider.of<UserSettings>(context, listen: false).username,
        );

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            AppStr.get("changeUsername"),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: _usernameController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: AppStr.get("inputUsername"),
              hintStyle: const TextStyle(color: Colors.black54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.secondaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: const TextStyle(color: Colors.black, fontSize: 16),
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppStr.get("cancel"),
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onPressed: () async {
                if (_usernameController.text.trim().isNotEmpty) {
                  await Provider.of<UserSettings>(
                    context,
                    listen: false,
                  ).setUsername(_usernameController.text.trim());
                  if (mounted) Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppStr.get("usernameEmptyError")),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(
                AppStr.get("save"),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        );
      },
    );
  }
}