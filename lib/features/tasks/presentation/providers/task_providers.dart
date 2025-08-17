import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/smart_priority_service.dart';
import '../../domain/repositories/task_repository.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_all_tasks.dart';
import '../../domain/usecases/get_task_by_id.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/usecases/sync_tasks.dart';

// Simple state classes
class TasksState {
  final List<Task> tasks;
  final bool isLoading;
  final String? error;
  final bool isRefreshing;
  final bool isSyncing;

  const TasksState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
    this.isRefreshing = false,
    this.isSyncing = false,
  });

  TasksState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    String? error,
    bool? isRefreshing,
    bool? isSyncing,
  }) => TasksState(
    tasks: tasks ?? this.tasks,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    isSyncing: isSyncing ?? this.isSyncing,
  );
}

class TaskDetailState {
  final Task? task;
  final bool isLoading;
  final String? error;

  const TaskDetailState({this.task, this.isLoading = false, this.error});

  TaskDetailState copyWith({Task? task, bool? isLoading, String? error}) =>
      TaskDetailState(
        task: task ?? this.task,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

// Main state notifier
class TasksNotifier extends StateNotifier<TasksState> {
  final TaskRepository _repository;
  final SmartPriorityService _smartPriorityService;

  TasksNotifier(this._repository, this._smartPriorityService)
    : super(const TasksState());

  Future<void> loadTasks() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await GetAllTasks(_repository)(NoParams());

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (tasks) async {
        // Sort tasks with smart priority
        final sortedTasks = await _smartPriorityService.sortTasksByPriority(
          tasks,
        );
        state = state.copyWith(tasks: sortedTasks, isLoading: false);
      },
    );
  }

  Future<void> refreshTasks() async {
    state = state.copyWith(isRefreshing: true, error: null);

    final result = await GetAllTasks(_repository)(NoParams());

    result.fold(
      (failure) =>
          state = state.copyWith(isRefreshing: false, error: failure.message),
      (tasks) async {
        // Sort tasks with smart priority
        final sortedTasks = await _smartPriorityService.sortTasksByPriority(
          tasks,
        );
        state = state.copyWith(tasks: sortedTasks, isRefreshing: false);
      },
    );
  }

