import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:eusebia_app/core/error/failures.dart';
import 'package:eusebia_app/core/usecases/usecase.dart';
import 'package:eusebia_app/features/tasks/domain/entities/task.dart';
import 'package:eusebia_app/features/tasks/domain/usecases/create_task.dart';
import 'package:eusebia_app/features/tasks/domain/usecases/get_all_tasks.dart';
import 'package:eusebia_app/features/tasks/domain/usecases/get_task_by_id.dart';
import 'package:eusebia_app/features/tasks/domain/usecases/delete_task.dart';
import 'package:eusebia_app/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:eusebia_app/features/tasks/data/datasources/task_remote_data_source.dart';
import 'package:eusebia_app/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:eusebia_app/features/tasks/data/models/task_model.dart';

/// Integration test for the complete task creation flow
///
/// This test verifies that the task creation process works end-to-end
/// through all layers of the clean architecture:
/// - Use Case layer (CreateTask)
/// - Repository layer (TaskRepositoryImpl)
/// - Data layer (TaskLocalDataSource)
/// - Database layer (SQLite)
///
/// The test ensures that:
/// 1. A task can be created successfully
/// 2. The created task can be retrieved by ID
/// 3. The task appears in the list of all tasks
/// 4. The task can be deleted successfully
/// 5. Error handling works correctly for invalid inputs
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Task Creation Integration Test', () {
    late Database database;
    late TaskLocalDataSource localDataSource;
    late TaskRepositoryImpl repository;
    late CreateTask createTask;
    late GetAllTasks getAllTasks;
    late GetTaskById getTaskById;
    late DeleteTask deleteTask;

    setUpAll(() async {
      // Initialize SQLite for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      // Create in-memory database for testing
      database = await openDatabase(
        ':memory:',
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE tasks (
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              description TEXT,
              status TEXT NOT NULL DEFAULT 'pending',
              priority TEXT NOT NULL DEFAULT 'medium',
              due_date TEXT,
              completed_at TEXT,
              tags TEXT,
              labels TEXT,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');
        },
      );
    });

    setUp(() async {
      // Initialize data sources and repositories
      localDataSource = TaskLocalDataSourceImpl(database);

      // Create a mock remote data source that always fails (not implemented yet)
      final mockRemoteDataSource = MockTaskRemoteDataSource();

      repository = TaskRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        localDataSource: localDataSource,
      );

      // Initialize use cases
      createTask = CreateTask(repository);
      getAllTasks = GetAllTasks(repository);
      getTaskById = GetTaskById(repository);
      deleteTask = DeleteTask(repository);

      // Clear the database before each test
      await database.delete('tasks');
    });

    tearDownAll(() async {
      await database.close();
    });

    group('Successful Task Creation Flow', () {
      test('should create a task and retrieve it by ID', () async {
        // Arrange
        final taskParams = CreateTaskParams(
          title: 'Complete integration test',
          description: 'Write comprehensive integration test for task creation',
          priority: TaskPriority.high,
          dueDate: DateTime.now().add(const Duration(days: 7)),
          tags: ['testing', 'integration'],
          labels: ['development', 'quality'],
        );

        // Act
        final createResult = await createTask(taskParams);
        final createdTask = createResult.fold(
          (failure) => throw Exception('Failed to create task: $failure'),
          (task) => task,
        );

        final retrieveResult = await getTaskById(
          GetTaskByIdParams(createdTask.id),
        );
        final retrievedTask = retrieveResult.fold(
          (failure) => throw Exception('Failed to retrieve task: $failure'),
          (task) => task,
        );

        // Assert
        expect(createResult.isRight(), isTrue);
        expect(retrievedTask.id, equals(createdTask.id));
        expect(retrievedTask.title, equals(taskParams.title));
        expect(retrievedTask.description, equals(taskParams.description));
        expect(retrievedTask.priority, equals(taskParams.priority));
        expect(retrievedTask.tags, equals(taskParams.tags));
        expect(retrievedTask.labels, equals(taskParams.labels));
        expect(retrievedTask.status, equals(TaskStatus.pending));
        expect(retrievedTask.createdAt, isNotNull);
        expect(retrievedTask.dueDate?.year, equals(taskParams.dueDate?.year));
        expect(retrievedTask.dueDate?.month, equals(taskParams.dueDate?.month));
        expect(retrievedTask.dueDate?.day, equals(taskParams.dueDate?.day));
      });

      test('should create multiple tasks and retrieve all tasks', () async {
        // Arrange
        final taskParams1 = CreateTaskParams(
          title: 'First task',
          priority: TaskPriority.low,
        );

        final taskParams2 = CreateTaskParams(
          title: 'Second task',
          priority: TaskPriority.urgent,
        );

        // Act
        final result1 = await createTask(taskParams1);
        final result2 = await createTask(taskParams2);

        final allTasksResult = await getAllTasks(const NoParams());
        final allTasks = allTasksResult.fold(
          (failure) => throw Exception('Failed to get all tasks: $failure'),
          (tasks) => tasks,
        );

        // Assert
        expect(result1.isRight(), isTrue);
        expect(result2.isRight(), isTrue);
        expect(allTasks.length, equals(2));
        expect(allTasks.any((task) => task.title == 'First task'), isTrue);
        expect(allTasks.any((task) => task.title == 'Second task'), isTrue);
        expect(
          allTasks.any((task) => task.priority == TaskPriority.low),
          isTrue,
        );
        expect(
          allTasks.any((task) => task.priority == TaskPriority.urgent),
          isTrue,
        );
      });

      test('should create task with minimal required fields', () async {
        // Arrange
        final taskParams = CreateTaskParams(title: 'Minimal task');

        // Act
        final createResult = await createTask(taskParams);
        final createdTask = createResult.fold(
          (failure) => throw Exception('Failed to create task: $failure'),
          (task) => task,
        );

        final retrieveResult = await getTaskById(
          GetTaskByIdParams(createdTask.id),
        );
        final retrievedTask = retrieveResult.fold(
          (failure) => throw Exception('Failed to retrieve task: $failure'),
          (task) => task,
        );

        // Assert
        expect(createResult.isRight(), isTrue);
        expect(retrievedTask.title, equals('Minimal task'));
        expect(retrievedTask.description, isNull);
        expect(retrievedTask.priority, equals(TaskPriority.medium)); // Default
        expect(retrievedTask.dueDate, isNull);
        expect(retrievedTask.tags, isEmpty);
        expect(retrievedTask.labels, isEmpty);
        expect(retrievedTask.status, equals(TaskStatus.pending));
      });
    });

    group('Task Deletion Flow', () {
      test('should create and delete a task successfully', () async {
        // Arrange
        final taskParams = CreateTaskParams(
          title: 'Task to delete',
          description: 'This task will be deleted',
        );

        // Act
        final createResult = await createTask(taskParams);
        final createdTask = createResult.fold(
          (failure) => throw Exception('Failed to create task: $failure'),
          (task) => task,
        );

        final deleteResult = await deleteTask(DeleteTaskParams(createdTask.id));
        final isDeleted = deleteResult.fold(
          (failure) => throw Exception('Failed to delete task: $failure'),
          (success) => success,
        );

        final allTasksResult = await getAllTasks(const NoParams());
        final allTasks = allTasksResult.fold(
          (failure) => throw Exception('Failed to get all tasks: $failure'),
          (tasks) => tasks,
        );

        // Assert
        expect(createResult.isRight(), isTrue);
        expect(isDeleted, isTrue);
        expect(allTasks, isEmpty);
      });
    });

    group('Error Handling', () {
      test('should handle retrieval of non-existent task', () async {
        // Arrange
        const nonExistentId = 'non-existent-id';

        // Act
        final result = await getTaskById(GetTaskByIdParams(nonExistentId));

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold((failure) {
          expect(failure, isA<CacheFailure>());
          expect(failure.message, contains('not found'));
        }, (task) => throw Exception('Expected failure but got success'));
      });
    });

    group('Data Persistence', () {
      test('should persist task data across multiple operations', () async {
        // Arrange
        final taskParams = CreateTaskParams(
          title: 'Persistent task',
          description: 'This task should persist',
          priority: TaskPriority.high,
          tags: ['persistent'],
        );

        // Act - Create task
        final createResult = await createTask(taskParams);
        final createdTask = createResult.fold(
          (failure) => throw Exception('Failed to create task: $failure'),
          (task) => task,
        );

        // Verify task exists
        final allTasksResult1 = await getAllTasks(const NoParams());
        final allTasks1 = allTasksResult1.fold(
          (failure) => throw Exception('Failed to get all tasks: $failure'),
          (tasks) => tasks,
        );
        expect(allTasks1.length, equals(1));

        // Create another task
        final taskParams2 = CreateTaskParams(
          title: 'Another persistent task',
          priority: TaskPriority.medium,
        );

        final createResult2 = await createTask(taskParams2);
        final createdTask2 = createResult2.fold(
          (failure) =>
              throw Exception('Failed to create second task: $failure'),
          (task) => task,
        );

        // Verify both tasks exist
        final allTasksResult2 = await getAllTasks(const NoParams());
        final allTasks2 = allTasksResult2.fold(
          (failure) => throw Exception('Failed to get all tasks: $failure'),
          (tasks) => tasks,
        );
        expect(allTasks2.length, equals(2));

        // Delete first task
        final deleteResult = await deleteTask(DeleteTaskParams(createdTask.id));
        final isDeleted = deleteResult.fold(
          (failure) => throw Exception('Failed to delete task: $failure'),
          (success) => success,
        );

        // Verify only second task remains
        final allTasksResult3 = await getAllTasks(const NoParams());
        final allTasks3 = allTasksResult3.fold(
          (failure) => throw Exception('Failed to get all tasks: $failure'),
          (tasks) => tasks,
        );

        // Assert
        expect(createResult.isRight(), isTrue);
        expect(createResult2.isRight(), isTrue);
        expect(isDeleted, isTrue);
        expect(allTasks3.length, equals(1));
        expect(allTasks3.first.id, equals(createdTask2.id));
        expect(allTasks3.first.title, equals('Another persistent task'));
      });
    });
  });
}

/// Mock remote data source for testing
class MockTaskRemoteDataSource implements TaskRemoteDataSource {
  @override
  Future<List<TaskModel>> getAllTasks() async {
    throw UnimplementedError('Remote data source not implemented for testing');
  }

  @override
  Future<TaskModel> getTaskById(String id) async {
    throw UnimplementedError('Remote data source not implemented for testing');
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    throw UnimplementedError('Remote data source not implemented for testing');
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    throw UnimplementedError('Remote data source not implemented for testing');
  }

  @override
  Future<void> deleteTask(String id) async {
    throw UnimplementedError('Remote data source not implemented for testing');
  }

  @override
  Future<List<TaskModel>> getTasksModifiedSince(DateTime since) async {
    throw UnimplementedError('Remote data source not implemented for testing');
  }

  @override
  Future<List<TaskModel>> batchUpdateTasks(List<TaskModel> tasks) async {
    throw UnimplementedError('Remote data source not implemented for testing');
  }
}
