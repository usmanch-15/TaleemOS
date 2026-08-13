import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../classes/presentation/providers/class_provider.dart';
import '../providers/attendance_provider.dart';
import '../widgets/attendance_summary_card.dart';

class AttendanceReportScreen extends ConsumerStatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  ConsumerState<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends ConsumerState<AttendanceReportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedClassId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(classesListProvider);
    final selectedDate = ref.watch(selectedAttendanceDateProvider);
    final selectedMonth = ref.watch(selectedAttendanceMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Reports'),
        bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'Daily / Class'), Tab(text: 'Low Attendance')]),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: classesAsync.when(
                        data: (classes) => DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Class select karein'),
                          value: _selectedClassId,
                          items: classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                          onChanged: (value) => setState(() => _selectedClassId = value),
                        ),
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const Text('Error loading classes'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(DateFormat('dd MMM').format(selectedDate)),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) ref.read(selectedAttendanceDateProvider.notifier).state = picked;
                      },
                    ),
                  ],
                ),
              ),
              if (_selectedClassId != null)
                Expanded(
                  child: FutureBuilder(
                    future: ref.read(getAttendanceReportUsecaseProvider).classSummary(classId: _selectedClassId!, date: selectedDate),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      return SingleChildScrollView(child: AttendanceSummaryCard(summary: snapshot.data!));
                    },
                  ),
                )
              else
                const Expanded(child: Center(child: Text('Class select karein report dekhne ke liye'))),
            ],
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => ref.read(selectedAttendanceMonthProvider.notifier).state =
                          DateTime(selectedMonth.year, selectedMonth.month - 1),
                    ),
                    Text(DateFormat('MMMM yyyy').format(selectedMonth), style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => ref.read(selectedAttendanceMonthProvider.notifier).state =
                          DateTime(selectedMonth.year, selectedMonth.month + 1),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) {
                    final lowAttendanceAsync = ref.watch(lowAttendanceStudentsProvider);
                    return lowAttendanceAsync.when(
                      data: (students) {
                        if (students.isEmpty) {
                          return const Center(child: Text('Koi student 75% se kam attendance par nahi hai'));
                        }
                        return ListView.builder(
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final s = students[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.red.shade50,
                                  child: Text('${s.percentage.toStringAsFixed(0)}%', style: TextStyle(fontSize: 11, color: Colors.red.shade700, fontWeight: FontWeight.bold)),
                                ),
                                title: Text(s.fullName),
                                subtitle: Text(s.studentCode),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}