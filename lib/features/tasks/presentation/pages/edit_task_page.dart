import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../providers/task_providers.dart';
import '../widgets/labels_bottom_sheet.dart';

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
  TimeOfDay? _dueTime;
  List<String> _selectedLabels = [];
  List<String> _allLabels = [];
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
    _selectedLabels = List.from(widget.task.labels);

    // Initialize date and time from existing task
    if (widget.task.dueDate != null) {
      _dueDate = DateTime(
        widget.task.dueDate!.year,
        widget.task.dueDate!.month,
        widget.task.dueDate!.day,
      );
      _dueTime = TimeOfDay(
        hour: widget.task.dueDate!.hour,
        minute: widget.task.dueDate!.minute,
      );
    }

    _loadAllLabels();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadAllLabels() async {
    try {
      final result = await sl<TaskRepository>().getAllLabels();
      result.fold(
        (failure) => null,
        (labels) => setState(() => _allLabels = labels),
      );
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> _updateTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Combine date and time if both are selected
      DateTime? finalDueDate;
      if (_dueDate != null) {
        if (_dueTime != null) {
          // Combine date and time
          finalDueDate = DateTime(
            _dueDate!.year,
            _dueDate!.month,
            _dueDate!.day,
            _dueTime!.hour,
            _dueTime!.minute,
          );
        } else {
          // Only date selected, set to end of day
          finalDueDate = DateTime(
            _dueDate!.year,
            _dueDate!.month,
            _dueDate!.day,
            23,
            59,
          );
        }
      }

      // Create updated task object
      final updatedTask = widget.task.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        priority: _priority,
        status: _status,
        dueDate: finalDueDate,
        labels: _selectedLabels,
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

  Future<void> _selectDueTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => _dueTime = picked);
    }
  }

  void _showLabelsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => LabelsBottomSheet(
        selectedLabels: _selectedLabels,
        allLabels: _allLabels,
        onLabelsChanged: (labels) {
          setState(() {
            _selectedLabels = labels;
            _allLabels =
                labels.where((label) => !_allLabels.contains(label)).toList() +
                _allLabels;
          });
        },
      ),
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context, widget.task),
          ),
        ],
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
            SizedBox(height: AppConstants.mediumPadding),
            _buildDueTimeSelector(),
            SizedBox(height: AppConstants.mediumPadding),
            _buildLabelsSelector(),
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

  Widget _buildDueTimeSelector() {
    return InkWell(
      onTap: _dueDate == null ? null : _selectDueTime,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Due Time (Optional)',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.access_time),
          hintText: _dueDate == null ? 'Select a date first' : null,
        ),
        child: Text(
          _dueDate == null
              ? 'Select a date first'
              : _dueTime == null
              ? 'No specific time'
              : '${_dueTime!.hour.toString().padLeft(2, '0')}:${_dueTime!.minute.toString().padLeft(2, '0')}',
        ),
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
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(tasksNotifierProvider.notifier).deleteTask(task.id);
              context.pop();
              context.pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelsSelector() {
    return InkWell(
      onTap: _showLabelsBottomSheet,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Labels',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.label),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedLabels.isEmpty)
              const Text('No labels selected')
            else
              Wrap(
                spacing: AppConstants.smallPadding,
                runSpacing: AppConstants.smallPadding,
                children: _selectedLabels
                    .map(
                      (label) => Chip(
                        label: Text(label),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() {
                            _selectedLabels.remove(label);
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
          ],
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

      case TaskStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.green);
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
