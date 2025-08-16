import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../constants/app_constants.dart';
import '../database/database_provider.dart';
import '../../features/tasks/data/datasources/task_local_data_source.dart';
import '../../features/tasks/data/datasources/task_remote_data_source.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/domain/usecases/get_all_tasks.dart';
import '../../features/tasks/domain/usecases/get_task_by_id.dart';
import '../../features/tasks/domain/usecases/create_task.dart';
import '../../features/tasks/domain/usecases/update_task.dart';
import '../../features/tasks/domain/usecases/delete_task.dart';
import '../../features/search/data/datasources/search_local_data_source.dart';
import '../../features/search/data/datasources/search_remote_data_source.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/search/domain/usecases/search_content.dart';
import '../../features/search/domain/usecases/get_search_suggestions.dart';
import '../../features/search/domain/usecases/get_recent_searches.dart';

/// Global GetIt instance for dependency injection
final GetIt sl = GetIt.instance;

/// Initialize all dependencies
Future<void> init() async {
  // Core
  await _initCore();

  // Features
  await _initTasks();
  await _initSearch();
  await _initSettings();
}

/// Initialize core dependencies
Future<void> _initCore() async {
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Database - Register the actual Database instance
  final database = await DatabaseProvider.database;
  sl.registerLazySingleton<Database>(() => database);

  // Dio HTTP Client
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options.baseUrl = AppConstants.baseUrl;
    dio.options.connectTimeout = Duration(
      milliseconds: AppConstants.connectionTimeout,
    );
    dio.options.receiveTimeout = Duration(
      milliseconds: AppConstants.receiveTimeout,
    );

    // Add interceptors for logging, authentication, etc.
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    return dio;
  });
}

/// Initialize task feature dependencies
Future<void> _initTasks() async {
  // Data sources
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(sl<Database>()),
  );

  sl.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllTasks(sl()));
  sl.registerLazySingleton(() => GetTaskById(sl()));
  sl.registerLazySingleton(() => CreateTask(sl()));
  sl.registerLazySingleton(() => UpdateTask(sl()));
  sl.registerLazySingleton(() => DeleteTask(sl()));
}

/// Initialize search feature dependencies
Future<void> _initSearch() async {
  // Data sources
  sl.registerLazySingleton<SearchLocalDataSource>(
    () => SearchLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<SearchRemoteDataSource>(
    () => SearchRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      taskLocalDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SearchContent(sl()));
  sl.registerLazySingleton(() => GetSearchSuggestions(sl()));
  sl.registerLazySingleton(() => GetRecentSearches(sl()));
}

/// Initialize settings feature dependencies
Future<void> _initSettings() async {
  // TODO: Register settings repositories and use cases
}
