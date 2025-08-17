import '../../../../core/constants/enums.dart';
import '../../domain/entities/settings.dart';

/// Settings model for data layer operations
class SettingsModel extends Settings {
  const SettingsModel({
    required super.themeMode,
    required super.notificationsEnabled,
    required super.language,
    required super.autoSaveEnabled,
  });

  /// Create settings model from entity
  factory SettingsModel.fromEntity(Settings settings) {
    return SettingsModel(
      themeMode: settings.themeMode,
      notificationsEnabled: settings.notificationsEnabled,
      language: settings.language,
      autoSaveEnabled: settings.autoSaveEnabled,
    );
  }

  /// Create settings model from JSON
  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      language: json['language'] ?? 'en',
      autoSaveEnabled: json['autoSaveEnabled'] ?? true,
    );
  }

  /// Convert settings model to JSON
  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'notificationsEnabled': notificationsEnabled,
      'language': language,
      'autoSaveEnabled': autoSaveEnabled,
    };
  }

  /// Create settings model with default values
  factory SettingsModel.defaultSettings() {
    return const SettingsModel(
      themeMode: ThemeMode.system,
      notificationsEnabled: true,
      language: 'en',
      autoSaveEnabled: true,
    );
  }

  /// Create a copy of settings model with updated values
  @override
  SettingsModel copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    String? language,
    bool? autoSaveEnabled,
  }) {
    return SettingsModel(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
      autoSaveEnabled: autoSaveEnabled ?? this.autoSaveEnabled,
    );
  }
}
