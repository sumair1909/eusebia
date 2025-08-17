import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';

/// Database configuration class
class DatabaseConfig {
  /// Database version
  static const int version = AppConstants.databaseVersion;

  /// Database name
  static const String databaseName = AppConstants.databaseName;

  /// Get database path
  static Future<String> get databasePath async {
    return join(await getDatabasesPath(), databaseName);
  }

  /// Open database with configuration
  static Future<Database> openDatabaseInstance() async {
    final String path = await databasePath;

    return await openDatabase(
      path,
      version: version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  static Future<void> _onCreate(Database db, int version) async {
    // Create tables
    await db.execute(AppConstants.createTasksTable);
    await db.execute(AppConstants.createSearchHistoryTable);
    await db.execute(AppConstants.createSyncMetadataTable);

    // Create indexes
    await db.execute(AppConstants.createTasksTitleIndex);
    await db.execute(AppConstants.createTasksStatusIndex);
    await db.execute(AppConstants.createSearchHistoryQueryIndex);
  }

  /// Handle database upgrades
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      // Add labels column to tasks table
      await db.execute(
        'ALTER TABLE ${AppConstants.tasksTable} ADD COLUMN ${AppConstants.labelsColumn} TEXT',
      );
    }
    if (oldVersion < 3) {
      // Add sync_metadata table
      await db.execute(AppConstants.createSyncMetadataTable);
    }
  }
}
