import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../models/task_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/task.dart';
import '../../../search/domain/usecases/search_content.dart';

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

  /// Search tasks with advanced filters
  Future<List<TaskModel>> searchTasksWithFilters(TaskSearchParams params);

  /// Get tasks modified since a specific timestamp
  Future<List<TaskModel>> getTasksModifiedSince(DateTime since);

  /// Update last sync timestamp
  Future<void> updateLastSyncTimestamp(DateTime timestamp);

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTimestamp();
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final Database database;

  const TaskLocalDataSourceImpl(this.database);

  @override
  Future<List<TaskModel>> getAllTasks() async {
    final List<Map<String, dynamic>> rows = await database.query(
      AppConstants.tasksTable,
      orderBy:
          '${AppConstants.dueDateColumn} ASC NULLS LAST, ${AppConstants.createdAtColumn} DESC',
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

  @override
  Future<List<TaskModel>> searchTasksWithFilters(
    TaskSearchParams params,
  ) async {
    final List<String> whereConditions = [];
    final List<Object> whereArgs = [];

    // Text search in title and description
    if (params.query.isNotEmpty) {
      whereConditions.add(
        '(${AppConstants.titleColumn} LIKE ? OR ${AppConstants.descriptionColumn} LIKE ?)',
      );
      whereArgs.addAll(['%${params.query}%', '%${params.query}%']);
    }

    // Priority filter
    if (params.priorities != null && params.priorities!.isNotEmpty) {
      final priorityNames = params.priorities!.map((p) => p.name).join(',');
      whereConditions.add('${AppConstants.priorityColumn} IN ($priorityNames)');
    }

    // Status filter
    if (params.statuses != null && params.statuses!.isNotEmpty) {
      final statusNames = params.statuses!.map((s) => s.name).join(',');
      whereConditions.add('${AppConstants.statusColumn} IN ($statusNames)');
    }

    // Due date range filter
    if (params.dueDateFrom != null) {
      whereConditions.add('${AppConstants.dueDateColumn} >= ?');
      whereArgs.add(params.dueDateFrom!.toIso8601String());
    }

    if (params.dueDateTo != null) {
      whereConditions.add('${AppConstants.dueDateColumn} <= ?');
      whereArgs.add(params.dueDateTo!.toIso8601String());
    }

    // Created date range filter
    if (params.createdFrom != null) {
      whereConditions.add('${AppConstants.createdAtColumn} >= ?');
      whereArgs.add(params.createdFrom!.toIso8601String());
    }

    if (params.createdTo != null) {
      whereConditions.add('${AppConstants.createdAtColumn} <= ?');
      whereArgs.add(params.createdTo!.toIso8601String());
    }

    // Tags filter
    if (params.tags != null && params.tags!.isNotEmpty) {
      for (final tag in params.tags!) {
        whereConditions.add('${AppConstants.tagsColumn} LIKE ?');
        whereArgs.add('%$tag%');
      }
    }

    // Labels filter
    if (params.labels != null && params.labels!.isNotEmpty) {
      for (final label in params.labels!) {
        whereConditions.add('${AppConstants.labelsColumn} LIKE ?');
        whereArgs.add('%$label%');
      }
    }

    // Overdue filter
    if (params.isOverdue == true) {
      whereConditions.add(
        '${AppConstants.dueDateColumn} < ? AND ${AppConstants.statusColumn} != ?',
      );
      whereArgs.addAll([
        DateTime.now().toIso8601String(),
        TaskStatus.completed.name,
      ]);
    }

    // Due today filter
    if (params.isDueToday == true) {
      final today = DateTime.now();
      final todayStart = DateTime(
        today.year,
        today.month,
        today.day,
      ).toIso8601String();
      final todayEnd = DateTime(
        today.year,
        today.month,
        today.day,
        23,
        59,
        59,
      ).toIso8601String();
      whereConditions.add(
        '${AppConstants.dueDateColumn} >= ? AND ${AppConstants.dueDateColumn} <= ?',
      );
      whereArgs.addAll([todayStart, todayEnd]);
    }

    final String whereClause = whereConditions.isNotEmpty
        ? whereConditions.join(' AND ')
        : '1=1';

    final List<Map<String, dynamic>> rows = await database.query(
      AppConstants.tasksTable,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: '${AppConstants.createdAtColumn} DESC',
    );

    return rows.map((row) => _fromRow(row)).toList();
  }

  @override
  Future<List<TaskModel>> getTasksModifiedSince(DateTime since) async {
    final List<Map<String, dynamic>> rows = await database.query(
      AppConstants.tasksTable,
      where: '${AppConstants.updatedAtColumn} > ?',
      whereArgs: [since.toIso8601String()],
    );
    return rows.map((row) => _fromRow(row)).toList();
  }

  @override
  Future<void> updateLastSyncTimestamp(DateTime timestamp) async {
    await database.insert(AppConstants.syncMetadataTable, {
      'last_sync': timestamp.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<DateTime?> getLastSyncTimestamp() async {
    final List<Map<String, dynamic>> rows = await database.query(
      AppConstants.syncMetadataTable,
      where: 'last_sync IS NOT NULL',
      limit: 1,
    );
    if (rows.isNotEmpty) {
      return DateTime.parse(rows.first['last_sync'] as String);
    }
    return null;
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
      lastModified: DateTime.parse(row[AppConstants.updatedAtColumn] as String),
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
      AppConstants.updatedAtColumn: task.lastModified.toIso8601String(),
    };
  }
}
