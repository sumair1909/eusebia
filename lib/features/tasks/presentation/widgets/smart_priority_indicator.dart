import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/smart_priority_service.dart';
import '../../domain/entities/task.dart';

/// Simple smart priority indicator widget
class SmartPriorityIndicator extends ConsumerStatefulWidget {
  final Task task;

  const SmartPriorityIndicator({super.key, required this.task});

  @override
  ConsumerState<SmartPriorityIndicator> createState() =>
      _SmartPriorityIndicatorState();
}

class _SmartPriorityIndicatorState
    extends ConsumerState<SmartPriorityIndicator> {
  double? _priorityScore;

  @override
  void initState() {
    super.initState();
    _calculatePriorityScore();
  }

  Future<void> _calculatePriorityScore() async {
    if (widget.task.status == TaskStatus.completed) return;

    try {
      final score = await SmartPriorityService().calculatePriorityScore(
        widget.task,
      );
      if (mounted) {
        setState(() {
          _priorityScore = score;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.task.status == TaskStatus.completed || _priorityScore == null) {
      return const SizedBox.shrink();
    }

    final score = _priorityScore!;
    final color = _getScoreColor(score);
    final icon = _getScoreIcon(score);

    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            '${score.toInt()}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.red;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.blue;
    return Colors.green;
  }

  IconData _getScoreIcon(double score) {
    if (score >= 80) return Icons.priority_high;
    if (score >= 60) return Icons.arrow_upward;
    if (score >= 40) return Icons.remove;
    return Icons.arrow_downward;
  }
}
