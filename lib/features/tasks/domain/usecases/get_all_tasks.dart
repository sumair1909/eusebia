import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Use case to get all tasks
class GetAllTasks implements UseCase<List<Task>, NoParams> {
  final TaskRepository repository;

  const GetAllTasks(this.repository);

  @override
  Future<Either<Failure, List<Task>>> call(NoParams params) async {
    return await repository.getAllTasks();
  }
}
