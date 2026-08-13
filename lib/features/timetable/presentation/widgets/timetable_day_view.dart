
import 'package:flutter/material.dart';
import '../../domain/entities/timetable_entity.dart';

class TimetableDayView extends StatelessWidget {
  final List<TimetableEntryEntity> entries;
  final void Function(TimetableEntryEntity)? onDelete;

  const TimetableDayView({super.key, required this.entries, this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text('Is din koi period nahi hai')),
      );
    }
    final sorted = [...entries]..sort((a, b) => a.startTime.compareTo(b.startTime));

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final e = sorted[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Container(
              width: 6,
              decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(3)),
            ),
            title: Text(e.subjectName, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${e.startTime} - ${e.endTime}${e.teacherName != null ? " • ${e.teacherName}" : ""}${e.roomNumber != null ? " • Room ${e.roomNumber}" : ""}'),
            trailing: onDelete != null
                ? IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => onDelete!(e))
                : null,
          ),
        );
      },
    );
  }
}