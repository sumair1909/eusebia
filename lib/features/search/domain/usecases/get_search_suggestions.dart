import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/search_repository.dart';

/// Parameters for getting search suggestions
class GetSearchSuggestionsParams {
  final String query;

  const GetSearchSuggestionsParams(this.query);
}

/// Use case to get search suggestions
class GetSearchSuggestions
    implements UseCase<List<String>, GetSearchSuggestionsParams> {
  final SearchRepository repository;

  const GetSearchSuggestions(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(
    GetSearchSuggestionsParams params,
  ) async {
    return await repository.getSearchSuggestions(params.query);
  }
}
