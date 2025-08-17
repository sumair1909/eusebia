import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/settings.dart';
import '../repositories/settings_repository.dart';

/// Use case to get current settings
class GetSettings implements UseCase<Settings, NoParams> {
  final SettingsRepository repository;

  GetSettings(this.repository);

  @override
  Future<Either<Failure, Settings>> call(NoParams params) async {
    return await repository.getSettings();
  }
}
