import 'package:financea/utils/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:financea/views/widgets/bottomnavbar.dart';
import 'package:provider/provider.dart';

class NewUserScreen extends StatefulWidget {
  const NewUserScreen({super.key});

  @override
  State<NewUserScreen> createState() => _NewUserScreenState();
}

class _NewUserScreenState extends State<NewUserScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? selectedLanguage = 'English';
  final List<String> languages = ['English', 'Español', 'Français', 'Deutsch'];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userName') ?? '';
      selectedLanguage = prefs.getString('language') ?? 'English';
    });
  }

  void _saveData() async {
    if (_nameController.text.isEmpty || selectedLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    await prefs.setString('userName', _nameController.text);
    await prefs.setString('language', selectedLanguage!);

    Provider.of<UserSettings>(context, listen: false)
      ..setUsername(_nameController.text)
      ..setLanguage(selectedLanguage!);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BottomNavBar()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSettings>(
      builder: (context, userSettings, child) {
        final theme = Theme.of(context);
        return Scaffold(
          backgroundColor: theme.colorScheme.background,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_circle,
                    size: 100,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome to Financea',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Let’s personalize your experience',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Your Name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedLanguage,
                    items: languages.map((lang) {
                      return DropdownMenuItem(
                        value: lang,
                        child: Text(lang),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedLanguage = value),
                    decoration: InputDecoration(
                      labelText: 'Preferred Language',
                      prefixIcon: const Icon(Icons.language),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Continue'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _saveData,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}