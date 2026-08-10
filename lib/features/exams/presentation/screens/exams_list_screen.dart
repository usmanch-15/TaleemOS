import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/exam_provider.dart';
import '../widgets/exam_status_badge.dart';

class ExamsListScreen extends ConsumerWidget {
  const ExamsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examsAsync = ref.watch(examsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Exams')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/exams/create'),
        icon: const Icon(Icons.add),
        label: const Text('Create Exam'),
      ),
      body: examsAsync.when(
        data: (exams) {
          if (exams.isEmpty) return const Center(child: Text('Abhi koi exam nahi banaya gaya'));
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: exams.length,
            itemBuilder: (context, index) {
              final exam = exams[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  title: Text(exam.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${exam.className} • ${exam.examType.label}\n${DateFormat('dd MMM').format(exam.startDate)} - ${DateFormat('dd MMM yyyy').format(exam.endDate)}',
                  ),
                  isThreeLine: true,
                  trailing: ExamStatusBadge(status: exam.status),
                  onTap: () => context.push('/admin/exams/${exam.id}'),
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