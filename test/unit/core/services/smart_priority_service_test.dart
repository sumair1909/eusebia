import 'package:flutter_test/flutter_test.dart';
import 'package:eusebia_app/core/services/smart_priority_service.dart';
import 'package:eusebia_app/features/tasks/domain/entities/task.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SmartPriorityService', () {
    late SmartPriorityService service;

    setUp(() {
      service = SmartPriorityService();
    });

    test(
      'should calculate different priority scores for different tasks',
      () async {
        // Arrange
        final urgentTask = Task(
          id: '1',
          title: 'Urgent Task',
          status: TaskStatus.pending,
          priority: TaskPriority.urgent,
          createdAt: DateTime.now(),
          dueDate: DateTime.now().add(const Duration(hours: 1)),
        );

        final lowTask = Task(
          id: '2',
          title: 'Low Task',
          status: TaskStatus.pending,
          priority: TaskPriority.low,
          createdAt: DateTime.now(),
          dueDate: DateTime.now().add(const Duration(days: 7)),
        );

        // Act
        final urgentScore = await service.calculatePriorityScore(urgentTask);
        final lowScore = await service.calculatePriorityScore(lowTask);

        // Assert
        expect(urgentScore, greaterThan(lowScore));
        expect(urgentScore, greaterThan(0));
        expect(urgentScore, lessThanOrEqualTo(100));
        expect(lowScore, greaterThan(0));
        expect(lowScore, lessThanOrEqualTo(100));
      },
    );

    test('should return 0 for completed task', () async {
      // Arrange
      final task = Task(
        id: '1',
        title: 'Test Task',
        status: TaskStatus.completed,
        priority: TaskPriority.medium,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      // Act
      final score = await service.calculatePriorityScore(task);

      // Assert
      expect(score, equals(0));
    });

    test('should handle tasks without due dates', () async {
      // Arrange
      final task = Task(
        id: '1',
        title: 'No Due Date Task',
        status: TaskStatus.pending,
        priority: TaskPriority.medium,
        createdAt: DateTime.now(),
      );

      // Act
      final score = await service.calculatePriorityScore(task);

      // Assert
      expect(score, greaterThan(0));
      expect(score, lessThanOrEqualTo(100));
    });
  });
}
