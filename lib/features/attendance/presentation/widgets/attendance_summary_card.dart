import 'package:flutter/material.dart';
import '../../domain/entities/attendance_entity.dart';

class AttendanceSummaryCard extends StatelessWidget {
  final AttendanceSummary summary;

  const AttendanceSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total: ${summary.totalStudents}', style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${summary.presentPercentage.toStringAsFixed(1)}% Present',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatChip(label: 'Present', count: summary.presentCount, color: Colors.green),
                _StatChip(label: 'Absent', count: summary.absentCount, color: Colors.red),
                _StatChip(label: 'Late', count: summary.lateCount, color: Colors.orange),
                _StatChip(label: 'Leave', count: summary.leaveCount, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}