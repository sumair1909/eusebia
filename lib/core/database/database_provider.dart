import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'database_config.dart';

/// Database provider using Riverpod
final databaseProvider = Provider<Future<Database>>((ref) async {
  return await DatabaseConfig.openDatabaseInstance();
});

/// Singleton database instance provider
final databaseInstanceProvider = FutureProvider<Database>((ref) async {
  return await ref.read(databaseProvider);
});

/// Database operations provider
class DatabaseProvider {
  static Database? _database;

  /// Get database instance (singleton)
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await DatabaseConfig.openDatabaseInstance();
    return _database!;
  }

  /// Close database
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Check if database is open
  static bool get isOpen => _database != null;
}
