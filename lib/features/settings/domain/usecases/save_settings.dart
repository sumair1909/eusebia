import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/settings.dart';
import '../repositories/settings_repository.dart';

/// Use case to save settings
class SaveSettings implements UseCase<void, Settings> {
  final SettingsRepository repository;

  SaveSettings(this.repository);

  @override
  Future<Either<Failure, void>> call(Settings settings) async {
    return await repository.saveSettings(settings);
  }
}
