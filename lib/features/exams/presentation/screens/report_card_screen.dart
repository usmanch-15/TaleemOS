import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../school/presentation/providers/school_provider.dart';
import '../providers/exam_provider.dart';

class ReportCardScreen extends ConsumerWidget {
  final String examId;
  final String studentId;
  final String studentName;

  const ReportCardScreen({super.key, required this.examId, required this.studentId, required this.studentName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryFuture = ref.watch(getReportCardUsecaseProvider).summary(examId: examId, studentId: studentId);
    final subjectsFuture = ref.watch(getReportCardUsecaseProvider).subjectWise(examId: examId, studentId: studentId);
    final schoolAsync = ref.watch(currentSchoolProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Card'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () async {
              final summary = await summaryFuture;
              final subjects = await subjectsFuture;
              final school = schoolAsync.value;
              if (summary == null || school == null) return;

              final subjectResults = subjects.map((s) {
                final examSubject = s['exam_subjects'] as Map<String, dynamic>;
                final subject = examSubject['subjects'] as Map<String, dynamic>;
                return {
                  'subject': subject['name'],
                  'obtained': s['obtained_marks']?.toString() ?? '-',
                  'total': examSubject['total_marks'].toString(),
                };
              }).toList();

              final file = await PdfService.instance.generateReportCard(
                schoolName: school.name,
                studentName: studentName,
                studentCode: studentId,
                className: '',
                examName: summary.examName,
                subjectResults: subjectResults,
                totalObtained: summary.totalObtained,
                totalPossible: summary.totalPossible,
                percentage: summary.percentage,
                grade: summary.overallGrade ?? '-',
                isPass: summary.isPass,
                classPosition: summary.classPosition,
                teacherRemarks: summary.teacherRemarks,
              );

              await Printing.sharePdf(bytes: await file.readAsBytes(), filename: 'report_card.pdf');
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([summaryFuture, subjectsFuture]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final summary = snapshot.data![0] as dynamic;
          final subjects = snapshot.data![1] as List<Map<String, dynamic>>;

          if (summary == null) return const Center(child: Text('Result nahi mila'));

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(child: Text(studentName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              Center(child: Text(summary.examName, style: TextStyle(color: Colors.grey.shade600))),
              const SizedBox(height: 20),
              Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                children: [
                  const TableRow(
                    decoration: BoxDecoration(color: Color(0xFFF0F0F0)),
                    children: [
                      Padding(padding: EdgeInsets.all(8), child: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.all(8), child: Text('Marks', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                  ...subjects.map((s) {
                    final examSubject = s['exam_subjects'] as Map<String, dynamic>;
                    final subject = examSubject['subjects'] as Map<String, dynamic>;
                    return TableRow(children: [
                      Padding(padding: const EdgeInsets.all(8), child: Text(subject['name'] as String)),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('${s['obtained_marks'] ?? '-'} / ${examSubject['total_marks']}'),
                      ),
                    ]);
                  }),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                color: summary.isPass ? Colors.green.shade50 : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total: ${summary.totalObtained}/${summary.totalPossible}'),
                          Text('${summary.percentage.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Grade: ${summary.overallGrade ?? "-"}'),
                          if (summary.classPosition != null) Text('Position: ${summary.classPosition}'),
                          Text(
                            summary.isPass ? 'PASS' : 'FAIL',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: summary.isPass ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (summary.teacherRemarks != null && summary.teacherRemarks!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Teacher Remarks: ${summary.teacherRemarks}'),
              ],
            ],
          );
        },
      ),
    );
  }
}