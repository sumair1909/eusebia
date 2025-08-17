import 'package:dio/dio.dart';
import '../models/task_model.dart';

/// Remote data source for tasks using HTTP API
abstract class TaskRemoteDataSource {
  /// Get all tasks from remote API
  Future<List<TaskModel>> getAllTasks();

  /// Get task by id from remote API
  Future<TaskModel> getTaskById(String id);

  /// Create task via remote API
  Future<TaskModel> createTask(TaskModel task);

  /// Update task via remote API
  Future<TaskModel> updateTask(TaskModel task);

  /// Delete task via remote API
  Future<void> deleteTask(String id);

  /// Get tasks modified since a specific timestamp
  Future<List<TaskModel>> getTasksModifiedSince(DateTime since);

  /// Batch update tasks
  Future<List<TaskModel>> batchUpdateTasks(List<TaskModel> tasks);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio dio;
  static const String _basePath = '/tasks';

  const TaskRemoteDataSourceImpl(this.dio);

  @override
  Future<List<TaskModel>> getAllTasks() async {
    try {
      final response = await dio.get(_basePath);
      final List<dynamic> tasksJson = response.data['data'] ?? [];
      return tasksJson.map((taskJson) => TaskModel.fromJson(taskJson)).toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<TaskModel> getTaskById(String id) async {
    try {
      final response = await dio.get('$_basePath/$id');
      return TaskModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final response = await dio.post(_basePath, data: task.toJson());
      return TaskModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final response = await dio.put(
        '$_basePath/${task.id}',
        data: task.toJson(),
      );
      return TaskModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await dio.delete('$_basePath/$id');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Handle Dio exceptions and convert to appropriate errors
  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          return Exception('Task not found');
        } else if (statusCode == 400) {
          return Exception('Bad request');
        } else if (statusCode == 500) {
          return Exception('Server error');
        }
        return Exception('HTTP error: $statusCode');
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      default:
        return Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<List<TaskModel>> getTasksModifiedSince(DateTime since) async {
    try {
      final response = await dio.get(
        '$_basePath/sync',
        queryParameters: {'since': since.toIso8601String()},
      );
      final List<dynamic> tasksJson = response.data['data'] ?? [];
      return tasksJson.map((taskJson) => TaskModel.fromJson(taskJson)).toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<TaskModel>> batchUpdateTasks(List<TaskModel> tasks) async {
    try {
      final response = await dio.post(
        '$_basePath/batch',
        data: {'tasks': tasks.map((task) => task.toJson()).toList()},
      );
      final List<dynamic> tasksJson = response.data['data'] ?? [];
      return tasksJson.map((taskJson) => TaskModel.fromJson(taskJson)).toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }
}
