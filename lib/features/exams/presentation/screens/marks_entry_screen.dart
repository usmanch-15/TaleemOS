import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/exam_provider.dart';

class MarksEntryScreen extends ConsumerStatefulWidget {
  final String examId;
  final String examSubjectId;
  final String subjectName;
  final String classId;
  final double totalMarks;

  const MarksEntryScreen({
    super.key,
    required this.examId,
    required this.examSubjectId,
    required this.subjectName,
    required this.classId,
    required this.totalMarks,
  });

  @override
  ConsumerState<MarksEntryScreen> createState() => _MarksEntryScreenState();
}

class _MarksEntryScreenState extends ConsumerState<MarksEntryScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final marks = <String, double?>{};
    for (final entry in _controllers.entries) {
      final value = double.tryParse(entry.value.text.trim());
      if (value != null) {
        if (value > widget.totalMarks) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Marks total (${widget.totalMarks}) se zyada nahi ho sakte')),
          );
          return;
        }
        marks[entry.key] = value;
      }
    }

    final success = await ref.read(examManagementControllerProvider.notifier).saveMarks(
      examId: widget.examId,
      examSubjectId: widget.examSubjectId,
      marks: marks,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marks save ho gaye')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sheetAsync = ref.watch(marksSheetProvider((
    examSubjectId: widget.examSubjectId,
    classId: widget.classId,
    sectionId: null,
    )));
    final state = ref.watch(examManagementControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Marks Entry — ${widget.subjectName}')),
      body: sheetAsync.when(
        data: (results) {
          for (final r in results) {
            _controllers.putIfAbsent(r.studentId, () => TextEditingController(text: r.obtainedMarks?.toString() ?? ''));
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.indigo.shade50,
                child: Text('Total Marks: ${widget.totalMarks}', style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final r = results[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Text(r.studentName)),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _controllers[r.studentId],
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                hintText: '0 - ${widget.totalMarks.toStringAsFixed(0)}',
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: AppButton(label: 'Save Marks', onPressed: _submit, isLoading: state.isLoading),
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