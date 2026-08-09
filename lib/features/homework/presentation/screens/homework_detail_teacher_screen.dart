
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/homework_entity.dart';
import '../providers/homework_provider.dart';
import '../widgets/homework_status_badge.dart';

class HomeworkDetailTeacherScreen extends ConsumerWidget {
  final String homeworkId;
  const HomeworkDetailTeacherScreen({super.key, required this.homeworkId});

  void _showGradeDialog(BuildContext context, WidgetRef ref, SubmissionEntity submission, double? totalMarks) {
    final marksController = TextEditingController(text: submission.obtainedMarks?.toString() ?? '');
    final feedbackController = TextEditingController(text: submission.teacherFeedback ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Grade — ${submission.studentName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: marksController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Obtained Marks ${totalMarks != null ? "/ $totalMarks" : ""}'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: feedbackController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Feedback (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final marks = double.tryParse(marksController.text.trim());
              if (marks == null) return;
              await ref.read(submissionControllerProvider.notifier).gradeSubmission(
                submissionId: submission.id,
                obtainedMarks: marks,
                feedback: feedbackController.text.trim(),
                homeworkId: homeworkId,
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save Grade'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeworkAsync = ref.watch(homeworkDetailProvider(homeworkId));
    final submissionsAsync = ref.watch(homeworkSubmissionsProvider(homeworkId));
    final statsAsync = ref.watch(homeworkCompletionStatsProvider(homeworkId));

    return Scaffold(
      appBar: AppBar(title: const Text('Homework Detail')),
      body: homeworkAsync.when(
        data: (hw) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(child: Text(hw.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                HomeworkStatusBadge(status: hw.status, isOverdue: hw.isOverdue),
              ],
            ),
            const SizedBox(height: 4),
            Text('${hw.subjectName} • Due: ${DateFormat('dd MMM yyyy').format(hw.dueDate)}',
                style: TextStyle(color: Colors.grey.shade600)),
            if (hw.description != null && hw.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(hw.description!),
            ],
            const SizedBox(height: 16),
            statsAsync.when(
              data: (stats) => Card(
                color: Colors.indigo.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatBlock(label: 'Submitted', value: '${stats.submittedCount}'),
                      _StatBlock(label: 'Late', value: '${stats.lateCount}'),
                      _StatBlock(label: 'Checked', value: '${stats.checkedCount}'),
                      _StatBlock(label: 'Pending', value: '${stats.pendingCount}'),
                    ],
                  ),
                ),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            const Text('Submissions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            submissionsAsync.when(
              data: (submissions) {
                if (submissions.isEmpty) return const Text('Koi submission nahi hui abhi tak');
                return Column(
                  children: submissions.map((s) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(s.studentName),
                        subtitle: s.submittedAt != null
                            ? Text('Submitted: ${DateFormat('dd MMM, hh:mm a').format(s.submittedAt!)}')
                            : const Text('Abhi submit nahi kiya'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SubmissionStatusBadge(status: s.status),
                            if (s.status.name == 'submitted' || s.status.name == 'late' || s.status.name == 'checked')
                              IconButton(
                                icon: const Icon(Icons.grade_outlined, size: 20),
                                onPressed: () => _showGradeDialog(context, ref, s, hw.totalMarks),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  const _StatBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}