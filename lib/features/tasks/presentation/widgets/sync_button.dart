import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_providers.dart';

/// A simple sync button widget
class SyncButton extends ConsumerWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(tasksNotifierProvider);

    return IconButton(
      onPressed: tasksState.isSyncing
          ? null
          : () {
              ref.read(tasksNotifierProvider.notifier).syncTasks();
            },
      icon: tasksState.isSyncing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.sync),
      tooltip: 'Sync with remote database',
    );
  }
}
