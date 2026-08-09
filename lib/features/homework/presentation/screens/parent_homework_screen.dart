
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/homework_provider.dart';
import '../widgets/homework_status_badge.dart';

class ParentHomeworkScreen extends ConsumerWidget {
  final String studentId;
  final String studentName;
  const ParentHomeworkScreen({super.key, required this.studentId, required this.studentName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(childSubmissionsProvider(studentId));

    return Scaffold(
      appBar: AppBar(title: Text('$studentName — Homework')),
      body: submissionsAsync.when(
        data: (submissions) {
          if (submissions.isEmpty) return const Center(child: Text('Abhi tak koi homework record nahi hai'));

          final pending = submissions.where((s) => s.submittedAt == null).toList();
          final completed = submissions.where((s) => s.submittedAt != null).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pending.isNotEmpty) ...[
                const Text('Pending', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                ...pending.map((s) => Card(
                  color: Colors.orange.shade50,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(s.studentName),
                    trailing: SubmissionStatusBadge(status: s.status),
                  ),
                )),
                const SizedBox(height: 16),
              ],
              if (completed.isNotEmpty) ...[
                const Text('Completed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                ...completed.map((s) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(s.submittedAt != null ? DateFormat('dd MMM yyyy').format(s.submittedAt!) : ''),
                    subtitle: s.obtainedMarks != null ? Text('Marks: ${s.obtainedMarks}') : null,
                    trailing: SubmissionStatusBadge(status: s.status),
                  ),
                )),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}