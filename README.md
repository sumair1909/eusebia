# Eusebia App

A modern, feature-rich task management application built with Flutter using Clean Architecture principles. Eusebia helps you organize, prioritize, and track your tasks with an intuitive interface and smart features.

## 🚀 Features

### Task Management
- **Create & Edit Tasks**: Add tasks with titles, descriptions, due dates, and priorities
- **Smart Priority System**: Automatic priority suggestions based on due dates and task patterns
- **Task Organization**: Categorize tasks with tags and labels
- **Status Tracking**: Track task progress (pending, in progress, completed)
- **Due Date Management**: Set and track due dates with overdue notifications
- **Task Filtering**: Filter tasks by status, priority, due date, and tags

### Search & Discovery
- **Global Search**: Search across all tasks with real-time suggestions
- **Recent Searches**: Quick access to your recent search queries
- **Advanced Filtering**: Combine multiple search criteria for precise results

### Settings & Customization
- **Theme Support**: Light, dark, and system theme modes
- **App Preferences**: Customize your task management experience
- **Data Management**: Export and backup your task data

### Technical Features
- **Offline-First**: Works seamlessly without internet connection
- **Cross-Platform**: Available on iOS, Android, Web, and Desktop
- **Responsive Design**: Optimized for all screen sizes
- **Performance Optimized**: Fast and smooth user experience

## 🏗️ Architecture

Eusebia follows **Feature-First Clean Architecture** principles for maintainability, testability, and scalability:

```
┌─────────────────────────────────────┐
│           Presentation              │
│  (UI, Controllers, State Mgmt)     │
├─────────────────────────────────────┤
│             Domain                  │
│  (Entities, Use Cases, Interfaces) │
├─────────────────────────────────────┤
│              Data                   │
│  (Repositories, Data Sources)       │
└─────────────────────────────────────┘
```

### Key Architectural Principles
- **Separation of Concerns**: Each layer has a specific responsibility
- **Dependency Inversion**: High-level modules don't depend on low-level modules
- **Testability**: Business logic is isolated and easily testable
- **Scalability**: New features can be added without affecting existing code

### Technology Stack
- **Framework**: Flutter 3.9+
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Dependency Injection**: GetIt
- **Local Storage**: SQLite + SharedPreferences
- **HTTP Client**: Dio
- **Error Handling**: Dartz (Either)
- **Testing**: Flutter Test + Mockito

## 📱 Screenshots

*Screenshots will be added here*

## 🛠️ Getting Started

### Prerequisites

- **Flutter SDK**: 3.9.0 or higher
- **Dart SDK**: 3.9.0 or higher
- **IDE**: VS Code, Android Studio, or IntelliJ IDEA
- **Git**: For version control

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/eusebia_app.git
   cd eusebia_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android
- Ensure Android SDK is installed
- Connect an Android device or start an emulator
- Run `flutter run` or use Android Studio

#### iOS
- Install Xcode (macOS only)
- Install iOS Simulator or connect an iOS device
- Run `flutter run` or use Xcode

#### Web
- Run `flutter run -d chrome` for web development
- The app will open in your default browser

#### Desktop
- For macOS: `flutter run -d macos`
- For Windows: `flutter run -d windows`
- For Linux: `flutter run -d linux`

## 🧪 Testing

### Run All Tests
```bash
flutter test
```

### Run Specific Test Files
```bash
flutter test test/unit/features/tasks/domain/usecases/create_task_test.dart
```

### Run Integration Tests
```bash
flutter test test/integration/
```

### Generate Test Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 📁 Project Structure

```
lib/
├── core/                           # Shared infrastructure
│   ├── constants/                  # App constants and enums
│   ├── database/                   # Database configuration
│   ├── di/                        # Dependency injection
│   ├── error/                     # Error handling
│   ├── routing/                   # Navigation configuration
│   ├── services/                  # Core services
│   ├── usecases/                  # Base use case interfaces
│   └── widgets/                   # Shared UI components
├── features/                      # Feature modules
│   ├── tasks/                     # Task management
│   │   ├── data/                  # Data layer (repositories, models)
│   │   ├── domain/                # Business logic (entities, use cases)
│   │   └── presentation/          # UI layer (pages, providers)
│   ├── search/                    # Search functionality
│   └── settings/                  # App settings
└── main.dart                      # App entry point
```

## 🔧 Development

### Code Style
- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter_lints` for code quality
- Run `flutter analyze` to check for issues

### Adding New Features
1. Create a new feature directory in `lib/features/`
2. Follow the clean architecture pattern:
   - `data/`: Repositories, data sources, models
   - `domain/`: Entities, use cases, repository interfaces
   - `presentation/`: UI components, providers
3. Register dependencies in `lib/core/di/injection_container.dart`
4. Add tests for your use cases and repositories

### State Management
- Use Riverpod providers for state management
- Keep providers close to where they're used
- Separate business logic from UI logic

### Error Handling
- Use `Either<Failure, Success>` for all operations
- Define specific failure types in `core/error/failures.dart`
- Handle errors gracefully in the UI

## 🚀 Building for Production

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

### Desktop
```bash
flutter build macos --release
flutter build windows --release
flutter build linux --release
```



