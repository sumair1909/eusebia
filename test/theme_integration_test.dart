import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eusebia_app/core/constants/enums.dart';
import 'package:eusebia_app/features/settings/data/models/settings_model.dart';

void main() {
  group('Theme Integration Tests', () {
    late SharedPreferences sharedPreferences;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
    });

    tearDown(() async {
      await sharedPreferences.clear();
    });

    test(
      'should store and retrieve theme mode from SharedPreferences',
      () async {
        // Test data
        const testThemeMode = ThemeMode.dark;
        const settingsKey = 'app_settings';
        const themeModeKey = 'theme_mode';

        // Create settings model
        final settings = SettingsModel(
          themeMode: testThemeMode,
          notificationsEnabled: true,
          language: 'en',
          autoSaveEnabled: true,
        );

        // Store settings
        final settingsJson = settings.toJson();
        await sharedPreferences.setString(settingsKey, settingsJson.toString());
        await sharedPreferences.setString(themeModeKey, testThemeMode.name);

        // Verify storage
        expect(sharedPreferences.getString(themeModeKey), equals('dark'));
        expect(sharedPreferences.getString(settingsKey), isNotNull);

        // Retrieve and verify
        final storedThemeMode = sharedPreferences.getString(themeModeKey);
        expect(storedThemeMode, equals('dark'));

        // Parse back to enum
        final parsedThemeMode = ThemeMode.values.firstWhere(
          (e) => e.name == storedThemeMode,
          orElse: () => ThemeMode.system,
        );
        expect(parsedThemeMode, equals(ThemeMode.dark));
      },
    );

    test('should handle theme mode changes correctly', () async {
      const themeModeKey = 'theme_mode';

      // Test light theme
      await sharedPreferences.setString(themeModeKey, 'light');
      var storedTheme = sharedPreferences.getString(themeModeKey);
      expect(storedTheme, equals('light'));

      // Test dark theme
      await sharedPreferences.setString(themeModeKey, 'dark');
      storedTheme = sharedPreferences.getString(themeModeKey);
      expect(storedTheme, equals('dark'));

      // Test system theme
      await sharedPreferences.setString(themeModeKey, 'system');
      storedTheme = sharedPreferences.getString(themeModeKey);
      expect(storedTheme, equals('system'));
    });

    test('should handle invalid theme mode gracefully', () async {
      const themeModeKey = 'theme_mode';

      // Test invalid theme mode
      await sharedPreferences.setString(themeModeKey, 'invalid');
      final storedTheme = sharedPreferences.getString(themeModeKey);
      expect(storedTheme, equals('invalid'));

      // Should default to system when parsing
      final parsedThemeMode = ThemeMode.values.firstWhere(
        (e) => e.name == storedTheme,
        orElse: () => ThemeMode.system,
      );
      expect(parsedThemeMode, equals(ThemeMode.system));
    });
  });
}