  Future<void> createTask(Task task) async {
    final result = await CreateTask(_repository)(
      CreateTaskParams(
        title: task.title,
        description: task.description,
        priority: task.priority,
        dueDate: task.dueDate,
        tags: task.tags,
        labels: task.labels,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (newTask) => state = state.copyWith(tasks: [...state.tasks, newTask]),
    );
  }

  Future<void> updateTask(Task task) async {
    final result = await UpdateTask(_repository)(
      UpdateTaskParams(
        id: task.id,
        title: task.title,
        description: task.description,
        status: task.status,
        priority: task.priority,
        dueDate: task.dueDate,
        completedAt: task.completedAt,
        tags: task.tags,
        labels: task.labels,
      ),
    );

    result.fold((failure) => state = state.copyWith(error: failure.message), (
      updatedTask,
    ) {
      final updatedTasks = state.tasks
          .map((t) => t.id == updatedTask.id ? updatedTask : t)
          .toList();
      state = state.copyWith(tasks: updatedTasks);
    });
  }

  Future<void> deleteTask(String taskId) async {
    final result = await DeleteTask(_repository)(DeleteTaskParams(taskId));

    result.fold((failure) => state = state.copyWith(error: failure.message), (
      success,
    ) {
      if (success) {
        final updatedTasks = state.tasks.where((t) => t.id != taskId).toList();
        state = state.copyWith(tasks: updatedTasks);
      }
    });
  }

  Future<void> toggleTaskCompletion(Task task) async {
    final newStatus = task.status == TaskStatus.completed
        ? TaskStatus.pending
        : TaskStatus.completed;

    final completedAt = newStatus == TaskStatus.completed
        ? DateTime.now()
        : null;

    final updatedTask = task.copyWith(
      status: newStatus,
      completedAt: completedAt,
    );

    final result = await UpdateTask(_repository)(
      UpdateTaskParams(
        id: updatedTask.id,
        title: updatedTask.title,
        description: updatedTask.description,
        status: updatedTask.status,
        priority: updatedTask.priority,
        dueDate: updatedTask.dueDate,
        completedAt: updatedTask.completedAt,
        tags: updatedTask.tags,
        labels: updatedTask.labels,
      ),
    );

    result.fold((failure) => state = state.copyWith(error: failure.message), (
      updatedTask,
    ) async {
      // Update completion patterns if task was completed
      if (newStatus == TaskStatus.completed) {
        await _smartPriorityService.updateCompletionPatterns(updatedTask);
      }

      // Update the task in the list and sort with smart priority
      final updatedTasks = state.tasks
          .map((t) => t.id == updatedTask.id ? updatedTask : t)
          .toList();

      // Sort tasks with smart priority
      await _sortTasksWithSmartPriority(updatedTasks);

      state = state.copyWith(tasks: updatedTasks);
    });
  }

  /// Sort tasks considering smart priority
  Future<void> _sortTasksWithSmartPriority(List<Task> tasks) async {
    final pendingTasks = tasks
        .where((t) => t.status == TaskStatus.pending)
        .toList();
    final completedTasks = tasks
        .where((t) => t.status == TaskStatus.completed)
        .toList();

    // Sort pending tasks by smart priority
    final sortedPendingTasks = await _smartPriorityService.sortTasksByPriority(
      pendingTasks,
    );

    // Sort completed tasks by completion date (most recent first)
    completedTasks.sort((a, b) {
      if (a.completedAt != null && b.completedAt != null) {
        return b.completedAt!.compareTo(a.completedAt!);
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    // Combine sorted pending and completed tasks
    tasks.clear();
    tasks.addAll(sortedPendingTasks);
    tasks.addAll(completedTasks);
  }

  void clearError() => state = state.copyWith(error: null);

  Future<void> syncTasks() async {
    state = state.copyWith(isSyncing: true, error: null);

    final result = await SyncTasks(_repository)(NoParams());

    result.fold(
      (failure) =>
          state = state.copyWith(isSyncing: false, error: failure.message),
      (success) {
        if (success) {
          // Reload tasks after successful sync
          loadTasks();
        }
        state = state.copyWith(isSyncing: false);
      },
    );
  }
}

class TaskDetailNotifier extends StateNotifier<TaskDetailState> {
  final TaskRepository _repository;

  TaskDetailNotifier(this._repository) : super(const TaskDetailState());

  Future<void> loadTask(String taskId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await GetTaskById(_repository)(GetTaskByIdParams(taskId));

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (task) => state = state.copyWith(task: task, isLoading: false),
    );
  }

  Future<void> updateTask(Task task) async {
    final result = await UpdateTask(_repository)(
      UpdateTaskParams(
        id: task.id,
        title: task.title,
        description: task.description,
        status: task.status,
        priority: task.priority,
        dueDate: task.dueDate,
        completedAt: task.completedAt,
        tags: task.tags,
        labels: task.labels,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (updatedTask) => state = state.copyWith(task: updatedTask),
    );
  }

  void clearError() => state = state.copyWith(error: null);
}

// Repository provider
final taskRepositoryProvider = Provider<TaskRepository>(
  (_) => sl<TaskRepository>(),
);

// Main providers with proper dependency injection
final tasksNotifierProvider = StateNotifierProvider<TasksNotifier, TasksState>(
  (ref) =>
      TasksNotifier(ref.read(taskRepositoryProvider), SmartPriorityService()),
);

final taskDetailNotifierProvider =
    StateNotifierProvider.family<TaskDetailNotifier, TaskDetailState, String>(
      (ref, taskId) => TaskDetailNotifier(ref.read(taskRepositoryProvider)),
    );
