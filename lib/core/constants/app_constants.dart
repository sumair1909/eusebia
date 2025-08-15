/// Application-wide constants
class AppConstants {
  static const String appName = 'Eusebia';
  static const String appVersion = '1.0.0';

  // API Constants
  static const String baseUrl = 'https://api.eusebia.com';
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Storage Keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String userTokenKey = 'user_token';

  // Validation Constants
  static const int minTaskTitleLength = 3;
  static const int maxTaskTitleLength = 100;
  static const int maxTaskDescriptionLength = 500;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
