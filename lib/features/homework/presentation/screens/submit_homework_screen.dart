
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/homework_entity.dart';
import '../providers/homework_provider.dart';
import '../widgets/homework_status_badge.dart';

class SubmitHomeworkScreen extends ConsumerStatefulWidget {
  final String homeworkId;
  const SubmitHomeworkScreen({super.key, required this.homeworkId});

  @override
  ConsumerState<SubmitHomeworkScreen> createState() => _SubmitHomeworkScreenState();
}

class _SubmitHomeworkScreenState extends ConsumerState<SubmitHomeworkScreen> {
  final _answerController = TextEditingController();
  File? _attachment;
  String? _attachmentName;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _attachment = File(result.files.single.path!);
        _attachmentName = result.files.single.name;
      });
    }
  }

  Future<void> _submit() async {
    final success = await ref.read(submissionControllerProvider.notifier).submit(
      homeworkId: widget.homeworkId,
      textAnswer: _answerController.text.trim(),
      attachmentFile: _attachment,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Homework submit ho gaya')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeworkAsync = ref.watch(homeworkDetailProvider(widget.homeworkId));
    final submissionAsync = ref.watch(studentSubmissionProvider(widget.homeworkId));
    final submitState = ref.watch(submissionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Homework')),
      body: homeworkAsync.when(
        data: (hw) => submissionAsync.when(
          data: (submission) {
            final alreadySubmitted = submission?.submittedAt != null;
            final isChecked = submission?.status == SubmissionStatus.checked || submission?.status == SubmissionStatus.returned;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    Expanded(child: Text(hw.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                    if (submission != null) SubmissionStatusBadge(status: submission.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${hw.subjectName} • Due: ${DateFormat('dd MMM yyyy').format(hw.dueDate)}',
                    style: TextStyle(color: hw.isOverdue ? Colors.red : Colors.grey.shade600)),
                if (hw.description != null && hw.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(hw.description!),
                ],
                if (hw.instructions != null && hw.instructions!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Instructions:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                  Text(hw.instructions!),
                ],
                const Divider(height: 32),
                if (isChecked) ...[
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Obtained Marks: ${submission!.obtainedMarks ?? "-"} ${hw.totalMarks != null ? "/ ${hw.totalMarks}" : ""}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          if (submission.teacherFeedback != null && submission.teacherFeedback!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Feedback: ${submission.teacherFeedback}'),
                          ],
                        ],
                      ),
                    ),
                  ),
                ] else if (alreadySubmitted) ...[
                  const Text('Aapka Answer', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (submission!.textAnswer != null && submission.textAnswer!.isNotEmpty) Text(submission.textAnswer!),
                  if (submission.attachmentName != null) ...[
                    const SizedBox(height: 8),
                    Row(children: [const Icon(Icons.attach_file, size: 18), const SizedBox(width: 4), Text(submission.attachmentName!)]),
                  ],
                  const SizedBox(height: 12),
                  const Text('Teacher check karne ka intezar hai', style: TextStyle(color: Colors.orange)),
                ] else ...[
                  TextField(
                    controller: _answerController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Apna jawab yahan likhein...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.attach_file),
                    label: Text(_attachmentName ?? 'File Attach Karein (optional)'),
                    onPressed: _pickFile,
                  ),
                  const SizedBox(height: 20),
                  AppButton(label: 'Submit Homework', onPressed: _submit, isLoading: submitState.isLoading),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}