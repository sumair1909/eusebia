import 'package:dio/dio.dart';
import '../models/search_result_model.dart';

/// Remote data source for search functionality
abstract class SearchRemoteDataSource {
  /// Search across all content types
  Future<List<SearchResultModel>> search(String query);

  /// Search with filters
  Future<List<SearchResultModel>> searchWithFilters(
    String query,
    List<String> types,
    DateTime? fromDate,
    DateTime? toDate,
  );

  /// Get search suggestions from server
  Future<List<String>> getSearchSuggestions(String query);
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final Dio dio;
  static const String _basePath = '/search';

  const SearchRemoteDataSourceImpl(this.dio);

  @override
  Future<List<SearchResultModel>> search(String query) async {
    try {
      final response = await dio.get(_basePath, queryParameters: {'q': query});

      final List<dynamic> resultsJson = response.data['data'] ?? [];
      return resultsJson
          .map((resultJson) => SearchResultModel.fromJson(resultJson))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<SearchResultModel>> searchWithFilters(
    String query,
    List<String> types,
    DateTime? fromDate,
    DateTime? toDate,
  ) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        if (types.isNotEmpty) 'types': types.join(','),
        if (fromDate != null) 'from': fromDate.toIso8601String(),
        if (toDate != null) 'to': toDate.toIso8601String(),
      };

      final response = await dio.get(_basePath, queryParameters: queryParams);

      final List<dynamic> resultsJson = response.data['data'] ?? [];
      return resultsJson
          .map((resultJson) => SearchResultModel.fromJson(resultJson))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      final response = await dio.get(
        '$_basePath/suggestions',
        queryParameters: {'q': query},
      );

      final List<dynamic> suggestionsJson = response.data['data'] ?? [];
      return suggestionsJson.cast<String>();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Handle Dio exceptions and convert to appropriate errors
  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 400) {
          return Exception('Invalid search query');
        } else if (statusCode == 500) {
          return Exception('Server error');
        }
        return Exception('HTTP error: $statusCode');
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      default:
        return Exception('Network error: ${e.message}');
    }
  }
}
