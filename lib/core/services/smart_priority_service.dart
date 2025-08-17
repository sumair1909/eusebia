import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../features/tasks/domain/entities/task.dart';

/// Smart Priority Service - Comprehensive yet simple priority scoring
/// Learns user patterns and adjusts task priorities automatically
class SmartPriorityService {
  static const String _labelLeadKey = 'smart_priority_label_lead';
  static const String _globalVelocityKey = 'smart_priority_global_velocity';
  static const String _completionCountKey = 'smart_priority_completion_count';

  /// Calculate priority score for a task (0-100)
  Future<double> calculatePriorityScore(Task task) async {
    if (task.status == TaskStatus.completed) return 0;

    final prefs = await SharedPreferences.getInstance();
    final labelLead = _getLabelLead(prefs);
    final globalVelocity = _getGlobalVelocity(prefs);

    final dueHours = task.dueDate == null
        ? 9999.0
        : task.dueDate!.difference(DateTime.now()).inHours.toDouble();

    final label = task.labels.firstOrNull ?? '__global';
    final typicalGap = labelLead[label] ?? labelLead['__global'] ?? -24.0;
    final slack = dueHours - typicalGap;

    // Fixed: proximity should be 0-1, not 0-100
    final proximity = _sigmoid(-slack / 24);
    final velocityF = 1.2 - 0.8 * _tanh(globalVelocity / 4);
    final userP = (task.priority.index + 1) * 25;

    return (userP * proximity * velocityF).clamp(0, 100);
  }

  /// Update learned data when task is completed
  Future<void> updateCompletionPatterns(Task task) async {
    if (task.status != TaskStatus.completed ||
        task.dueDate == null ||
        task.completedAt == null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final label = task.labels.firstOrNull ?? '__global';
    final lead = task.dueDate!.difference(task.completedAt!).inHours.toDouble();

    // Update label lead time
    final labelLead = _getLabelLead(prefs);
    final count = _getCompletionCount(prefs, label);
    labelLead[label] =
        ((labelLead[label] ?? -24.0) * count + lead) / (count + 1);
    await prefs.setString(_labelLeadKey, jsonEncode(labelLead));

    // Update global velocity (14-day rolling average)
    final globalVelocity = _getGlobalVelocity(prefs);
    final newVelocity =
        (globalVelocity * 13 + 1) / 14; // Simple rolling average
    await prefs.setDouble(_globalVelocityKey, newVelocity);

    // Update completion count
    await _updateCompletionCount(prefs, label);
  }

  /// Sort tasks by priority score (highest first)
  Future<List<Task>> sortTasksByPriority(List<Task> tasks) async {
    final scoredTasks = await Future.wait(
      tasks.map(
        (task) async => _ScoredTask(task, await calculatePriorityScore(task)),
      ),
    );
    scoredTasks.sort((a, b) => b.score.compareTo(a.score));
    return scoredTasks.map((st) => st.task).toList();
  }

  // Helper methods
  Map<String, double> _getLabelLead(SharedPreferences prefs) {
    final json = prefs.getString(_labelLeadKey) ?? '{}';
    return Map<String, double>.from(jsonDecode(json));
  }

  double _getGlobalVelocity(SharedPreferences prefs) {
    return prefs.getDouble(_globalVelocityKey) ?? 0.1;
  }

  int _getCompletionCount(SharedPreferences prefs, String label) {
    final counts = Map<String, int>.from(
      jsonDecode(prefs.getString(_completionCountKey) ?? '{}'),
    );
    return counts[label] ?? 0;
  }

  Future<void> _updateCompletionCount(
    SharedPreferences prefs,
    String label,
  ) async {
    final counts = Map<String, int>.from(
      jsonDecode(prefs.getString(_completionCountKey) ?? '{}'),
    );
    counts[label] = (counts[label] ?? 0) + 1;
    await prefs.setString(_completionCountKey, jsonEncode(counts));
  }

  double _sigmoid(double x) => 1 / (1 + exp(-x));
  double _tanh(double x) => (exp(x) - exp(-x)) / (exp(x) + exp(-x));
}

/// Helper class for sorting tasks with scores
class _ScoredTask {
  final Task task;
  final double score;
  _ScoredTask(this.task, this.score);
}
