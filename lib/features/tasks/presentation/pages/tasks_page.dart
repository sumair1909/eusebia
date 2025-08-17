import 'package:eusebia_app/core/constants/app_constants.dart';
import 'package:eusebia_app/core/constants/extensions.dart';
import 'package:eusebia_app/core/routing/routes.dart';
import 'package:eusebia_app/core/widgets/profile_widget.dart';
import 'package:eusebia_app/features/tasks/domain/entities/task.dart';
import 'package:eusebia_app/features/tasks/presentation/providers/task_providers.dart';
import 'package:eusebia_app/features/tasks/presentation/widgets/completed_tasks_bottom_sheet.dart';
import 'package:eusebia_app/features/tasks/presentation/widgets/smart_priority_indicator.dart';
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
      appBar: AppBar(
        title: Text('Eusebia', style: context.theme.textTheme.titleLarge),

        actions: [
          IconButton(
            onPressed: () => context.pushNamed(AppRoutes.search),
            icon: const Icon(Icons.search),
          ),
          const ProfileWidget(radius: 15),
          SizedBox(width: AppConstants.smallPadding),
        ],
      ),
      body: Column(children: [Expanded(child: const TasksListWidget())]),
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
    _loadTasks();
  }

  void _loadTasks() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tasksNotifierProvider.notifier).loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksNotifierProvider);

    // Handle error state
    if (tasksState.error != null) {
      _showErrorSnackBar(tasksState.error!);
      ref.read(tasksNotifierProvider.notifier).clearError();
    }

    return _buildContent(tasksState);
  }

  void _showErrorSnackBar(String error) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
        );
      }
    });
  }

  Widget _buildContent(TasksState tasksState) {
    if (tasksState.isLoading) {
      return const _LoadingWidget();
    }

    final pendingTasks = tasksState.tasks
        .where((task) => task.status == TaskStatus.pending)
        .toList();

    if (pendingTasks.isEmpty && !tasksState.isLoading) {
      return const _EmptyStateWidget();
    }

    return _TasksListView(tasks: pendingTasks);
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _EmptyStateWidget extends ConsumerWidget {
  const _EmptyStateWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(tasksNotifierProvider);
    final completedTasksCount = tasksState.tasks
        .where((task) => task.status == TaskStatus.completed)
        .length;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            completedTasksCount > 0 ? 'No pending tasks' : 'No tasks found',
            style: context.theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            completedTasksCount > 0
                ? 'All tasks are completed!'
                : 'Create your first task!',
            style: context.theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          if (completedTasksCount > 0) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showCompletedTasksBottomSheet(context),
              icon: Icon(Icons.check_circle, color: Colors.green[600]),
              label: Text('View Completed Tasks ($completedTasksCount)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[50],
                foregroundColor: Colors.green[700],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.green[200]!),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCompletedTasksBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CompletedTasksBottomSheet(),
    );
  }
}

class _TasksListView extends ConsumerWidget {
  final List<Task> tasks;

  const _TasksListView({required this.tasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(tasksNotifierProvider);
    final completedTasksCount = tasksState.tasks
        .where((task) => task.status == TaskStatus.completed)
        .length;

    return RefreshIndicator(
      onRefresh: () => ref.read(tasksNotifierProvider.notifier).refreshTasks(),
      child: ListView.builder(
        itemCount: tasks.length + (completedTasksCount > 0 ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == tasks.length) {
            return _CompletedTasksButton(completedCount: completedTasksCount);
          }
          final task = tasks[index];
          return TaskCard(
            task: task,
            onTap: () => context.pushNamed(AppRoutes.editTask, extra: task),
          );
        },
      ),
    );
  }
}

class TaskCard extends ConsumerWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskCard({super.key, required this.task, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = task.status == TaskStatus.completed;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.smallPadding,
          vertical: AppConstants.smallPadding,
        ),
        child: Row(
          children: [
            _TaskCheckbox(
              isCompleted: isCompleted,
              onChanged: (value) {
                ref
                    .read(tasksNotifierProvider.notifier)
                    .toggleTaskCompletion(task);
              },
            ),
            SizedBox(width: AppConstants.smallPadding),
            Expanded(
              child: _TaskContent(task: task, isCompleted: isCompleted),
            ),
            // Add smart priority indicator
            if (!isCompleted) SmartPriorityIndicator(task: task),
          ],
        ),
      ),
    );
  }
}

class _TaskCheckbox extends StatelessWidget {
  final bool isCompleted;
  final ValueChanged<bool?>? onChanged;

  const _TaskCheckbox({required this.isCompleted, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Checkbox(value: isCompleted, onChanged: onChanged);
  }
}

class _TaskContent extends StatelessWidget {
  final Task task;
  final bool isCompleted;

  const _TaskContent({required this.task, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TaskTitle(title: task.title, isCompleted: isCompleted),
        if (task.description != null && task.description!.isNotEmpty)
          _TaskDescription(
            description: task.description!,
            isCompleted: isCompleted,
          ),
        if (task.dueDate != null)
          _TaskDueDate(task: task, isCompleted: isCompleted),
      ],
    );
  }
}

class _TaskTitle extends StatelessWidget {
  final String title;
  final bool isCompleted;

  const _TaskTitle({required this.title, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.theme.textTheme.titleMedium?.copyWith(
        decoration: isCompleted ? TextDecoration.lineThrough : null,
        color: isCompleted ? Colors.grey[600] : null,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _TaskDescription extends StatelessWidget {
  final String description;
  final bool isCompleted;

  const _TaskDescription({
    required this.description,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      style: context.theme.textTheme.bodySmall?.copyWith(
        decoration: isCompleted ? TextDecoration.lineThrough : null,
        color: isCompleted ? Colors.grey[600] : null,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _TaskDueDate extends StatelessWidget {
  final Task task;
  final bool isCompleted;

  const _TaskDueDate({required this.task, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final dueDate = task.dueDate!;
    final dateText = _formatDate(dueDate);
    final timeText = _formatTime(dueDate);

    return Row(
      children: [
        Text(
          dateText,
          style: context.theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        const SizedBox(width: AppConstants.smallPadding),
        Text(
          timeText,
          style: context.theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _CompletedTasksButton extends StatelessWidget {
  final int completedCount;

  const _CompletedTasksButton({required this.completedCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      child: ElevatedButton.icon(
        onPressed: () => _showCompletedTasksBottomSheet(context),
        icon: Icon(Icons.check_circle, color: Colors.green[600]),
        label: Text('Completed Tasks ($completedCount)'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[50],
          foregroundColor: Colors.green[700],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.green[200]!),
          ),
        ),
      ),
    );
  }

  void _showCompletedTasksBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CompletedTasksBottomSheet(),
    );
  }
}
