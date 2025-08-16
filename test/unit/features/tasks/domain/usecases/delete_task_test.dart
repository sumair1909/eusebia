
import 'package:flutter_test/flutter_test.dart';
import 'package:eusebia_app/features/tasks/domain/usecases/delete_task.dart';

void main() {
  group('DeleteTask Use Case', () {
    test('should create DeleteTaskParams with task id', () {
      // Arrange
      const taskId = 'test-task-id';

      // Act
      const params = DeleteTaskParams(taskId);

      // Assert
      expect(params.id, taskId);
    });

    test('should create DeleteTaskParams with different task id', () {
      // Arrange
      const taskId = 'another-task-id';

      // Act
      const params = DeleteTaskParams(taskId);

      // Assert
      expect(params.id, taskId);
    });

    test('should handle empty task id', () {
      // Arrange
      const taskId = '';

      // Act
      const params = DeleteTaskParams(taskId);

      // Assert
      expect(params.id, isEmpty);
    });
  });
}
