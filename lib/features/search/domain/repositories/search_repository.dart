import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/search_result.dart';

/// Repository interface for search operations
abstract class SearchRepository {
  /// Search across all content types
  Future<Either<Failure, List<SearchResult>>> search(String query);

  /// Search with filters
  Future<Either<Failure, List<SearchResult>>> searchWithFilters(
    String query,
    List<String> types,
    DateTime? fromDate,
    DateTime? toDate,
  );

  /// Get search suggestions
  Future<Either<Failure, List<String>>> getSearchSuggestions(String query);

  /// Get recent searches
  Future<Either<Failure, List<String>>> getRecentSearches();

  /// Save search query to recent searches
  Future<Either<Failure, void>> saveSearchQuery(String query);
}
