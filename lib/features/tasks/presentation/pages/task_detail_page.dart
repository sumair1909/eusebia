import 'package:flutter/material.dart';

class TaskDetailPage extends StatelessWidget {
  final String taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task $taskId')),
      body: Center(
        child: Text('Task Detail Page for Task $taskId - Coming Soon'),
      ),
    );
  }
}
