# Eusebia App - Clean Architecture Documentation

## Overview

Eusebia is a personal task manager app built with Flutter using **Feature-First Clean Architecture**. The app is designed to be scalable, maintainable, and testable.

## Architecture Principles

### 1. Feature-First Organization
Each feature is self-contained with its own:
- **Data Layer**: Repositories, data sources, models
- **Domain Layer**: Entities, use cases, repositories interfaces
- **Presentation Layer**: UI components, controllers, pages

### 2. Clean Architecture Layers

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

### 3. Dependency Rule
Dependencies point inward:
- Presentation depends on Domain
- Domain depends on nothing
- Data depends on Domain

## Project Structure

```
lib/
├── core/                           # Shared infrastructure
│   ├── constants/                  # App constants
│   ├── di/                        # Dependency injection
│   ├── error/                     # Error handling
│   ├── repositories/              # Base repository interfaces
│   ├── routing/                   # Navigation configuration
│   ├── usecases/                  # Base use case interfaces
│   └── widgets/                   # Shared UI components
├── features/                      # Feature modules
│   ├── tasks/                     # Task management
│   │   ├── data/                  # Data layer
│   │   ├── domain/                # Business logic
│   │   └── presentation/          # UI layer
│   ├── search/                    # Search functionality
│   └── settings/                  # App settings
└── main.dart                      # App entry point
```

## Key Technologies

### State Management
- **Riverpod**: For reactive state management
- **Provider Pattern**: For dependency injection

### Navigation
- **GoRouter**: For declarative routing

### Dependency Injection
- **GetIt**: For service locator pattern

### Error Handling
- **Dartz**: For functional error handling
- **Either**: For success/failure results

### HTTP Client
- **Dio**: For network requests

### Local Storage
- **SharedPreferences**: For simple key-value storage

## Implementation Guidelines

### 1. Use Cases
- Each use case should have a single responsibility
- Use cases should be testable and independent
- Follow the `UseCase<Type, Params>` interface

### 2. Repositories
- Implement the `BaseRepository<T>` interface
- Handle data transformation between layers
- Manage data sources (local/remote)

### 3. Error Handling
- Use `Either<Failure, Success>` for all operations
- Define specific failure types in `core/error/failures.dart`
- Handle errors gracefully in UI

### 4. State Management
- Use Riverpod providers for state
- Keep providers close to where they're used
- Separate business logic from UI logic

### 5. Navigation
- Define routes in `core/routing/app_router.dart`
- Use named routes for navigation
- Handle deep linking and web URLs

## Getting Started

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the App**
   ```bash
   flutter run
   ```

3. **Development Workflow**
   - Add new features in `features/` directory
   - Follow the clean architecture pattern
   - Write tests for use cases and repositories
   - Update documentation as needed

## Best Practices

1. **Code Quality**
   - Follow Dart/Flutter style guide
   - Use meaningful names for classes and methods
   - Write self-documenting code
   - Add comments for complex logic

2. **Testing**
   - Write unit tests for use cases
   - Write widget tests for UI components
   - Mock dependencies for isolated testing

3. **Performance**
   - Use lazy loading for large lists
   - Implement proper caching strategies
   - Optimize image loading and rendering

4. **Security**
   - Validate all user inputs
   - Secure API communications
   - Handle sensitive data properly

## Future Enhancements

- [ ] Add local database (Hive/Isar)
- [ ] Implement offline-first architecture
- [ ] Add push notifications
- [ ] Implement data synchronization
- [ ] Add analytics and crash reporting
- [ ] Implement dark mode support
- [ ] Add internationalization (i18n)
