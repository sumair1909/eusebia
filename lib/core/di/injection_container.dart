import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

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
  // TODO: Register task repositories, data sources, and use cases

}

/// Initialize search feature dependencies
Future<void> _initSearch() async {
  // TODO: Register search repositories and use cases
}

/// Initialize settings feature dependencies
Future<void> _initSettings() async {
  // TODO: Register settings repositories and use cases
}
