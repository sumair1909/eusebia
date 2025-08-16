import 'package:eusebia_app/core/constants/app_constants.dart';
import 'package:eusebia_app/core/constants/extensions.dart';
import 'package:eusebia_app/core/routing/routes.dart';
import 'package:eusebia_app/core/widgets/profile_widget.dart';
import 'package:eusebia_app/features/tasks/domain/entities/task.dart';
import 'package:eusebia_app/features/tasks/presentation/providers/task_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(AppRoutes.addTask),
        shape: CircleBorder(),
        elevation: 0,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.horizontalPadding,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text('Eusebia', style: context.theme.textTheme.titleLarge),
                Spacer(),
                IconButton(
                  onPressed: () => context.pushNamed(AppRoutes.search),
                  icon: const Icon(Icons.search),
                ),
                SizedBox(width: AppConstants.smallPadding),
                const ProfileWidget(),
              ],
            ),
            SizedBox(height: 200, child: const TasksListWidget()),
          ],
        ),
      ),
    );
  }
}

class TasksListWidget extends ConsumerStatefulWidget {
  const TasksListWidget({super.key});

  @override
  ConsumerState<TasksListWidget> createState() => _TasksListWidgetState();
}

class _TasksListWidgetState extends ConsumerState<TasksListWidget> {
  @override
  void initState() {
    super.initState();
    // Load tasks when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tasksNotifierProvider.notifier).loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksNotifierProvider);

    // Show error message if there's an error
    if (tasksState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${tasksState.error}')));
        ref.read(tasksNotifierProvider.notifier).clearError();
      });
    }

    if (tasksState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tasksState.tasks.isEmpty) {
      return const Center(
        child: Text('No tasks found. Create your first task!'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(tasksNotifierProvider.notifier).refreshTasks(),
      child: ListView.builder(
        itemCount: tasksState.tasks.length,
        itemBuilder: (context, index) {
          final task = tasksState.tasks[index];
          return ListTile(
            title: Text(task.title),
            subtitle: Text(task.description ?? ''),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    context.pushNamed(AppRoutes.editTask, extra: task);
                    break;
                  case 'delete':
                    _showDeleteConfirmation(context, task);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
            onTap: () {
              context.pushNamed(AppRoutes.taskDetail, extra: task);
            },
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(tasksNotifierProvider.notifier).deleteTask(task.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
