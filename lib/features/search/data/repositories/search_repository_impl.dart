import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/usecases/search_content.dart';
import '../datasources/search_local_data_source.dart';
import '../datasources/search_remote_data_source.dart';
import '../../../tasks/data/datasources/task_local_data_source.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/domain/entities/task.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;
  final SearchLocalDataSource localDataSource;
  final TaskLocalDataSource taskLocalDataSource;

  const SearchRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.taskLocalDataSource,
  });

  @override
  Future<Either<Failure, List<SearchResult>>> search(String query) async {
    try {
      if (query.trim().isEmpty) {
        return const Right([]);
      }

      // Save search query to recent searches
      await localDataSource.saveSearchQuery(query);

      // Try remote search first
      try {
        final remoteResults = await remoteDataSource.search(query);
        return Right(remoteResults.map((model) => model.toEntity()).toList());
      } catch (e) {
        // If remote fails, fall back to local search
        final localTaskResults = await taskLocalDataSource.searchTasks(query);
        final searchResults = localTaskResults
            .map(
              (task) => SearchResult(
                id: task.id,
                title: task.title,
                description: task.description,
                type: 'task',
                createdAt: task.createdAt,
                metadata: {
                  'status': task.status.name,
                  'priority': task.priority.name,
                  'dueDate': task.dueDate?.toIso8601String(),
                  'tags': task.tags,
                },
              ),
            )
            .toList();
        return Right(searchResults);
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SearchResult>>> searchWithFilters(
    String query,
    List<String> types,
    DateTime? fromDate,
    DateTime? toDate,
  ) async {
    try {
      if (query.trim().isEmpty) {
        return const Right([]);
      }

      // Save search query to recent searches
      await localDataSource.saveSearchQuery(query);

      // Try remote search with filters
      try {
        final remoteResults = await remoteDataSource.searchWithFilters(
          query,
          types,
          fromDate,
          toDate,
        );
        return Right(remoteResults.map((model) => model.toEntity()).toList());
      } catch (e) {
        // If remote fails, return empty results for now
        return const Right([]);
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SearchResult>>> searchTasks(
    TaskSearchParams params,
  ) async {
    try {
      debugPrint(
        'SearchRepositoryImpl.searchTasks called with params: $params',
      );

      // Save search query to recent searches if not empty
      if (params.query.isNotEmpty) {
        await localDataSource.saveSearchQuery(params.query);
      }

      // Get all tasks first, then apply filters in memory
      final allTasks = await taskLocalDataSource.getAllTasks();
      debugPrint('Found ${allTasks.length} total tasks');

      // Apply filters
      List<TaskModel> filteredTasks = allTasks.where((task) {
        // Text search filter
        if (params.query.isNotEmpty) {
          final query = params.query.toLowerCase();
          final title = task.title.toLowerCase();
          final description = task.description?.toLowerCase() ?? '';
          if (!title.contains(query) && !description.contains(query)) {
            return false;
          }
        }

        // Priority filter
        if (params.priorities != null && params.priorities!.isNotEmpty) {
          if (!params.priorities!.contains(task.priority)) {
            return false;
          }
        }

        // Status filter
        if (params.statuses != null && params.statuses!.isNotEmpty) {
          if (!params.statuses!.contains(task.status)) {
            return false;
          }
        }

        // Due date range filter
        if (params.dueDateFrom != null) {
          if (task.dueDate == null ||
              task.dueDate!.isBefore(params.dueDateFrom!)) {
            return false;
          }
        }

        if (params.dueDateTo != null) {
          if (task.dueDate == null ||
              task.dueDate!.isAfter(params.dueDateTo!)) {
            return false;
          }
        }

        // Created date range filter
        if (params.createdFrom != null) {
          if (task.createdAt.isBefore(params.createdFrom!)) {
            return false;
          }
        }

        if (params.createdTo != null) {
          if (task.createdAt.isAfter(params.createdTo!)) {
            return false;
          }
        }

        // Tags filter
        if (params.tags != null && params.tags!.isNotEmpty) {
          if (!params.tags!.any((tag) => task.tags.contains(tag))) {
            return false;
          }
        }

        // Labels filter
        if (params.labels != null && params.labels!.isNotEmpty) {
          if (!params.labels!.any((label) => task.labels.contains(label))) {
            return false;
          }
        }

        // Overdue filter
        if (params.isOverdue == true) {
          if (task.dueDate == null ||
              task.status == TaskStatus.completed ||
              !DateTime.now().isAfter(task.dueDate!)) {
            return false;
          }
        }

        // Due today filter
        if (params.isDueToday == true) {
          if (task.dueDate == null) {
            return false;
          }
          final now = DateTime.now();
          final dueDate = task.dueDate!;
          if (now.year != dueDate.year ||
              now.month != dueDate.month ||
              now.day != dueDate.day) {
            return false;
          }
        }

        return true;
      }).toList();

      debugPrint('After filtering: ${filteredTasks.length} tasks');

      final searchResults = filteredTasks.map((task) {
        // Calculate overdue and due today status
        final isOverdue =
            task.dueDate != null &&
            task.status != TaskStatus.completed &&
            DateTime.now().isAfter(task.dueDate!);

        final isDueToday =
            task.dueDate != null &&
            DateTime.now().year == task.dueDate!.year &&
            DateTime.now().month == task.dueDate!.month &&
            DateTime.now().day == task.dueDate!.day;

        return SearchResult(
          id: task.id,
          title: task.title,
          description: task.description,
          type: 'task',
          createdAt: task.createdAt,
          metadata: {
            'status': task.status.name,
            'priority': task.priority.name,
            'dueDate': task.dueDate?.toIso8601String(),
            'tags': task.tags,
            'labels': task.labels,
            'isOverdue': isOverdue,
            'isDueToday': isDueToday,
          },
        );
      }).toList();

      debugPrint('Returning ${searchResults.length} search results');
      return Right(searchResults);
    } catch (e) {
      debugPrint('SearchTasks error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getSearchSuggestions(
    String query,
  ) async {
    try {
      if (query.trim().isEmpty) {
        return const Right([]);
      }

      // Try remote suggestions first
      try {
        final remoteSuggestions = await remoteDataSource.getSearchSuggestions(
          query,
        );
        return Right(remoteSuggestions);
      } catch (e) {
        // If remote fails, fall back to local suggestions
        final localSuggestions = await localDataSource.getSearchSuggestions(
          query,
        );
        return Right(localSuggestions);
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getRecentSearches() async {
    try {
      final recentSearches = await localDataSource.getRecentSearches();
      return Right(recentSearches);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveSearchQuery(String query) async {
    try {
      await localDataSource.saveSearchQuery(query);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
