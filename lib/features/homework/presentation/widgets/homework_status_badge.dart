import 'package:flutter/material.dart';
import '../../domain/entities/homework_entity.dart';

class HomeworkStatusBadge extends StatelessWidget {
  final HomeworkStatus status;
  final bool isOverdue;

  const HomeworkStatusBadge({super.key, required this.status, this.isOverdue = false});

  @override
  Widget build(BuildContext context) {
    if (isOverdue) {
      return _buildChip('Overdue', Colors.red);
    }
    switch (status) {
      case HomeworkStatus.draft:
        return _buildChip('Draft', Colors.grey);
      case HomeworkStatus.published:
        return _buildChip('Published', Colors.green);
    }
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class SubmissionStatusBadge extends StatelessWidget {
  final SubmissionStatus status;
  const SubmissionStatusBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case SubmissionStatus.pending:
        return Colors.grey;
      case SubmissionStatus.submitted:
        return Colors.blue;
      case SubmissionStatus.late:
        return Colors.orange;
      case SubmissionStatus.checked:
        return Colors.green;
      case SubmissionStatus.returned:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: _color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(status.label, style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}