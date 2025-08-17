import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/enums.dart';
import '../usecases/usecase.dart';
import '../di/injection_container.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_settings.dart';

/// Provider for app theme state
class ThemeNotifier extends StateNotifier<ThemeMode> {
  final GetSettings getSettings;

  ThemeNotifier({required this.getSettings}) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  /// Load theme mode from settings
  Future<void> _loadThemeMode() async {
    try {
      final result = await getSettings(const NoParams());
      result.fold(
        (failure) => state = ThemeMode.system,
        (settings) => state = settings.themeMode,
      );
    } catch (e) {
      state = ThemeMode.system;
    }
  }

  /// Update theme mode
  void updateThemeMode(ThemeMode themeMode) {
    state = themeMode;
  }

  /// Get Flutter's ThemeMode from our custom ThemeMode
  ThemeMode get flutterThemeMode {
    switch (state) {
      case ThemeMode.light:
        return ThemeMode.light;
      case ThemeMode.dark:
        return ThemeMode.dark;
      case ThemeMode.system:
        return ThemeMode.system;
    }
  }
}

/// Provider for theme notifier
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(getSettings: ref.read(getSettingsProvider));
});

/// Provider for Flutter's ThemeMode
final flutterThemeModeProvider = Provider<ThemeMode>((ref) {
  final themeNotifier = ref.watch(themeProvider.notifier);
  return themeNotifier.flutterThemeMode;
});

/// Provider for get settings use case (for theme provider)
final getSettingsProvider = Provider<GetSettings>((ref) {
  return GetSettings(sl<SettingsRepository>());
});
