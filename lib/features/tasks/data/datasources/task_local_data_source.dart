import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../models/task_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/task.dart';

/// Local data source for tasks using SQLite
abstract class TaskLocalDataSource {
  /// Get all tasks from local storage
  Future<List<TaskModel>> getAllTasks();

  /// Get task by id from local storage
  Future<TaskModel?> getTaskById(String id);

  /// Save task to local storage
  Future<void> saveTask(TaskModel task);

  /// Update task in local storage
  Future<void> updateTask(TaskModel task);

  /// Delete task from local storage
  Future<void> deleteTask(String id);

  /// Clear all tasks from local storage
  Future<void> clearAllTasks();

  /// Search tasks by query
  Future<List<TaskModel>> searchTasks(String query);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Database database;

  const TaskLocalDataSourceImpl(this.database);

  @override
  Future<List<TaskModel>> getAllTasks() async {
    final List<Map<String, dynamic>> rows = await database.query(
      AppConstants.tasksTable,
      orderBy: '${AppConstants.createdAtColumn} DESC',
    );
    return rows.map((row) => _fromRow(row)).toList();
  }

  @override
  Future<TaskModel?> getTaskById(String id) async {
    final List<Map<String, dynamic>> rows = await database.query(
      AppConstants.tasksTable,
      where: '${AppConstants.idColumn} = ?',
      whereArgs: [id],
    );
    if (rows.isNotEmpty) {
      return _fromRow(rows.first);
    }
    return null;
  }

  @override
  Future<void> saveTask(TaskModel task) async {
    await database.insert(AppConstants.tasksTable, _toRow(task));
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await database.update(
      AppConstants.tasksTable,
      _toRow(task),
      where: '${AppConstants.idColumn} = ?',
      whereArgs: [task.id],
    );
  }

  @override
  Future<void> deleteTask(String id) async {
    await database.delete(
      AppConstants.tasksTable,
      where: '${AppConstants.idColumn} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> clearAllTasks() async {
    await database.delete(AppConstants.tasksTable);
  }

  @override
  Future<List<TaskModel>> searchTasks(String query) async {
    final List<Map<String, dynamic>> rows = await database.query(
      AppConstants.tasksTable,
      where:
          '${AppConstants.titleColumn} LIKE ? OR ${AppConstants.descriptionColumn} LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: '${AppConstants.createdAtColumn} DESC',
    );
    return rows.map((row) => _fromRow(row)).toList();
  }

  /// Convert database row to TaskModel
  TaskModel _fromRow(Map<String, dynamic> row) {
    return TaskModel(
      id: row[AppConstants.idColumn] as String,
      title: row[AppConstants.titleColumn] as String,
      description: row[AppConstants.descriptionColumn] as String?,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == row[AppConstants.statusColumn],
        orElse: () => TaskStatus.pending,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == row[AppConstants.priorityColumn],
        orElse: () => TaskPriority.medium,
      ),
      createdAt: DateTime.parse(row[AppConstants.createdAtColumn] as String),
      dueDate: row[AppConstants.dueDateColumn] != null
          ? DateTime.parse(row[AppConstants.dueDateColumn] as String)
          : null,
      completedAt: row[AppConstants.completedAtColumn] != null
          ? DateTime.parse(row[AppConstants.completedAtColumn] as String)
          : null,
      tags: row[AppConstants.tagsColumn] != null
          ? List<String>.from(
              jsonDecode(row[AppConstants.tagsColumn] as String),
            )
          : [],
      labels: row[AppConstants.labelsColumn] != null
          ? List<String>.from(
              jsonDecode(row[AppConstants.labelsColumn] as String),
            )
          : [],
    );
  }

  /// Convert TaskModel to database row
  Map<String, dynamic> _toRow(TaskModel task) {
    return {
      AppConstants.idColumn: task.id,
      AppConstants.titleColumn: task.title,
      AppConstants.descriptionColumn: task.description,
      AppConstants.statusColumn: task.status.name,
      AppConstants.priorityColumn: task.priority.name,
      AppConstants.dueDateColumn: task.dueDate?.toIso8601String(),
      AppConstants.completedAtColumn: task.completedAt?.toIso8601String(),
      AppConstants.tagsColumn: jsonEncode(task.tags),
      AppConstants.labelsColumn: jsonEncode(task.labels),
      AppConstants.createdAtColumn: task.createdAt.toIso8601String(),
      AppConstants.updatedAtColumn: DateTime.now().toIso8601String(),
    };
  }
}
