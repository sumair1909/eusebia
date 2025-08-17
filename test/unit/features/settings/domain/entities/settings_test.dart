import 'package:flutter_test/flutter_test.dart';
import 'package:eusebia_app/core/constants/enums.dart';
import 'package:eusebia_app/features/settings/domain/entities/settings.dart';

void main() {
  group('Settings', () {
    test('should create settings with default values', () {
      // Act
      final settings = Settings.defaultSettings();

      // Assert
      expect(settings.themeMode, equals(ThemeMode.system));
      expect(settings.notificationsEnabled, isTrue);
      expect(settings.language, equals('en'));
      expect(settings.autoSaveEnabled, isTrue);
    });

    test('should create settings with custom values', () {
      // Arrange
      const themeMode = ThemeMode.dark;
      const notificationsEnabled = false;
      const language = 'es';
      const autoSaveEnabled = false;

      // Act
      const settings = Settings(
        themeMode: themeMode,
        notificationsEnabled: notificationsEnabled,
        language: language,
        autoSaveEnabled: autoSaveEnabled,
      );

      // Assert
      expect(settings.themeMode, equals(themeMode));
      expect(settings.notificationsEnabled, equals(notificationsEnabled));
      expect(settings.language, equals(language));
      expect(settings.autoSaveEnabled, equals(autoSaveEnabled));
    });

    test('should create copy with updated values', () {
      // Arrange
      const originalSettings = Settings(
        themeMode: ThemeMode.light,
        notificationsEnabled: true,
        language: 'en',
        autoSaveEnabled: true,
      );

      // Act
      final updatedSettings = originalSettings.copyWith(
        themeMode: ThemeMode.dark,
        notificationsEnabled: false,
      );

      // Assert
      expect(updatedSettings.themeMode, equals(ThemeMode.dark));
      expect(updatedSettings.notificationsEnabled, isFalse);
      expect(updatedSettings.language, equals('en')); // unchanged
      expect(updatedSettings.autoSaveEnabled, isTrue); // unchanged
    });

    test('should be equal when all properties are the same', () {
      // Arrange
      const settings1 = Settings(
        themeMode: ThemeMode.system,
        notificationsEnabled: true,
        language: 'en',
        autoSaveEnabled: false,
      );

      const settings2 = Settings(
        themeMode: ThemeMode.system,
        notificationsEnabled: true,
        language: 'en',
        autoSaveEnabled: false,
      );

      // Act & Assert
      expect(settings1, equals(settings2));
      expect(settings1.hashCode, equals(settings2.hashCode));
    });

    test('should not be equal when properties are different', () {
      // Arrange
      const settings1 = Settings(
        themeMode: ThemeMode.light,
        notificationsEnabled: true,
        language: 'en',
        autoSaveEnabled: true,
      );

      const settings2 = Settings(
        themeMode: ThemeMode.dark,
        notificationsEnabled: true,
        language: 'en',
        autoSaveEnabled: true,
      );

      // Act & Assert
      expect(settings1, isNot(equals(settings2)));
    });
  });
}
