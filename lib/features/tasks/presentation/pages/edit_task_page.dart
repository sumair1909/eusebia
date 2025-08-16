import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/task.dart';
import '../providers/task_providers.dart';

class EditTaskPage extends ConsumerStatefulWidget {
  final Task task;

  const EditTaskPage({super.key, required this.task});

  @override
  ConsumerState<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends ConsumerState<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TaskPriority _priority;
  late TaskStatus _status;
  DateTime? _dueDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description ?? '',
    );
    _priority = widget.task.priority;
    _status = widget.task.status;
    _dueDate = widget.task.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create updated task object
      final updatedTask = widget.task.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        priority: _priority,
        status: _status,
        dueDate: _dueDate,
      );

      // Use Riverpod to update the task
      await ref.read(tasksNotifierProvider.notifier).updateTask(updatedTask);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppConstants.horizontalPadding),
          children: [
            _buildTitleField(),
            SizedBox(height: AppConstants.mediumPadding),
            _buildDescriptionField(),
            SizedBox(height: AppConstants.mediumPadding),
            _buildStatusSelector(),
            SizedBox(height: AppConstants.mediumPadding),
            _buildPrioritySelector(),
            SizedBox(height: AppConstants.mediumPadding),
            _buildDueDateSelector(),
            SizedBox(height: AppConstants.largePadding),
            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Title',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Title is required';
        }
        if (value.trim().length < AppConstants.minTaskTitleLength) {
          return 'Title must be at least ${AppConstants.minTaskTitleLength} characters';
        }
        if (value.trim().length > AppConstants.maxTaskTitleLength) {
          return 'Title must be less than ${AppConstants.maxTaskTitleLength} characters';
        }
        return null;
      },
      maxLength: AppConstants.maxTaskTitleLength,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description (Optional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 3,
      maxLength: AppConstants.maxTaskDescriptionLength,
    );
  }

  Widget _buildStatusSelector() {
    return DropdownButtonFormField<TaskStatus>(
      initialValue: _status,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.flag),
      ),
      items: TaskStatus.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Row(
            children: [
              _getStatusIcon(status),
              SizedBox(width: AppConstants.smallPadding),
              Text(status.name.toUpperCase()),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _status = value);
        }
      },
    );
  }

  Widget _buildPrioritySelector() {
    return DropdownButtonFormField<TaskPriority>(
      initialValue: _priority,
      decoration: const InputDecoration(
        labelText: 'Priority',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.priority_high),
      ),
      items: TaskPriority.values.map((priority) {
        return DropdownMenuItem(
          value: priority,
          child: Row(
            children: [
              _getPriorityIcon(priority),
              SizedBox(width: AppConstants.smallPadding),
              Text(priority.name.toUpperCase()),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _priority = value);
        }
      },
    );
  }

  Widget _buildDueDateSelector() {
    return InkWell(
      onTap: _selectDueDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Due Date (Optional)',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          _dueDate == null
              ? 'No due date'
              : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _updateTask,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: AppConstants.mediumPadding),
      ),
      child: _isLoading
          ? const CircularProgressIndicator()
          : const Text('Update Task'),
    );
  }

  Widget _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return const Icon(Icons.schedule, color: Colors.orange);
      case TaskStatus.inProgress:
        return const Icon(Icons.play_arrow, color: Colors.blue);
      case TaskStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.green);
      case TaskStatus.cancelled:
        return const Icon(Icons.cancel, color: Colors.red);
    }
  }

  Widget _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return const Icon(Icons.arrow_downward, color: Colors.green);
      case TaskPriority.medium:
        return const Icon(Icons.remove, color: Colors.orange);
      case TaskPriority.high:
        return const Icon(Icons.arrow_upward, color: Colors.red);
      case TaskPriority.urgent:
        return const Icon(Icons.priority_high, color: Colors.purple);
    }
  }
}
