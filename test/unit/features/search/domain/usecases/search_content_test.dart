import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eusebia_app/core/error/failures.dart';
import 'package:eusebia_app/features/search/domain/entities/search_result.dart';
import 'package:eusebia_app/features/search/domain/repositories/search_repository.dart';
import 'package:eusebia_app/features/search/domain/usecases/search_content.dart';

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
  group('SearchContent Use Case', () {
    test('should create SearchContent use case', () {
      final mockRepository = MockSearchRepository();
      expect(() => SearchContent(mockRepository), returnsNormally);
    });

    test('should have correct type parameters', () {
      final mockRepository = MockSearchRepository();
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

    test('should handle long query', () {
      const longQuery = 'This is a very long search query with many words';
      const params = SearchContentParams(query: longQuery);
      expect(params.query, longQuery);
    });
  });

  group('SearchResult', () {
    test('should create SearchResult with all fields', () {
      final searchResult = SearchResult(
        id: '1',
        title: 'Test Result',
        description: 'Test Description',
        type: 'task',
        createdAt: DateTime(2024, 1, 15),
        metadata: {'relevance': 0.9},
      );

      expect(searchResult.id, '1');
      expect(searchResult.title, 'Test Result');
      expect(searchResult.description, 'Test Description');
      expect(searchResult.type, 'task');
      expect(searchResult.createdAt, DateTime(2024, 1, 15));
      expect(searchResult.metadata, {'relevance': 0.9});
    });

    test('should create SearchResult with minimal fields', () {
      final searchResult = SearchResult(
        id: '2',
        title: 'Minimal Result',
        type: 'note',
        createdAt: DateTime(2024, 1, 16),
      );

      expect(searchResult.id, '2');
      expect(searchResult.title, 'Minimal Result');
      expect(searchResult.description, null);
      expect(searchResult.type, 'note');
      expect(searchResult.metadata, isEmpty);
    });

    test('should be equal when all properties are the same', () {
      final result1 = SearchResult(
        id: '1',
        title: 'Test Result',
        type: 'task',
        createdAt: DateTime(2024, 1, 15),
      );

      final result2 = SearchResult(
        id: '1',
        title: 'Test Result',
        type: 'task',
        createdAt: DateTime(2024, 1, 15),
      );

      expect(result1, equals(result2));
    });

    test('should not be equal when properties are different', () {
      final result1 = SearchResult(
        id: '1',
        title: 'Test Result',
        type: 'task',
        createdAt: DateTime(2024, 1, 15),
      );

      final result2 = SearchResult(
        id: '2',
        title: 'Test Result',
        type: 'task',
        createdAt: DateTime(2024, 1, 15),
      );

      expect(result1, isNot(equals(result2)));
    });
  });
}
