import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), elevation: 0),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading settings: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(settingsProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (settings) => _SettingsContent(settings: settings),
      ),
    );
  }
}

class _SettingsContent extends ConsumerWidget {
  final dynamic settings;

  const _SettingsContent({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Appearance'),
        _buildThemeModeTile(context, ref),
        const SizedBox(height: 24),

        _buildSectionHeader('Notifications'),
        _buildNotificationTile(context, ref),
        const SizedBox(height: 24),

        _buildSectionHeader('General'),
        _buildLanguageTile(context, ref),
        _buildAutoSaveTile(context, ref),
        const SizedBox(height: 24),

        _buildSectionHeader('About'),
        _buildAboutTile(context),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildThemeModeTile(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.palette),
        title: const Text('Theme Mode'),
        subtitle: Text(_getThemeModeDisplayName(settings.themeMode)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showThemeModeDialog(context, ref),
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, WidgetRef ref) {
    return Card(
      child: SwitchListTile(
        secondary: const Icon(Icons.notifications),
        title: const Text('Notifications'),
        subtitle: const Text('Enable push notifications'),
        value: settings.notificationsEnabled,
        onChanged: (value) {
          ref.read(settingsProvider.notifier).updateNotifications(value);
        },
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.language),
        title: const Text('Language'),
        subtitle: Text(_getLanguageDisplayName(settings.language)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showLanguageDialog(context, ref),
      ),
    );
  }

  Widget _buildAutoSaveTile(BuildContext context, WidgetRef ref) {
    return Card(
      child: SwitchListTile(
        secondary: const Icon(Icons.save),
        title: const Text('Auto Save'),
        subtitle: const Text('Automatically save changes'),
        value: settings.autoSaveEnabled,
        onChanged: (value) {
          ref.read(settingsProvider.notifier).updateAutoSave(value);
        },
      ),
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.info),
        title: const Text('About'),
        subtitle: const Text('App version and information'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showAboutDialog(context),
      ),
    );
  }

  void _showThemeModeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((themeMode) {
            return RadioListTile<ThemeMode>(
              title: Text(_getThemeModeDisplayName(themeMode)),
              value: themeMode,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateTheme(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final languages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'es', 'name': 'Español'},
      {'code': 'fr', 'name': 'Français'},
      {'code': 'de', 'name': 'Deutsch'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) {
            return RadioListTile<String>(
              title: Text(language['name']!),
              value: language['code']!,
              groupValue: settings.language,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateLanguage(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Eusebia'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('A modern task management app built with Flutter.'),
            SizedBox(height: 16),
            Text('Features:'),
            Text('• Clean Architecture'),
            Text('• Riverpod State Management'),
            Text('• Local Storage'),
            Text('• Theme Support'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      default:
        return 'English';
    }
  }

  String _getThemeModeDisplayName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}
