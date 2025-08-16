# Tasks Feature - Riverpod State Management

This directory contains the Riverpod state management implementation for the tasks feature.

## Overview

The tasks feature uses Riverpod for state management instead of global dependency injection variables. This provides better testability, dependency management, and state synchronization across the UI.

## Files

### `task_providers.dart`
Contains all the Riverpod providers and state management logic for the tasks feature:

- **Repository Provider**: `taskRepositoryProvider` - Provides the task repository
- **Use Case Providers**: Providers for all task use cases (GetAllTasks, CreateTask, etc.)
- **State Classes**: 
  - `TasksState` - Manages the list of tasks and loading states
  - `TaskDetailState` - Manages individual task details
- **State Notifiers**:
  - `TasksNotifier` - Handles CRUD operations for task lists
  - `TaskDetailNotifier` - Handles individual task operations
- **Convenience Providers**: Simple providers for accessing specific state parts



## Usage

### In Widgets

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the tasks state
    final tasksState = ref.watch(tasksNotifierProvider);
    
    // Access specific parts of the state
    final tasks = ref.watch(tasksProvider);
    final isLoading = ref.watch(tasksLoadingProvider);
    final error = ref.watch(tasksErrorProvider);
    
    // Perform actions
    ref.read(tasksNotifierProvider.notifier).loadTasks();
    ref.read(tasksNotifierProvider.notifier).createTask(newTask);
    
    return // Your widget
  }
}
```

### State Management

The state management follows these patterns:

1. **Loading States**: Separate loading states for initial load and refresh
2. **Error Handling**: Centralized error handling with automatic clearing
3. **Optimistic Updates**: Immediate UI updates followed by server sync
4. **State Synchronization**: Automatic state updates across all widgets

### Benefits

1. **Testability**: Easy to mock providers for testing
2. **Dependency Management**: Clear dependency graph
3. **State Synchronization**: Automatic updates across the app
4. **Performance**: Efficient rebuilds with granular state watching
5. **Type Safety**: Compile-time safety for state access

## Integration with DI Container

The providers directly access the repository from the existing dependency injection container:

```dart
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return sl<TaskRepository>();
});
```

This provides a clean integration between the DI container and Riverpod state management without unnecessary complexity.
