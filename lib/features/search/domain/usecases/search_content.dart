import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/search_result.dart';
import '../repositories/search_repository.dart';
import '../../../tasks/domain/entities/task.dart';

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

/// Parameters for searching tasks with advanced filters
class TaskSearchParams {
  final String query;
  final List<TaskPriority>? priorities;
  final List<TaskStatus>? statuses;
  final DateTime? dueDateFrom;
  final DateTime? dueDateTo;
  final DateTime? createdFrom;
  final DateTime? createdTo;
  final List<String>? tags;
  final List<String>? labels;
  final bool? isOverdue;
  final bool? isDueToday;

  const TaskSearchParams({
    required this.query,
    this.priorities,
    this.statuses,
    this.dueDateFrom,
    this.dueDateTo,
    this.createdFrom,
    this.createdTo,
    this.tags,
    this.labels,
    this.isOverdue,
    this.isDueToday,
  });

  /// Check if any filters are applied
  bool get hasFilters {
    return priorities != null ||
        statuses != null ||
        dueDateFrom != null ||
        dueDateTo != null ||
        createdFrom != null ||
        createdTo != null ||
        tags != null ||
        labels != null ||
        isOverdue != null ||
        isDueToday != null;
  }
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

/// Use case to search tasks with advanced filters
class SearchTasks implements UseCase<List<SearchResult>, TaskSearchParams> {
  final SearchRepository repository;

  const SearchTasks(this.repository);

  @override
  Future<Either<Failure, List<SearchResult>>> call(
    TaskSearchParams params,
  ) async {
    return await repository.searchTasks(params);
  }
}
