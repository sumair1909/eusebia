import 'package:eusebia_app/core/constants/app_constants.dart';
import 'package:eusebia_app/core/constants/extensions.dart';
import 'package:eusebia_app/features/tasks/domain/entities/task.dart';
import 'package:eusebia_app/features/tasks/presentation/providers/task_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompletedTasksBottomSheet extends ConsumerWidget {
  const CompletedTasksBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(tasksNotifierProvider);
    final completedTasks = tasksState.tasks
        .where((task) => task.status == TaskStatus.completed)
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: context.theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(context, completedTasks.length),
          Expanded(child: _buildCompletedTasksList(completedTasks, ref)),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int completedCount) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.smallPadding),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[600]),
          const SizedBox(width: AppConstants.smallPadding),
          Text(
            'Completed Tasks ($completedCount)',
            style: context.theme.textTheme.titleMedium,
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTasksList(List<Task> completedTasks, WidgetRef ref) {
    if (completedTasks.isEmpty) {
      return const _EmptyCompletedTasksWidget();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
      ),
      itemCount: completedTasks.length,
      itemBuilder: (context, index) {
        final task = completedTasks[index];
        return _CompletedTaskCard(
          task: task,
          onToggle: () => ref
              .read(tasksNotifierProvider.notifier)
              .toggleTaskCompletion(task),
        );
      },
    );
  }
}

class _EmptyCompletedTasksWidget extends StatelessWidget {
  const _EmptyCompletedTasksWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No completed tasks',
            style: context.theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete some tasks to see them here',
            style: context.theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedTaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;

  const _CompletedTaskCard({required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.smallPadding),
        child: Row(
          children: [
            Checkbox(
              value: true,
              onChanged: (_) => onToggle(),
              activeColor: Colors.green[600],
            ),
            const SizedBox(width: AppConstants.smallPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: context.theme.textTheme.titleMedium?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (task.description != null && task.description!.isNotEmpty)
                    Text(
                      task.description!,
                      style: context.theme.textTheme.bodySmall?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (task.completedAt != null)
                    Text(
                      'Completed on ${_formatCompletionDate(task.completedAt!)}',
                      style: context.theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCompletionDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final completionDay = DateTime(date.year, date.month, date.day);

    if (completionDay.isAtSameMomentAs(today)) {
      return 'Today at ${_formatTime(date)}';
    } else if (completionDay.isAtSameMomentAs(
      today.subtract(const Duration(days: 1)),
    )) {
      return 'Yesterday at ${_formatTime(date)}';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} at ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
