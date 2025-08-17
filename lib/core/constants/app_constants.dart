/// Application-wide constants
class AppConstants {
  static const String appName = 'Eusebia';
  static const String appVersion = '1.0.0';

  // Padding Constants
  static const double horizontalPadding = 20.0;
  static const double verticalPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double mediumPadding = 12.0;
  static const double largePadding = 24.0;

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

  // Database Constants
  static const String databaseName = 'eusebia.db';
  static const int databaseVersion = 1;

  // Database Table Names
  static const String tasksTable = 'tasks';
  static const String searchHistoryTable = 'search_history';

  // Database Column Names
  static const String idColumn = 'id';
  static const String createdAtColumn = 'created_at';
  static const String updatedAtColumn = 'updated_at';

  // Tasks Table Columns
  static const String titleColumn = 'title';
  static const String descriptionColumn = 'description';
  static const String statusColumn = 'status';
  static const String priorityColumn = 'priority';
  static const String dueDateColumn = 'due_date';
  static const String completedAtColumn = 'completed_at';
  static const String tagsColumn = 'tags';
  static const String labelsColumn = 'labels';

  // Search History Table Columns
  static const String queryColumn = 'query';
  static const String timestampColumn = 'timestamp';

  // Database Table Creation Scripts
  static const String createTasksTable =
      '''
    CREATE TABLE $tasksTable (
      $idColumn TEXT PRIMARY KEY,
      $titleColumn TEXT NOT NULL,
      $descriptionColumn TEXT,
      $statusColumn TEXT NOT NULL DEFAULT 'pending',
      $priorityColumn TEXT NOT NULL DEFAULT 'medium',
      $dueDateColumn TEXT,
      $completedAtColumn TEXT,
      $tagsColumn TEXT,
      $labelsColumn TEXT,
      $createdAtColumn TEXT NOT NULL,
      $updatedAtColumn TEXT NOT NULL
    )
  ''';

  static const String createSearchHistoryTable =
      '''
    CREATE TABLE $searchHistoryTable (
      $idColumn TEXT PRIMARY KEY,
      $queryColumn TEXT NOT NULL,
      $timestampColumn TEXT NOT NULL
    )
  ''';

  // Database Indexes
  static const String createTasksTitleIndex =
      '''
    CREATE INDEX idx_tasks_title ON $tasksTable($titleColumn)
  ''';

  static const String createTasksStatusIndex =
      '''
    CREATE INDEX idx_tasks_status ON $tasksTable($statusColumn)
  ''';

  static const String createSearchHistoryQueryIndex =
      '''
    CREATE INDEX idx_search_history_query ON $searchHistoryTable($queryColumn)
  ''';
}
