
import 'package:flutter/material.dart';
import '../../domain/entities/attendance_entity.dart';

class AttendanceStatusSelector extends StatelessWidget {
  final AttendanceStatus? selected;
  final ValueChanged<AttendanceStatus> onChanged;

  const AttendanceStatusSelector({super.key, this.selected, required this.onChanged});

  Color _colorFor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.leave:
        return Colors.blue;
    }
  }

  IconData _iconFor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.absent:
        return Icons.cancel;
      case AttendanceStatus.late:
        return Icons.access_time_filled;
      case AttendanceStatus.leave:
        return Icons.event_busy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: AttendanceStatus.values.map((status) {
        final isSelected = selected == status;
        final color = _colorFor(status);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: GestureDetector(
            onTap: () => onChanged(status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: isSelected ? 1.5 : 1),
              ),
              child: Icon(_iconFor(status), color: isSelected ? color : Colors.grey.shade400, size: 22),
            ),
          ),
        );
      }).toList(),
    );
  }
}