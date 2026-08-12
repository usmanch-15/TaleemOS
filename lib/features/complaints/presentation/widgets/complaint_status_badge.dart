import 'package:flutter/material.dart';
import '../../domain/entities/complaint_entity.dart';

class ComplaintStatusBadge extends StatelessWidget {
  final ComplaintStatus status;
  const ComplaintStatusBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case ComplaintStatus.open:
        return Colors.orange;
      case ComplaintStatus.inProgress:
        return Colors.blue;
      case ComplaintStatus.resolved:
        return Colors.green;
      case ComplaintStatus.closed:
        return Colors.grey;
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

class ComplaintPriorityBadge extends StatelessWidget {
  final ComplaintPriority priority;
  const ComplaintPriorityBadge({super.key, required this.priority});

  Color get _color {
    switch (priority) {
      case ComplaintPriority.low:
        return Colors.grey;
      case ComplaintPriority.normal:
        return Colors.blue;
      case ComplaintPriority.high:
        return Colors.orange;
      case ComplaintPriority.urgent:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.flag, size: 12, color: _color),
        const SizedBox(width: 3),
        Text(priority.label, style: TextStyle(fontSize: 11, color: _color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}