import 'package:flutter_test/flutter_test.dart';
import 'package:eusebia_app/features/tasks/domain/entities/task.dart';

void main() {
  group('Task Entity', () {
    late Task testTask;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
      testTask = Task(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        status: TaskStatus.pending,
        priority: TaskPriority.medium,
        createdAt: testDate,
        dueDate: DateTime(2024, 1, 20),
        tags: ['work', 'important'],
      );
    });

    test('should create a task with all required properties', () {
      // Assert
      expect(testTask.id, '1');
      expect(testTask.title, 'Test Task');
      expect(testTask.description, 'Test Description');
      expect(testTask.status, TaskStatus.pending);
      expect(testTask.priority, TaskPriority.medium);
      expect(testTask.createdAt, testDate);
      expect(testTask.dueDate, DateTime(2024, 1, 20));
      expect(testTask.tags, ['work', 'important']);
    });

    test('should create a task with default values', () {
      // Arrange
      final defaultTask = Task(
        id: '2',
        title: 'Default Task',
        createdAt: testDate,
      );

      // Assert
      expect(defaultTask.status, TaskStatus.pending);
      expect(defaultTask.priority, TaskPriority.medium);
      expect(defaultTask.description, null);
      expect(defaultTask.dueDate, null);
      expect(defaultTask.completedAt, null);
      expect(defaultTask.tags, isEmpty);
    });

    test('should create a copy with updated fields', () {
      // Arrange
      final updatedDueDate = DateTime(2024, 1, 25);
      final updatedTask = testTask.copyWith(
        title: 'Updated Task',
        status: TaskStatus.completed,
        dueDate: updatedDueDate,
        completedAt: DateTime(2024, 1, 18),
      );

      // Assert
      expect(updatedTask.id, testTask.id);
      expect(updatedTask.title, 'Updated Task');
      expect(updatedTask.description, testTask.description);
      expect(updatedTask.status, TaskStatus.completed);
      expect(updatedTask.priority, testTask.priority);
      expect(updatedTask.createdAt, testTask.createdAt);
      expect(updatedTask.dueDate, updatedDueDate);
      expect(updatedTask.completedAt, DateTime(2024, 1, 18));
      expect(updatedTask.tags, testTask.tags);
    });

    test('should create a copy with only some fields updated', () {
      // Arrange
      final updatedTask = testTask.copyWith(title: 'Partial Update');

      // Assert
      expect(updatedTask.id, testTask.id);
      expect(updatedTask.title, 'Partial Update');
      expect(updatedTask.description, testTask.description);
      expect(updatedTask.status, testTask.status);
      expect(updatedTask.priority, testTask.priority);
      expect(updatedTask.createdAt, testTask.createdAt);
      expect(updatedTask.dueDate, testTask.dueDate);
      expect(updatedTask.completedAt, testTask.completedAt);
      expect(updatedTask.tags, testTask.tags);
    });

    group('isOverdue', () {
      test('should return false when task is completed', () {
        // Arrange
        final completedTask = testTask.copyWith(
          status: TaskStatus.completed,
          dueDate: DateTime(2024, 1, 10), // Past date
        );

        // Assert
        expect(completedTask.isOverdue, false);
      });

      test('should return false when due date is null', () {
        // Arrange
        final noDueDateTask = testTask.copyWith(dueDate: null);

        // Assert
        expect(noDueDateTask.isOverdue, false);
      });

      test('should return true when task is overdue', () {
        // Arrange
        final overdueTask = testTask.copyWith(
          dueDate: DateTime(2024, 1, 10), // Past date
        );

        // Assert
        expect(overdueTask.isOverdue, true);
      });

      test('should return false when task is not overdue', () {
        // Arrange
        final futureTask = testTask.copyWith(
          dueDate: DateTime(2025, 1, 20), // Future date
        );

        // Assert
        expect(futureTask.isOverdue, false);
      });
    });

    group('isDueToday', () {
      test('should return false when due date is null', () {
        // Arrange
        final noDueDateTask = testTask.copyWith(dueDate: null);

        // Assert
        expect(noDueDateTask.isDueToday, false);
      });

      test('should return true when task is due today', () {
        // Arrange
        final today = DateTime.now();
        final dueTodayTask = testTask.copyWith(
          dueDate: DateTime(today.year, today.month, today.day, 15, 30),
        );

        // Assert
        expect(dueTodayTask.isDueToday, true);
      });

      test('should return false when task is not due today', () {
        // Arrange
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final dueTomorrowTask = testTask.copyWith(
          dueDate: DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
        );

        // Assert
        expect(dueTomorrowTask.isDueToday, false);
      });
    });

    test('should be equal when all properties are the same', () {
      // Arrange
      final sameTask = Task(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        status: TaskStatus.pending,
        priority: TaskPriority.medium,
        createdAt: testDate,
        dueDate: DateTime(2024, 1, 20),
        tags: ['work', 'important'],
      );

      // Assert
      expect(testTask, equals(sameTask));
    });

    test('should not be equal when properties are different', () {
      // Arrange
      final differentTask = testTask.copyWith(id: '2');

      // Assert
      expect(testTask, isNot(equals(differentTask)));
    });
  });
}
