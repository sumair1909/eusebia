import 'package:eusebia_app/core/constants/extensions.dart';
import 'package:eusebia_app/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/tasks/domain/entities/task.dart';
import '../../features/tasks/presentation/pages/tasks_page.dart';
import '../../features/tasks/presentation/pages/task_detail_page.dart';
import '../../features/tasks/presentation/pages/add_task_page.dart';
import '../../features/tasks/presentation/pages/edit_task_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

/// Application router configuration
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        redirect: (context, state) => AppRoutes.tasks.path,
      ),
      GoRoute(
        path: AppRoutes.tasks.path,
        name: AppRoutes.tasks,
        builder: (context, state) => const TasksPage(),
      ),
      GoRoute(
        path: AppRoutes.search.path,
        name: AppRoutes.search,
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: AppRoutes.settings.path,
        name: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.taskDetail.path,
        name: AppRoutes.taskDetail,
        builder: (context, state) {
          final task = state.extra as Task;
          return TaskDetailPage(task: task);
        },
      ),
      GoRoute(
        path: AppRoutes.addTask.path,
        name: AppRoutes.addTask,
        builder: (context, state) => const AddTaskPage(),
      ),
      GoRoute(
        path: AppRoutes.editTask.path,
        name: AppRoutes.editTask,
        builder: (context, state) {
          final task = state.extra as Task;
          return EditTaskPage(task: task);
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
