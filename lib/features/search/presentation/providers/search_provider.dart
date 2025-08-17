import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/usecases/search_content.dart';
import '../../domain/repositories/search_repository.dart';
import '../../../tasks/domain/entities/task.dart';

/// Provider for search repository
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return sl<SearchRepository>();
});

/// Provider for search content use case
final searchContentProvider = Provider<SearchContent>((ref) {
  return sl<SearchContent>();
});

/// Provider for search tasks use case
final searchTasksProvider = Provider<SearchTasks>((ref) {
  return sl<SearchTasks>();
});

/// State class for search
class SearchState {
  final bool isLoading;
  final List<SearchResult> results;
  final String? error;
  final String query;
  final TaskSearchParams? searchParams;

  const SearchState({
    this.isLoading = false,
    this.results = const [],
    this.error,
    this.query = '',
    this.searchParams,
  });

  SearchState copyWith({
    bool? isLoading,
    List<SearchResult>? results,
    String? error,
    String? query,
    TaskSearchParams? searchParams,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      error: error,
      query: query ?? this.query,
      searchParams: searchParams ?? this.searchParams,
    );
  }
}

/// Search notifier for managing search state
class SearchNotifier extends StateNotifier<SearchState> {
  final SearchContent searchContent;
  final SearchTasks searchTasks;

  SearchNotifier({required this.searchContent, required this.searchTasks})
    : super(const SearchState());

  /// Search with basic query
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(results: [], query: query);
      return;
    }

    state = state.copyWith(isLoading: true, error: null, query: query);

    final result = await searchContent(SearchContentParams(query: query));

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: _mapFailureToMessage(failure),
        );
      },
      (results) {
        state = state.copyWith(isLoading: false, results: results);
      },
    );
  }

  /// Search tasks with advanced filters
  Future<void> searchTasksWithFilters(TaskSearchParams params) async {
    debugPrint('SearchTasksWithFilters called with params: $params');

    state = state.copyWith(
      isLoading: true,
      error: null,
      query: params.query,
      searchParams: params,
    );

    final result = await searchTasks(params);
    debugPrint('SearchTasks result: $result');

    result.fold(
      (failure) {
        debugPrint('Search failed: ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          error: _mapFailureToMessage(failure),
        );
      },
      (results) {
        debugPrint('Search successful, found ${results.length} results');
        state = state.copyWith(isLoading: false, results: results);
      },
    );
  }

  /// Search tasks with simple query
  Future<void> searchTasksByQuery(String query) async {
    final params = TaskSearchParams(query: query);
    await searchTasksWithFilters(params);
  }

  /// Search tasks with priority filter
  Future<void> searchTasksByPriority(
    String query,
    List<TaskPriority> priorities,
  ) async {
    final params = TaskSearchParams(query: query, priorities: priorities);
    await searchTasksWithFilters(params);
  }

  /// Search tasks with status filter
  Future<void> searchTasksByStatus(
    String query,
    List<TaskStatus> statuses,
  ) async {
    final params = TaskSearchParams(query: query, statuses: statuses);
    await searchTasksWithFilters(params);
  }

  /// Search overdue tasks
  Future<void> searchOverdueTasks(String query) async {
    final params = TaskSearchParams(query: query, isOverdue: true);
    await searchTasksWithFilters(params);
  }

  /// Search tasks due today
  Future<void> searchTasksDueToday(String query) async {
    final params = TaskSearchParams(query: query, isDueToday: true);
    await searchTasksWithFilters(params);
  }

  /// Search tasks by due date range
  Future<void> searchTasksByDueDateRange(
    String query,
    DateTime fromDate,
    DateTime toDate,
  ) async {
    final params = TaskSearchParams(
      query: query,
      dueDateFrom: fromDate,
      dueDateTo: toDate,
    );
    await searchTasksWithFilters(params);
  }

  /// Clear search results
  void clearSearch() {
    state = const SearchState();
  }

  /// Map failure to user-friendly message
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Server error occurred. Please try again.';
      case CacheFailure _:
        return 'Cache error occurred. Please try again.';
      case NetworkFailure _:
        return 'Network error occurred. Please check your internet connection.';
      case ValidationFailure _:
        return 'Validation error occurred. Please check your input.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}

/// Provider for search notifier
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((
  ref,
) {
  final searchContent = ref.watch(searchContentProvider);
  final searchTasks = ref.watch(searchTasksProvider);
  return SearchNotifier(searchContent: searchContent, searchTasks: searchTasks);
});
