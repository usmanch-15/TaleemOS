import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/attendance_provider.dart';
import '../widgets/attendance_calendar.dart';

class AttendanceHistoryScreen extends ConsumerWidget {
  final String studentId;
  final String studentName;
  const AttendanceHistoryScreen({super.key, required this.studentId, required this.studentName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedAttendanceMonthProvider);
    final historyAsync = ref.watch(studentAttendanceHistoryProvider(studentId));
    final percentageAsync = ref.watch(studentAttendancePercentageProvider(studentId));

    return Scaffold(
      appBar: AppBar(title: Text('$studentName — Attendance')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => ref.read(selectedAttendanceMonthProvider.notifier).state =
                      DateTime(selectedMonth.year, selectedMonth.month - 1),
                ),
                Expanded(
                  child: Text(
                    DateFormat('MMMM yyyy').format(selectedMonth),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: selectedMonth.month == DateTime.now().month && selectedMonth.year == DateTime.now().year
                      ? null
                      : () => ref.read(selectedAttendanceMonthProvider.notifier).state =
                      DateTime(selectedMonth.year, selectedMonth.month + 1),
                ),
              ],
            ),
          ),
          percentageAsync.when(
            data: (pct) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: pct >= 75 ? Colors.green.shade50 : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Is mahine ki attendance', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: pct >= 75 ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            loading: () => const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
          historyAsync.when(
            data: (records) => AttendanceCalendar(month: selectedMonth, records: records),
            loading: () => const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Padding(padding: const EdgeInsets.all(16), child: Text('Error: $e')),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 24),
        ],
      ),
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