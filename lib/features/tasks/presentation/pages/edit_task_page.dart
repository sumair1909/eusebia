import 'package:flutter/material.dart';

class EditTaskPage extends StatelessWidget {
  final String taskId;

  const EditTaskPage({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Task $taskId')),
      body: Center(
        child: Text('Edit Task Page for Task $taskId - Coming Soon'),
      ),
    );
  }
}
