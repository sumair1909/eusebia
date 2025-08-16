import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/repositories/task_repository.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_all_tasks.dart';
import '../../domain/usecases/get_task_by_id.dart';
import '../../domain/usecases/update_task.dart';

// Simple state classes
class TasksState {
  final List<Task> tasks;
  final bool isLoading;
  final String? error;
  final bool isRefreshing;

  const TasksState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
    this.isRefreshing = false,
  });

  TasksState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    String? error,
    bool? isRefreshing,
  }) =>
      TasksState(
        tasks: tasks ?? this.tasks,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        isRefreshing: isRefreshing ?? this.isRefreshing,
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
  TasksNotifier() : super(const TasksState());

  Future<void> loadTasks() async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await GetAllTasks(sl<TaskRepository>())(NoParams());
    
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (tasks) => state = state.copyWith(tasks: tasks, isLoading: false),
    );
  }

  Future<void> refreshTasks() async {
    state = state.copyWith(isRefreshing: true, error: null);
    
    final result = await GetAllTasks(sl<TaskRepository>())(NoParams());
    
    result.fold(
      (failure) => state = state.copyWith(isRefreshing: false, error: failure.message),
      (tasks) => state = state.copyWith(tasks: tasks, isRefreshing: false),
    );
  }

  Future<void> createTask(Task task) async {
    final result = await CreateTask(sl<TaskRepository>())(CreateTaskParams(
      title: task.title,
      description: task.description,
      priority: task.priority,
      dueDate: task.dueDate,
      tags: task.tags,
    ));

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (newTask) => state = state.copyWith(tasks: [...state.tasks, newTask]),
    );
  }

  Future<void> updateTask(Task task) async {
    final result = await UpdateTask(sl<TaskRepository>())(UpdateTaskParams(
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      dueDate: task.dueDate,
      completedAt: task.completedAt,
      tags: task.tags,
    ));

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (updatedTask) {
        final updatedTasks = state.tasks.map((t) => t.id == updatedTask.id ? updatedTask : t).toList();
        state = state.copyWith(tasks: updatedTasks);
      },
    );
  }

  Future<void> deleteTask(String taskId) async {
    final result = await DeleteTask(sl<TaskRepository>())(DeleteTaskParams(taskId));

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (success) {
        if (success) {
          final updatedTasks = state.tasks.where((t) => t.id != taskId).toList();
          state = state.copyWith(tasks: updatedTasks);
        }
      },
    );
  }

  void clearError() => state = state.copyWith(error: null);
}

class TaskDetailNotifier extends StateNotifier<TaskDetailState> {
  TaskDetailNotifier() : super(const TaskDetailState());

  Future<void> loadTask(String taskId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await GetTaskById(sl<TaskRepository>())(GetTaskByIdParams(taskId));
    
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (task) => state = state.copyWith(task: task, isLoading: false),
    );
  }

  Future<void> updateTask(Task task) async {
    final result = await UpdateTask(sl<TaskRepository>())(UpdateTaskParams(
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      dueDate: task.dueDate,
      completedAt: task.completedAt,
      tags: task.tags,
    ));

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (updatedTask) => state = state.copyWith(task: updatedTask),
    );
  }

  void clearError() => state = state.copyWith(error: null);
}

// Main providers
final tasksNotifierProvider = StateNotifierProvider<TasksNotifier, TasksState>((ref) => TasksNotifier());

final taskDetailNotifierProvider = StateNotifierProvider.family<TaskDetailNotifier, TaskDetailState, String>((ref, taskId) => TaskDetailNotifier());
