import '../../../../core/constants/enums.dart';

/// Settings entity representing user preferences
class Settings {
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final String language;
  final bool autoSaveEnabled;

  const Settings({
    required this.themeMode,
    required this.notificationsEnabled,
    required this.language,
    required this.autoSaveEnabled,
  });

  /// Create settings with default values
  factory Settings.defaultSettings() {
    return const Settings(
      themeMode: ThemeMode.system,
      notificationsEnabled: true,
      language: 'en',
      autoSaveEnabled: true,
    );
  }

  /// Create a copy of settings with updated values
  Settings copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    String? language,
    bool? autoSaveEnabled,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
      autoSaveEnabled: autoSaveEnabled ?? this.autoSaveEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Settings &&
        other.themeMode == themeMode &&
        other.notificationsEnabled == notificationsEnabled &&
        other.language == language &&
        other.autoSaveEnabled == autoSaveEnabled;
  }

  @override
  int get hashCode {
    return themeMode.hashCode ^
        notificationsEnabled.hashCode ^
        language.hashCode ^
        autoSaveEnabled.hashCode;
  }

  @override
  String toString() {
    return 'Settings(themeMode: $themeMode, notificationsEnabled: $notificationsEnabled, language: $language, autoSaveEnabled: $autoSaveEnabled)';
  }
}
