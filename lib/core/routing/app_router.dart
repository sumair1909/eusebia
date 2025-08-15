import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/tasks/presentation/pages/tasks_page.dart';
import '../../features/tasks/presentation/pages/task_detail_page.dart';
import '../../features/tasks/presentation/pages/add_task_page.dart';
import '../../features/tasks/presentation/pages/edit_task_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

/// Application router configuration
class AppRouter {
  static const String home = '/';
  static const String tasks = '/tasks';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String taskDetail = '/task/:id';
  static const String addTask = '/add-task';
  static const String editTask = '/edit-task/:id';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(path: home, redirect: (context, state) => tasks),
      GoRoute(
        path: tasks,
        name: 'tasks',
        builder: (context, state) => const TasksPage(),
      ),
      GoRoute(
        path: search,
        name: 'search',
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: taskDetail,
        name: 'task-detail',
        builder: (context, state) {
          final taskId = state.pathParameters['id']!;
          return TaskDetailPage(taskId: taskId);
        },
      ),
      GoRoute(
        path: addTask,
        name: 'add-task',
        builder: (context, state) => const AddTaskPage(),
      ),
      GoRoute(
        path: editTask,
        name: 'edit-task',
        builder: (context, state) {
          final taskId = state.pathParameters['id']!;
          return EditTaskPage(taskId: taskId);
        },
      ),
    ],
    errorBuilder: (context, state) => const ErrorPage(),
  );
}

/// Error page for invalid routes
class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: const Center(
        child: Text('The page you are looking for does not exist.'),
      ),
    );
  }
}
