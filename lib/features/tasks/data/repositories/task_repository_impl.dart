import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/error/failures.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  final TaskLocalDataSource localDataSource;

  const TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Task>>> getAllTasks() async {
    try {
      // Try to get from local first for offline support
      final localTasks = await localDataSource.getAllTasks();
      if (localTasks.isNotEmpty) {
        return Right(localTasks.map((model) => model.toEntity()).toList());
      }

      // TODO: Uncomment when remote API is ready
      // // If local is empty, try remote
      // final remoteTasks = await remoteDataSource.getAllTasks();
      //
      // // Cache remote data locally
      // for (final task in remoteTasks) {
      //   await localDataSource.saveTask(task);
      // }
      //
      // return Right(remoteTasks.map((model) => model.toEntity()).toList());

      // For now, return local tasks only
      return Right(localTasks.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> getTaskById(String id) async {
    try {
      // Try local first
      final localTask = await localDataSource.getTaskById(id);
      if (localTask != null) {
        return Right(localTask.toEntity());
      }

      // TODO: Uncomment when remote API is ready
      // // If not found locally, try remote
      // final remoteTask = await remoteDataSource.getTaskById(id);
      // await localDataSource.saveTask(remoteTask);
      // return Right(remoteTask.toEntity());

      return Left(CacheFailure('Task not found'));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> createTask(Task task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);

      // TODO: Uncomment when remote API is ready
      // // Save to remote first
      // final remoteTask = await remoteDataSource.createTask(taskModel);
      //
      // // Then cache locally
      // await localDataSource.saveTask(remoteTask);
      //
      // return Right(remoteTask.toEntity());

      // For now, save locally only
      await localDataSource.saveTask(taskModel);
      return Right(taskModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> updateTask(Task task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);

      // TODO: Uncomment when remote API is ready
      // // Update remote first
      // final remoteTask = await remoteDataSource.updateTask(taskModel);
      //
      // // Then update local cache
      // await localDataSource.updateTask(remoteTask);
      //
      // return Right(remoteTask.toEntity());

      // For now, update locally only
      await localDataSource.updateTask(taskModel);
      return Right(taskModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteTask(String id) async {
    try {
      // TODO: Uncomment when remote API is ready
      // // Delete from remote first
      // await remoteDataSource.deleteTask(id);

      // Then delete from local cache
      await localDataSource.deleteTask(id);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByStatus(
    TaskStatus status,
  ) async {
    try {
      final allTasks = await getAllTasks();
      return allTasks.map(
        (tasks) => tasks.where((task) => task.status == status).toList(),
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByPriority(
    TaskPriority priority,
  ) async {
    try {
      final allTasks = await getAllTasks();
      return allTasks.map(
        (tasks) => tasks.where((task) => task.priority == priority).toList(),
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getOverdueTasks() async {
    try {
      final allTasks = await getAllTasks();
      return allTasks.map(
        (tasks) => tasks.where((task) => task.isOverdue).toList(),
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksDueToday() async {
    try {
      final allTasks = await getAllTasks();
      return allTasks.map(
        (tasks) => tasks.where((task) => task.isDueToday).toList(),
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByTags(List<String> tags) async {
    try {
      final allTasks = await getAllTasks();
      return allTasks.map(
        (tasks) => tasks
            .where((task) => tags.any((tag) => task.tags.contains(tag)))
            .toList(),
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllLabels() async {
    try {
      final allTasks = await getAllTasks();
      return allTasks.map((tasks) {
        final allLabels = <String>{};
        for (final task in tasks) {
          allLabels.addAll(task.labels);
        }
        return allLabels.toList()..sort();
      });
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
