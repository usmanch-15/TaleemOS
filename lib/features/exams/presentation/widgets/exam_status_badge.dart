import 'package:flutter/material.dart';
import '../../domain/entities/exam_entity.dart';

class ExamStatusBadge extends StatelessWidget {
  final ExamStatus status;
  const ExamStatusBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case ExamStatus.draft:
        return Colors.grey;
      case ExamStatus.ongoing:
        return Colors.orange;
      case ExamStatus.completed:
        return Colors.blue;
      case ExamStatus.published:
        return Colors.green;
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