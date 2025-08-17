import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/settings.dart';

/// Repository interface for settings operations
abstract class SettingsRepository {
  /// Get current settings
  Future<Either<Failure, Settings>> getSettings();

  /// Save settings
  Future<Either<Failure, void>> saveSettings(Settings settings);

  /// Update theme mode
  Future<Either<Failure, void>> updateThemeMode(String themeMode);

  /// Update notification settings
  Future<Either<Failure, void>> updateNotificationSettings(bool enabled);

  /// Update language settings
  Future<Either<Failure, void>> updateLanguage(String language);

  /// Update auto-save settings
  Future<Either<Failure, void>> updateAutoSaveSettings(bool enabled);
}
