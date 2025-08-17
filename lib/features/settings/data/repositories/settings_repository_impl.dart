import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/failures.dart' as failures;
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';
import '../models/settings_model.dart';

/// Implementation of settings repository
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Settings>> getSettings() async {
    try {
      final settingsModel = await localDataSource.getSettings();
      return Right(settingsModel);
    } catch (e) {
      return Left(failures.CacheFailure('Failed to get settings from cache'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSettings(Settings settings) async {
    try {
      final settingsModel = SettingsModel.fromEntity(settings);
      await localDataSource.saveSettings(settingsModel);
      return const Right(null);
    } catch (e) {
      return Left(failures.CacheFailure('Failed to save settings to cache'));
    }
  }

  @override
  Future<Either<Failure, void>> updateThemeMode(String themeMode) async {
    try {
      await localDataSource.updateThemeMode(themeMode);
      return const Right(null);
    } catch (e) {
      return Left(
        failures.CacheFailure('Failed to update theme mode in cache'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateNotificationSettings(bool enabled) async {
    try {
      await localDataSource.updateNotificationSettings(enabled);
      return const Right(null);
    } catch (e) {
      return Left(
        failures.CacheFailure(
          'Failed to update notification settings in cache',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateLanguage(String language) async {
    try {
      await localDataSource.updateLanguage(language);
      return const Right(null);
    } catch (e) {
      return Left(failures.CacheFailure('Failed to update language in cache'));
    }
  }

  @override
  Future<Either<Failure, void>> updateAutoSaveSettings(bool enabled) async {
    try {
      await localDataSource.updateAutoSaveSettings(enabled);
      return const Right(null);
    } catch (e) {
      return Left(
        failures.CacheFailure('Failed to update auto-save settings in cache'),
      );
    }
  }
}
