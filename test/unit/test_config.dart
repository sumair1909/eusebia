import 'package:flutter_test/flutter_test.dart';
import 'package:eusebia_app/features/tasks/domain/entities/task.dart';
import 'package:eusebia_app/features/tasks/data/models/task_model.dart';
import 'package:eusebia_app/features/search/domain/entities/search_result.dart';

/// Common test utilities and mock generators
class TestConfig {
  /// Create a test task entity
  static Task createTestTask({
    String id = '1',
    String title = 'Test Task',
    String? description = 'Test Description',
    TaskStatus status = TaskStatus.pending,
    TaskPriority priority = TaskPriority.medium,
    DateTime? createdAt,
    DateTime? dueDate,
    List<String> tags = const ['work'],
  }) {
    return Task(
      id: id,
      title: title,
      description: description,
      status: status,
      priority: priority,
      createdAt: createdAt ?? DateTime(2024, 1, 15),
      dueDate: dueDate,
      tags: tags,
    );
  }

  /// Create a test task model
  static TaskModel createTestTaskModel({
    String id = '1',
    String title = 'Test Task',
    String? description = 'Test Description',
    TaskStatus status = TaskStatus.pending,
    TaskPriority priority = TaskPriority.medium,
    DateTime? createdAt,
    DateTime? dueDate,
    List<String> tags = const ['work'],
  }) {
    return TaskModel(
      id: id,
      title: title,
      description: description,
      status: status,
      priority: priority,
      createdAt: createdAt ?? DateTime(2024, 1, 15),
      dueDate: dueDate,
      tags: tags,
      lastModified: DateTime(2024, 1, 15),
    );
  }

  /// Create a test search result
  static SearchResult createTestSearchResult({
    String id = '1',
    String title = 'Test Search Result',
    String? description = 'Test Description',
    String type = 'task',
    DateTime? createdAt,
    Map<String, dynamic> metadata = const {},
  }) {
    return SearchResult(
      id: id,
      title: title,
      description: description,
      type: type,
      createdAt: createdAt ?? DateTime(2024, 1, 15),
      metadata: metadata,
    );
  }

  /// Create a list of test tasks
  static List<Task> createTestTasks({int count = 3}) {
    return List.generate(
      count,
      (index) => createTestTask(
        id: (index + 1).toString(),
        title: 'Test Task ${index + 1}',
        description: 'Test Description ${index + 1}',
      ),
    );
  }

  /// Create a list of test task models
  static List<TaskModel> createTestTaskModels({int count = 3}) {
    return List.generate(
      count,
      (index) => createTestTaskModel(
        id: (index + 1).toString(),
        title: 'Test Task ${index + 1}',
        description: 'Test Description ${index + 1}',
      ),
    );
  }

  /// Create a list of test search results
  static List<SearchResult> createTestSearchResults({int count = 3}) {
    return List.generate(
      count,
      (index) => createTestSearchResult(
        id: (index + 1).toString(),
        title: 'Test Search Result ${index + 1}',
        description: 'Test Description ${index + 1}',
      ),
    );
  }
}

/// Common test matchers
class TestMatchers {
  /// Matcher for checking if a task has specific properties
  static Matcher isTaskWith({
    String? id,
    String? title,
    TaskStatus? status,
    TaskPriority? priority,
  }) {
    return predicate<Task>(
      (task) {
        if (id != null && task.id != id) return false;
        if (title != null && task.title != title) return false;
        if (status != null && task.status != status) return false;
        if (priority != null && task.priority != priority) return false;
        return true;
      },
      'is task with id: $id, title: $title, status: $status, priority: $priority',
    );
  }

  /// Matcher for checking if a search result has specific properties
  static Matcher isSearchResultWith({String? id, String? title, String? type}) {
    return predicate<SearchResult>((result) {
      if (id != null && result.id != id) return false;
      if (title != null && result.title != title) return false;
      if (type != null && result.type != type) return false;
      return true;
    }, 'is search result with id: $id, title: $title, type: $type');
  }
}
