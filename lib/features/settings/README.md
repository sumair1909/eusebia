# Settings Feature

This feature implements a complete settings management system for the Eusebia app using Clean Architecture principles.

## Architecture

The settings feature follows the Clean Architecture pattern with three layers:

### Domain Layer
- **Entities**: `Settings` - Core business object representing user preferences
- **Repositories**: `SettingsRepository` - Abstract interface for data operations
- **Use Cases**: 
  - `GetSettings` - Retrieve current settings
  - `SaveSettings` - Save complete settings
  - `UpdateThemeMode` - Update theme mode specifically

### Data Layer
- **Models**: `SettingsModel` - Data transfer object extending the entity
- **Data Sources**: `SettingsLocalDataSource` - Local storage using SharedPreferences
- **Repository Implementation**: `SettingsRepositoryImpl` - Concrete implementation

### Presentation Layer
- **Providers**: `SettingsProvider` - Riverpod state management
- **Pages**: `SettingsPage` - UI for settings management
- **Theme Provider**: `ThemeProvider` - App-wide theme state management

## Features

### Theme Management
- **Light Mode**: Bright theme with light colors
- **Dark Mode**: Dark theme with appropriate contrast
- **System Mode**: Follows device system theme preference
- **Real-time Updates**: Theme changes apply immediately

### Settings Options
- **Theme Mode**: Light, Dark, or System
- **Notifications**: Enable/disable push notifications
- **Language**: Multiple language support (English, Spanish, French, German)
- **Auto Save**: Enable/disable automatic saving

### Data Persistence
- **SharedPreferences**: Local storage for settings
- **Backward Compatibility**: Supports both complete settings object and individual keys
- **Error Handling**: Graceful fallback to default settings

## Usage

### Accessing Settings
```dart
// In a ConsumerWidget
final settingsAsync = ref.watch(settingsProvider);

settingsAsync.when(
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error),
  data: (settings) => YourWidget(settings: settings),
);
```

### Updating Theme
```dart
// Update theme mode
ref.read(settingsProvider.notifier).updateTheme(ThemeMode.dark);

// Watch theme changes
final themeMode = ref.watch(themeProvider);
```

### Updating Other Settings
```dart
// Update notifications
ref.read(settingsProvider.notifier).updateNotifications(false);

// Update language
ref.read(settingsProvider.notifier).updateLanguage('es');

// Update auto-save
ref.read(settingsProvider.notifier).updateAutoSave(true);
```

## Dependencies

- **flutter_riverpod**: State management
- **shared_preferences**: Local storage
- **dartz**: Functional programming utilities
- **equatable**: Value equality

## Testing

The feature includes comprehensive unit tests:
- Entity tests for business logic
- Repository tests for data operations
- Use case tests for business rules

Run tests with:
```bash
flutter test test/unit/features/settings/
```

## Integration

The settings feature is integrated into the main app through:
1. **Dependency Injection**: Registered in `injection_container.dart`
2. **Routing**: Accessible via the app router
3. **Theme Integration**: Connected to MaterialApp theme system
4. **State Management**: Integrated with Riverpod providers

## Future Enhancements

- Remote settings synchronization
- Settings import/export
- Custom theme colors
- Advanced notification preferences
- Accessibility settings
