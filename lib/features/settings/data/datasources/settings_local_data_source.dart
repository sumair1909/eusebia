import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/enums.dart';
import '../models/settings_model.dart';

/// Local data source for settings using SharedPreferences
abstract class SettingsLocalDataSource {
  /// Get settings from local storage
  Future<SettingsModel> getSettings();

  /// Save settings to local storage
  Future<void> saveSettings(SettingsModel settings);

  /// Update theme mode in local storage
  Future<void> updateThemeMode(String themeMode);

  /// Update notification settings in local storage
  Future<void> updateNotificationSettings(bool enabled);

  /// Update language settings in local storage
  Future<void> updateLanguage(String language);

  /// Update auto-save settings in local storage
  Future<void> updateAutoSaveSettings(bool enabled);
}

/// Implementation of settings local data source
class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _settingsKey = 'app_settings';
  static const String _themeModeKey = 'theme_mode';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _languageKey = 'language';
  static const String _autoSaveKey = 'auto_save_enabled';

  SettingsLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<SettingsModel> getSettings() async {
    try {
      // Try to get complete settings object first
      final settingsJson = sharedPreferences.getString(_settingsKey);
      if (settingsJson != null) {
        final Map<String, dynamic> settingsMap = Map<String, dynamic>.from(
          settingsJson as Map<String, dynamic>,
        );
        return SettingsModel.fromJson(settingsMap);
      }

      // Fallback to individual keys for backward compatibility
      final themeMode = sharedPreferences.getString(_themeModeKey) ?? 'system';
      final notificationsEnabled =
          sharedPreferences.getBool(_notificationsKey) ?? true;
      final language = sharedPreferences.getString(_languageKey) ?? 'en';
      final autoSaveEnabled = sharedPreferences.getBool(_autoSaveKey) ?? true;

      return SettingsModel(
        themeMode: _parseThemeMode(themeMode),
        notificationsEnabled: notificationsEnabled,
        language: language,
        autoSaveEnabled: autoSaveEnabled,
      );
    } catch (e) {
      // Return default settings if any error occurs
      return SettingsModel.defaultSettings();
    }
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    try {
      // Save complete settings object
      final settingsJson = settings.toJson();
      await sharedPreferences.setString(_settingsKey, settingsJson.toString());

      // Also save individual keys for backward compatibility
      await sharedPreferences.setString(_themeModeKey, settings.themeMode.name);
      await sharedPreferences.setBool(
        _notificationsKey,
        settings.notificationsEnabled,
      );
      await sharedPreferences.setString(_languageKey, settings.language);
      await sharedPreferences.setBool(_autoSaveKey, settings.autoSaveEnabled);
    } catch (e) {
      throw Exception('Failed to save settings: $e');
    }
  }

  @override
  Future<void> updateThemeMode(String themeMode) async {
    try {
      await sharedPreferences.setString(_themeModeKey, themeMode);

      // Update the complete settings object as well
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        themeMode: _parseThemeMode(themeMode),
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw Exception('Failed to update theme mode: $e');
    }
  }

  @override
  Future<void> updateNotificationSettings(bool enabled) async {
    try {
      await sharedPreferences.setBool(_notificationsKey, enabled);

      // Update the complete settings object as well
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        notificationsEnabled: enabled,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw Exception('Failed to update notification settings: $e');
    }
  }

  @override
  Future<void> updateLanguage(String language) async {
    try {
      await sharedPreferences.setString(_languageKey, language);

      // Update the complete settings object as well
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(language: language);
      await saveSettings(updatedSettings);
    } catch (e) {
      throw Exception('Failed to update language: $e');
    }
  }

  @override
  Future<void> updateAutoSaveSettings(bool enabled) async {
    try {
      await sharedPreferences.setBool(_autoSaveKey, enabled);

      // Update the complete settings object as well
      final currentSettings = await getSettings();
      final updatedSettings = currentSettings.copyWith(
        autoSaveEnabled: enabled,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw Exception('Failed to update auto-save settings: $e');
    }
  }

  /// Parse theme mode string to ThemeMode enum
  dynamic _parseThemeMode(String themeMode) {
    switch (themeMode.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
