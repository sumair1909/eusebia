# Database Layer

This directory contains the simplified database layer implementation with only two files.

## Structure

- `database_config.dart` - Handles database version, path, and openDatabase() functionality
- `database_provider.dart` - Singleton provider exposed via Riverpod

## Architecture

### DatabaseConfig
- **Version Management** - Database version from AppConstants
- **Path Configuration** - Database file path management
- **Database Initialization** - openDatabase() with onCreate and onUpgrade callbacks
- **Schema Management** - Table creation and migration scripts

### DatabaseProvider
- **Riverpod Integration** - Provides database instance via Riverpod providers
- **Singleton Pattern** - Ensures single database instance across the app
- **Lifecycle Management** - Database open/close operations
- **Dependency Injection** - Registered in GetIt for dependency injection

## Usage

### Using Riverpod
```dart
// In a ConsumerWidget
final database = ref.watch(databaseInstanceProvider);

// Or in a provider
final database = ref.read(databaseProvider);
```

### Using Dependency Injection
```dart
// Get database instance
final database = await sl<Future<Database>>();
```

### Direct Usage
```dart
// Get database instance
final database = await DatabaseProvider.database;

// Close database
await DatabaseProvider.close();
```

## Database Schema

The database includes tables for:
- **Tasks** - Task management with title, description, completion status, and priority
- **Search History** - Search queries and timestamps

All schema definitions are centralized in `AppConstants`.
