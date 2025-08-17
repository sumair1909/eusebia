import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:eusebia_app/features/search/domain/usecases/search_content.dart';
import 'package:eusebia_app/features/search/domain/entities/search_result.dart';
import 'package:eusebia_app/features/search/domain/repositories/search_repository.dart';
import 'package:eusebia_app/features/tasks/domain/entities/task.dart';
import 'package:eusebia_app/core/error/failures.dart';

// Simple mock for testing
class MockSearchRepository implements SearchRepository {
  @override
  Future<Either<Failure, List<SearchResult>>> search(String query) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<SearchResult>>> searchWithFilters(
    String query,
    List<String> types,
    DateTime? fromDate,
    DateTime? toDate,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<SearchResult>>> searchTasks(
    TaskSearchParams params,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<String>>> getSearchSuggestions(
    String query,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<String>>> getRecentSearches() async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> saveSearchQuery(String query) async {
    throw UnimplementedError();
  }
}

void main() {
  late MockSearchRepository mockRepository;

  setUp(() {
    mockRepository = MockSearchRepository();
  });

  const tQuery = 'test query';

  group('SearchContent', () {
    test('should create SearchContent use case', () {
      expect(() => SearchContent(mockRepository), returnsNormally);
    });

    test('should have correct type parameters', () {
      final useCase = SearchContent(mockRepository);
      expect(useCase, isA<SearchContent>());
    });
  });

  group('SearchContentParams', () {
    test('should create SearchContentParams with query', () {
      const params = SearchContentParams(query: 'test query');
      expect(params.query, 'test query');
    });

    test('should handle empty query', () {
      const params = SearchContentParams(query: '');
      expect(params.query, isEmpty);
    });

    test('should handle filters', () {
      final params = SearchContentParams(
        query: 'test',
        types: ['task'],
        fromDate: DateTime(2023, 1, 1),
        toDate: DateTime(2023, 12, 31),
      );
      expect(params.query, 'test');
      expect(params.types, ['task']);
      expect(params.fromDate, DateTime(2023, 1, 1));
      expect(params.toDate, DateTime(2023, 12, 31));
    });
  });

  group('TaskSearchParams', () {
    test('should create TaskSearchParams with query', () {
      const params = TaskSearchParams(query: 'test query');
      expect(params.query, 'test query');
    });

    test('should check if TaskSearchParams has filters', () {
      // Test with no filters
      final paramsNoFilters = TaskSearchParams(query: tQuery);
      expect(paramsNoFilters.hasFilters, false);

      // Test with priority filter
      final paramsWithPriority = TaskSearchParams(
        query: tQuery,
        priorities: [TaskPriority.high],
      );
      expect(paramsWithPriority.hasFilters, true);

      // Test with status filter
      final paramsWithStatus = TaskSearchParams(
        query: tQuery,
        statuses: [TaskStatus.pending],
      );
      expect(paramsWithStatus.hasFilters, true);

      // Test with date filters
      final paramsWithDate = TaskSearchParams(
        query: tQuery,
        dueDateFrom: DateTime(2023, 1, 1),
        dueDateTo: DateTime(2023, 12, 31),
      );
      expect(paramsWithDate.hasFilters, true);

      // Test with overdue filter
      final paramsWithOverdue = TaskSearchParams(
        query: tQuery,
        isOverdue: true,
      );
      expect(paramsWithOverdue.hasFilters, true);

      // Test with due today filter
      final paramsWithDueToday = TaskSearchParams(
        query: tQuery,
        isDueToday: true,
      );
      expect(paramsWithDueToday.hasFilters, true);

      // Test with tags filter
      final paramsWithTags = TaskSearchParams(
        query: tQuery,
        tags: ['important', 'urgent'],
      );
      expect(paramsWithTags.hasFilters, true);

      // Test with labels filter
      final paramsWithLabels = TaskSearchParams(
        query: tQuery,
        labels: ['work', 'personal'],
      );
      expect(paramsWithLabels.hasFilters, true);
    });
  });

  group('SearchTasks', () {

    setUp(() {
    });

    test('should create SearchTasks use case', () {
      expect(() => SearchTasks(mockRepository), returnsNormally);
    });

    test('should have correct type parameters', () {
      final useCase = SearchTasks(mockRepository);
      expect(useCase, isA<SearchTasks>());
    });
  });
}
