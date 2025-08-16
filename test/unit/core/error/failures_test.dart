import 'package:flutter_test/flutter_test.dart';
import 'package:eusebia_app/core/error/failures.dart';

void main() {
  group('Failure Classes', () {
    group('ServerFailure', () {
      test('should create ServerFailure with message', () {
        // Arrange
        const message = 'Server error occurred';

        // Act
        const failure = ServerFailure(message);

        // Assert
        expect(failure.message, message);
      });

      test('should be equal when messages are the same', () {
        // Arrange
        const failure1 = ServerFailure('Error message');
        const failure2 = ServerFailure('Error message');

        // Assert
        expect(failure1, equals(failure2));
      });

      test('should not be equal when messages are different', () {
        // Arrange
        const failure1 = ServerFailure('Error message 1');
        const failure2 = ServerFailure('Error message 2');

        // Assert
        expect(failure1, isNot(equals(failure2)));
      });
    });

    group('CacheFailure', () {
      test('should create CacheFailure with message', () {
        // Arrange
        const message = 'Cache error occurred';

        // Act
        const failure = CacheFailure(message);

        // Assert
        expect(failure.message, message);
      });

      test('should be equal when messages are the same', () {
        // Arrange
        const failure1 = CacheFailure('Cache error');
        const failure2 = CacheFailure('Cache error');

        // Assert
        expect(failure1, equals(failure2));
      });
    });

    group('NetworkFailure', () {
      test('should create NetworkFailure with message', () {
        // Arrange
        const message = 'Network error occurred';

        // Act
        const failure = NetworkFailure(message);

        // Assert
        expect(failure.message, message);
      });

      test('should be equal when messages are the same', () {
        // Arrange
        const failure1 = NetworkFailure('Network error');
        const failure2 = NetworkFailure('Network error');

        // Assert
        expect(failure1, equals(failure2));
      });
    });

    group('ValidationFailure', () {
      test('should create ValidationFailure with message', () {
        // Arrange
        const message = 'Validation error occurred';

        // Act
        const failure = ValidationFailure(message);

        // Assert
        expect(failure.message, message);
      });

      test('should be equal when messages are the same', () {
        // Arrange
        const failure1 = ValidationFailure('Validation error');
        const failure2 = ValidationFailure('Validation error');

        // Assert
        expect(failure1, equals(failure2));
      });
    });

    group('Failure inheritance', () {
      test('all failure types should inherit from Failure', () {
        // Arrange & Act
        const serverFailure = ServerFailure('Server error');
        const cacheFailure = CacheFailure('Cache error');
        const networkFailure = NetworkFailure('Network error');
        const validationFailure = ValidationFailure('Validation error');

        // Assert
        expect(serverFailure, isA<Failure>());
        expect(cacheFailure, isA<Failure>());
        expect(networkFailure, isA<Failure>());
        expect(validationFailure, isA<Failure>());
      });

      test('should have correct props for equality', () {
        // Arrange
        const failure = ServerFailure('Test message');

        // Act
        final props = failure.props;

        // Assert
        expect(props, contains('Test message'));
        expect(props.length, 1);
      });
    });
  });
}
