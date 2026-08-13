import 'package:flutter/material.dart';
import '../../../attendance/domain/entities/attendance_entity.dart';


class AttendanceCalendar extends StatelessWidget {
  final DateTime month;
  final List<AttendanceEntity> records;

  const AttendanceCalendar({super.key, required this.month, required this.records});

  Color _colorFor(AttendanceStatus? status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.leave:
        return Colors.blue;
      case null:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;

    final statusByDay = <int, AttendanceStatus>{};
    for (final r in records) {
      statusByDay[r.date.day] = r.status;
    }

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemCount: daysInMonth + firstWeekday,
          itemBuilder: (context, index) {
            if (index < firstWeekday) return const SizedBox.shrink();
            final day = index - firstWeekday + 1;
            final status = statusByDay[day];
            return Container(
              decoration: BoxDecoration(
                color: _colorFor(status).withOpacity(status == null ? 1 : 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: status != null ? FontWeight.bold : FontWeight.normal,
                  color: status != null ? _colorFor(status) : Colors.grey.shade500,
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 12,
            children: const [
              _LegendItem(color: Colors.green, label: 'Present'),
              _LegendItem(color: Colors.red, label: 'Absent'),
              _LegendItem(color: Colors.orange, label: 'Late'),
              _LegendItem(color: Colors.blue, label: 'Leave'),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}