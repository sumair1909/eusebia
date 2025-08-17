import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';

/// Use case to update theme mode
class UpdateThemeMode implements UseCase<void, String> {
  final SettingsRepository repository;

  UpdateThemeMode(this.repository);

  @override
  Future<Either<Failure, void>> call(String themeMode) async {
    return await repository.updateThemeMode(themeMode);
  }
}
