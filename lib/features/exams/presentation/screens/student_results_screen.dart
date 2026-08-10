import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/exam_provider.dart';

class StudentResultsScreen extends ConsumerWidget {
  final String studentId;
  final String studentName;
  const StudentResultsScreen({super.key, required this.studentId, required this.studentName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(studentExamSummariesProvider(studentId));

    return Scaffold(
      appBar: AppBar(title: Text('$studentName — Results')),
      body: summariesAsync.when(
        data: (summaries) {
          if (summaries.isEmpty) return const Center(child: Text('Abhi tak koi result publish nahi hua'));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: summaries.length,
            itemBuilder: (context, index) {
              final s = summaries[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  title: Text(s.examName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${s.percentage.toStringAsFixed(1)}% • Grade: ${s.overallGrade ?? "-"}'),
                  trailing: Icon(
                    s.isPass ? Icons.check_circle : Icons.cancel,
                    color: s.isPass ? Colors.green : Colors.red,
                  ),
                  onTap: () => context.push(
                    '/results/report-card/${s.examId}',
                    extra: {'studentId': studentId, 'studentName': studentName},
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