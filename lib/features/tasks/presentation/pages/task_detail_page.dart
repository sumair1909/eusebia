import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/extensions.dart';
import '../../domain/entities/task.dart';
import '../providers/task_providers.dart';

class TaskDetailPage extends ConsumerStatefulWidget {
  final Task task;

  const TaskDetailPage({super.key, required this.task});

  @override
  ConsumerState<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends ConsumerState<TaskDetailPage> {
  @override
  void initState() {
    super.initState();
    // Load task details when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(taskDetailNotifierProvider(widget.task.id).notifier)
          .loadTask(widget.task.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskDetailState = ref.watch(
      taskDetailNotifierProvider(widget.task.id),
    );

    // Show error message if there's an error
    if (taskDetailState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${taskDetailState.error}')),
        );
        ref
            .read(taskDetailNotifierProvider(widget.task.id).notifier)
            .clearError();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            onPressed: () => context.pushNamed(
              'editTask',
              extra: taskDetailState.task ?? widget.task,
            ),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.horizontalPadding,
        ),
        child: taskDetailState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildTaskDetails(taskDetailState.task ?? widget.task),
      ),
    );
  }

  Widget _buildTaskDetails(Task task) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Title
          Text(
            task.title,
            style: context.theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Status and Priority
          Row(
            children: [
              _buildStatusChip(task.status),
              const SizedBox(width: 12),
              _buildPriorityChip(task.priority),
            ],
          ),

          const SizedBox(height: 24),

          // Description
          if (task.description != null && task.description!.isNotEmpty) ...[
            Text(
              'Description',
              style: context.theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(task.description!, style: context.theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
          ],

          // Due Date
          if (task.dueDate != null) ...[
            Text(
              'Due Date',
              style: context.theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(task.dueDate!),
              style: context.theme.textTheme.bodyMedium?.copyWith(
                color: task.isOverdue ? Colors.red : null,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Tags
          if (task.tags.isNotEmpty) ...[
            Text(
              'Tags',
              style: context.theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: task.tags.map((tag) => Chip(label: Text(tag))).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Created Date
          Text(
            'Created',
            style: context.theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(task.createdAt),
            style: context.theme.textTheme.bodyMedium,
          ),

          if (task.completedAt != null) ...[
            const SizedBox(height: 24),
            Text(
              'Completed',
              style: context.theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(task.completedAt!),
              style: context.theme.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(TaskStatus status) {
    Color color;
    String text;

    switch (status) {
      case TaskStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        break;
      case TaskStatus.inProgress:
        color = Colors.blue;
        text = 'In Progress';
        break;
      case TaskStatus.completed:
        color = Colors.green;
        text = 'Completed';
        break;
      case TaskStatus.cancelled:
        color = Colors.red;
        text = 'Cancelled';
        break;
    }

    return Chip(
      label: Text(text, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    Color color;
    String text;

    switch (priority) {
      case TaskPriority.low:
        color = Colors.grey;
        text = 'Low';
        break;
      case TaskPriority.medium:
        color = Colors.blue;
        text = 'Medium';
        break;
      case TaskPriority.high:
        color = Colors.orange;
        text = 'High';
        break;
      case TaskPriority.urgent:
        color = Colors.red;
        text = 'Urgent';
        break;
    }

    return Chip(
      label: Text(text, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
