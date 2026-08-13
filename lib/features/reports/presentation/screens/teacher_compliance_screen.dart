import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/report_provider.dart';

class TeacherComplianceScreen extends ConsumerWidget {
  const TeacherComplianceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(teacherMarkingStatusProvider);
    final selectedDate = ref.watch(selectedComplianceDateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Compliance')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 60)),
                  lastDate: DateTime.now(),
                );
                if (picked != null) ref.read(selectedComplianceDateProvider.notifier).state = picked;
              },
            ),
          ),
          Expanded(
            child: statusAsync.when(
              data: (list) {
                if (list.isEmpty) return const Center(child: Text('Koi data nahi mila'));
                final notMarked = list.where((t) => !t.hasMarked).length;

                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: notMarked > 0 ? Colors.orange.shade50 : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        notMarked > 0
                            ? '$notMarked teachers ne abhi tak attendance mark nahi ki'
                            : 'Sab teachers ne attendance mark kar di hai 🎉',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final t = list[index];
                          return ListTile(
                            leading: Icon(
                              t.hasMarked ? Icons.check_circle : Icons.cancel,
                              color: t.hasMarked ? Colors.green : Colors.red,
                            ),
                            title: Text(t.teacherName),
                            subtitle: Text(t.className),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}