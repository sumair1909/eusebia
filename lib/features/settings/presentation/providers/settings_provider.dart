import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/save_settings.dart';
import '../../domain/usecases/update_theme_mode.dart';

/// Provider for settings state management
class SettingsNotifier extends StateNotifier<AsyncValue<Settings>> {
  final GetSettings getSettings;
  final SaveSettings saveSettings;
  final UpdateThemeMode updateThemeMode;

  SettingsNotifier({
    required this.getSettings,
    required this.saveSettings,
    required this.updateThemeMode,
  }) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  /// Load settings from storage
  Future<void> _loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final result = await getSettings(const NoParams());
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (settings) => state = AsyncValue.data(settings),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Update theme mode
  Future<void> updateTheme(ThemeMode themeMode) async {
    if (state.value == null) return;

    try {
      final result = await updateThemeMode(themeMode.name);
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (_) {
          final updatedSettings = state.value!.copyWith(themeMode: themeMode);
          state = AsyncValue.data(updatedSettings);
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Update notification settings
  Future<void> updateNotifications(bool enabled) async {
    if (state.value == null) return;

    try {
      final updatedSettings = state.value!.copyWith(
        notificationsEnabled: enabled,
      );
      final result = await saveSettings(updatedSettings);
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (_) => state = AsyncValue.data(updatedSettings),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Update language settings
  Future<void> updateLanguage(String language) async {
    if (state.value == null) return;

    try {
      final updatedSettings = state.value!.copyWith(language: language);
      final result = await saveSettings(updatedSettings);
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (_) => state = AsyncValue.data(updatedSettings),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Update auto-save settings
  Future<void> updateAutoSave(bool enabled) async {
    if (state.value == null) return;

    try {
      final updatedSettings = state.value!.copyWith(autoSaveEnabled: enabled);
      final result = await saveSettings(updatedSettings);
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (_) => state = AsyncValue.data(updatedSettings),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refresh settings
  Future<void> refresh() async {
    await _loadSettings();
  }
}

/// Provider for settings notifier
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<Settings>>(
      (ref) => SettingsNotifier(
        getSettings: ref.read(getSettingsProvider),
        saveSettings: ref.read(saveSettingsProvider),
        updateThemeMode: ref.read(updateThemeModeProvider),
      ),
    );

/// Provider for get settings use case
final getSettingsProvider = Provider<GetSettings>((ref) {
  return GetSettings(sl<SettingsRepository>());
});

/// Provider for save settings use case
final saveSettingsProvider = Provider<SaveSettings>((ref) {
  return SaveSettings(sl<SettingsRepository>());
});

/// Provider for update theme mode use case
final updateThemeModeProvider = Provider<UpdateThemeMode>((ref) {
  return UpdateThemeMode(sl<SettingsRepository>());
});
