import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../classes/presentation/providers/class_provider.dart';
import '../../domain/entities/exam_entity.dart';
import '../providers/exam_provider.dart';
import '../widgets/exam_status_badge.dart';

class ExamDetailScreen extends ConsumerStatefulWidget {
  final String examId;
  const ExamDetailScreen({super.key, required this.examId});

  @override
  ConsumerState<ExamDetailScreen> createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends ConsumerState<ExamDetailScreen> {
  void _showAddSubjectDialog(ExamEntity exam) {
    String? selectedSubjectId;
    final totalMarksController = TextEditingController(text: '100');
    final passingMarksController = TextEditingController(text: '40');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final subjectsAsync = ref.watch(subjectsForClassProvider(exam.classId));
          return AlertDialog(
            title: const Text('Add Subject to Exam'),
            content: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  subjectsAsync.when(
                    data: (subjects) {
                      final availableSubjects =
                      subjects.where((s) => !exam.subjects.any((es) => es.subjectId == s.id)).toList();
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Subject'),
                        items: availableSubjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                        onChanged: (value) => setDialogState(() => selectedSubjectId = value),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Error'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: totalMarksController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Total Marks'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passingMarksController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Passing Marks'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () async {
                  if (selectedSubjectId == null) return;
                  final total = double.tryParse(totalMarksController.text) ?? 100;
                  final passing = double.tryParse(passingMarksController.text) ?? 40;
                  await ref.read(examManagementControllerProvider.notifier).addSubject(
                    examId: exam.id,
                    subjectId: selectedSubjectId!,
                    totalMarks: total,
                    passingMarks: passing,
                  );
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmPublish(String examId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publish Exam'),
        content: const Text(
          'Publish karne ke baad results students/parents ko nazar aayenge aur class positions final ho jayengi. Confirm karein?',
        ),
        actions: [
          TextButton(onPressed: () => context.pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => context.pop(true), child: const Text('Publish')),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(examManagementControllerProvider.notifier).publishExam(examId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exam publish ho gaya')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final examAsync = ref.watch(examDetailProvider(widget.examId));

    return Scaffold(
      appBar: AppBar(title: const Text('Exam Detail')),
      body: examAsync.when(
        data: (exam) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(child: Text(exam.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  ExamStatusBadge(status: exam.status),
                ],
              ),
              Text('${exam.className} • ${exam.examType.label}', style: TextStyle(color: Colors.grey.shade600)),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subjects', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Subject'),
                    onPressed: () => _showAddSubjectDialog(exam),
                  ),
                ],
              ),
              if (exam.subjects.isEmpty)
                const Padding(padding: EdgeInsets.all(16), child: Text('Koi subject add nahi hua'))
              else
                ...exam.subjects.map((s) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(s.subjectName),
                    subtitle: Text('Total: ${s.totalMarks} • Passing: ${s.passingMarks}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_note),
                      tooltip: 'Marks Entry',
                      onPressed: () => context.push(
                        '/admin/exams/${exam.id}/marks-entry',
                        extra: {'examSubjectId': s.id, 'subjectName': s.subjectName, 'classId': exam.classId, 'totalMarks': s.totalMarks},
                      ),
                    ),
                  ),
                )),
              const SizedBox(height: 24),
              if (exam.status != ExamStatus.published && exam.subjects.isNotEmpty)
                ElevatedButton.icon(
                  icon: const Icon(Icons.publish),
                  label: const Text('Publish Exam Results'),
                  onPressed: () => _confirmPublish(exam.id),
                ),
              if (exam.status == ExamStatus.published)
                OutlinedButton.icon(
                  icon: const Icon(Icons.leaderboard),
                  label: const Text('View Class Results & Positions'),
                  onPressed: () => context.push('/admin/exams/${exam.id}/results'),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}