import 'package:dartz/dartz.dart' hide Task;
import '../error/failures.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';

/// Service for handling data synchronization
class SyncService {
  final TaskRepository _taskRepository;

  const SyncService(this._taskRepository);

  /// Sync tasks with remote database
  Future<Either<Failure, bool>> syncTasks() async {
    return await _taskRepository.syncWithRemote();
  }

  /// Get tasks that need to be synced
  Future<Either<Failure, List<dynamic>>> getTasksToSync() async {
    return await _taskRepository.getTasksToSync();
  }
}
