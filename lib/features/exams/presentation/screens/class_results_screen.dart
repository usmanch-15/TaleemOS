

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/exam_provider.dart';

class ClassResultsScreen extends ConsumerWidget {
  final String examId;
  const ClassResultsScreen({super.key, required this.examId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(classExamSummariesProvider(examId));

    return Scaffold(
      appBar: AppBar(title: const Text('Class Results')),
      body: summariesAsync.when(
        data: (summaries) {
          if (summaries.isEmpty) return const Center(child: Text('Koi result nahi mila'));
          return ListView.builder(
            itemCount: summaries.length,
            itemBuilder: (context, index) {
              final s = summaries[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: s.isPass ? Colors.green.shade50 : Colors.red.shade50,
                    child: Text(
                      '#${s.classPosition ?? "-"}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: s.isPass ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  ),
                  title: Text(s.studentName),
                  subtitle: Text('${s.totalObtained}/${s.totalPossible} • ${s.percentage.toStringAsFixed(1)}%'),
                  trailing: Chip(
                    label: Text(s.overallGrade ?? '-', style: const TextStyle(fontSize: 12)),
                    backgroundColor: s.isPass ? Colors.green.shade50 : Colors.red.shade50,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}