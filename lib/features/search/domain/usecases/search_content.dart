import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/search_result.dart';
import '../repositories/search_repository.dart';

/// Parameters for searching content
class SearchContentParams {
  final String query;
  final List<String>? types;
  final DateTime? fromDate;
  final DateTime? toDate;

  const SearchContentParams({
    required this.query,
    this.types,
    this.fromDate,
    this.toDate,
  });
}

/// Use case to search content across the application
class SearchContent
    implements UseCase<List<SearchResult>, SearchContentParams> {
  final SearchRepository repository;

  const SearchContent(this.repository);

  @override
  Future<Either<Failure, List<SearchResult>>> call(
    SearchContentParams params,
  ) async {
    if (params.types != null ||
        params.fromDate != null ||
        params.toDate != null) {
      return await repository.searchWithFilters(
        params.query,
        params.types ?? [],
        params.fromDate,
        params.toDate,
      );
    }

    return await repository.search(params.query);
  }
}
