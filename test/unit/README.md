# Unit Test Suite

This directory contains comprehensive unit tests for the Eusebia App, focusing on business logic and data layer testing.

## Test Structure

```
test/unit/
├── core/
│   └── error/
│       └── failures_test.dart          # Tests for failure classes
├── features/
│   ├── tasks/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── task_test.dart      # Tests for Task entity
│   │   │   └── usecases/
│   │   │       ├── get_all_tasks_test.dart
│   │   │       └── create_task_test.dart
│   │   └── data/
│   │       └── repositories/
│   │           └── task_repository_impl_test.dart
│   └── search/
│       └── domain/
│           └── usecases/
│               └── search_content_test.dart
├── test_config.dart                    # Common test utilities
├── run_tests.dart                      # Test runner
└── README.md                           # This file
```

## Test Categories

### 1. Entity Tests
- **Purpose**: Test domain entities and their business logic
- **Focus**: Validation, computed properties, equality, and immutability
- **Examples**: Task entity tests for `isOverdue`, `isDueToday`, `copyWith`

### 2. Use Case Tests
- **Purpose**: Test business logic in use cases
- **Focus**: Input validation, error handling, and repository interaction
- **Examples**: `GetAllTasks`, `CreateTask`, `SearchContent`

### 3. Repository Tests
- **Purpose**: Test data layer logic and caching strategies
- **Focus**: Local vs remote data source coordination, error handling
- **Examples**: `TaskRepositoryImpl` tests for offline-first behavior

### 4. Failure Tests
- **Purpose**: Test error handling and failure types
- **Focus**: Failure creation, equality, and inheritance
- **Examples**: `ServerFailure`, `CacheFailure`, `NetworkFailure`

## Test Utilities

### TestConfig
Provides factory methods for creating test data:
- `createTestTask()` - Creates Task entities with default or custom values
- `createTestTaskModel()` - Creates TaskModel instances
- `createTestSearchResult()` - Creates SearchResult instances
- `createTestTasks(count: n)` - Creates lists of test tasks

### TestMatchers
Custom matchers for more expressive assertions:
- `isTaskWith()` - Matches tasks with specific properties
- `isSearchResultWith()` - Matches search results with specific properties

## Running Tests

### Run All Unit Tests
```bash
flutter test test/unit/
```

### Run Specific Test Categories
```bash
# Run only entity tests
flutter test test/unit/features/tasks/domain/entities/

# Run only use case tests
flutter test test/unit/features/tasks/domain/usecases/

# Run only repository tests
flutter test test/unit/features/tasks/data/repositories/
```

### Run Tests with Coverage
```bash
flutter test --coverage test/unit/
```

### Generate Mock Files
```bash
flutter packages pub run build_runner build
```

## Test Best Practices

### 1. Test Organization
- Use descriptive test names that explain the scenario
- Group related tests using `group()`
- Follow AAA pattern: Arrange, Act, Assert

### 2. Mocking
- Use `@GenerateMocks()` annotation for automatic mock generation
- Mock only external dependencies (repositories, data sources)
- Verify mock interactions to ensure correct usage

### 3. Test Data
- Use `TestConfig` utilities for consistent test data
- Create realistic test scenarios
- Test edge cases and error conditions

### 4. Assertions
- Use specific assertions rather than generic ones
- Test both success and failure scenarios
- Verify error messages and failure types

## Example Test Structure

```dart
group('FeatureName', () {
  late MockDependency mockDependency;
  late UseCase useCase;

  setUp(() {
    mockDependency = MockDependency();
    useCase = UseCase(mockDependency);
  });

  test('should perform action successfully', () async {
    // Arrange
    when(mockDependency.method()).thenAnswer((_) async => expectedResult);

    // Act
    final result = await useCase(params);

    // Assert
    expect(result, Right(expectedResult));
    verify(mockDependency.method());
  });

  test('should handle error gracefully', () async {
    // Arrange
    when(mockDependency.method()).thenThrow(Exception('Error'));

    // Act
    final result = await useCase(params);

    // Assert
    expect(result, isA<Left<Failure>>());
  });
});
```

## Coverage Goals

- **Entity Tests**: 100% coverage for business logic methods
- **Use Case Tests**: 100% coverage for all code paths
- **Repository Tests**: 100% coverage for data coordination logic
- **Overall**: Aim for >90% code coverage

## Continuous Integration

Tests are automatically run on:
- Pull request creation
- Code push to main branch
- Release preparation

All tests must pass before code can be merged.
