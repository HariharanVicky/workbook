import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/category_provider.dart';
import 'categories_screen.dart';
import 'pin_setup_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          final hasPin = settingsProvider.isPinSet();
          final pinEnabled = settingsProvider.pinEnabled;
          return ListView(
            children: [
              // Theme Settings
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Appearance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Theme'),
                trailing: DropdownButton<ThemeMode>(
                  value: settingsProvider.themeMode,
                  onChanged: (ThemeMode? newMode) {
                    if (newMode != null) {
                      settingsProvider.setThemeMode(newMode);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Security Settings
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Security',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(
                    pinEnabled ? Icons.lock : Icons.lock_open,
                    color: pinEnabled ? Colors.green : Colors.grey,
                  ),
                  title: Text(
                    hasPin ? (pinEnabled ? 'PIN is enabled' : 'PIN is set but not enabled') : 'No PIN is set',
                  ),
                  subtitle: Text(
                    hasPin
                        ? 'You can change or remove your PIN.'
                        : 'Set a 4-digit PIN to secure your app.'
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PinSetupScreen(),
                        ),
                      );
                    },
                    child: Text(hasPin ? 'Change PIN' : 'Set PIN'),
                  ),
                ),
              ),
              const Divider(),

              // Currency Settings
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Financial',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Currency'),
                trailing: DropdownButton<String>(
                  value: settingsProvider.currency,
                  onChanged: (String? newCurrency) {
                    if (newCurrency != null) {
                      settingsProvider.setCurrency(newCurrency);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: 'USD',
                      child: Text('USD'),
                    ),
                    DropdownMenuItem(
                      value: 'INR',
                      child: Text('INR'),
                    ),
                    DropdownMenuItem(
                      value: 'EUR',
                      child: Text('EUR'),
                    ),
                    DropdownMenuItem(
                      value: 'GBP',
                      child: Text('GBP'),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Categories Management
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Manage Categories'),
                subtitle: const Text('Add, edit, or delete expense and income categories'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoriesScreen(),
                    ),
                  );
                },
              ),
              const Divider(),

              // About Section
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'About',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('App Version'),
                subtitle: const Text('1.0.0'),
              ),
            ],
          );
        },
      ),
    );
  }
} 