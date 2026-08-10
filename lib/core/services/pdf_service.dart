import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  PdfService._();
  static final PdfService instance = PdfService._();

  Future<File> generateReportCard({
    required String schoolName,
    required String studentName,
    required String studentCode,
    required String className,
    required String examName,
    required List<Map<String, dynamic>> subjectResults, // [{subject, obtained, total}]
    required double totalObtained,
    required double totalPossible,
    required double percentage,
    required String grade,
    required bool isPass,
    int? classPosition,
    String? teacherRemarks,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(schoolName, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Center(child: pw.Text('Report Card — $examName', style: const pw.TextStyle(fontSize: 14))),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Student: $studentName'),
                  pw.Text('Code: $studentCode'),
                ],
              ),
              pw.Text('Class: $className'),
              pw.SizedBox(height: 16),
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Subject', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Obtained', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...subjectResults.map((s) => pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(s['subject'].toString())),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(s['obtained'].toString())),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(s['total'].toString())),
                  ])),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total: ${totalObtained.toStringAsFixed(1)} / ${totalPossible.toStringAsFixed(1)}'),
                  pw.Text('Percentage: ${percentage.toStringAsFixed(1)}%'),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Grade: $grade'),
                  if (classPosition != null) pw.Text('Position: $classPosition'),
                  pw.Text(
                    isPass ? 'Result: PASS' : 'Result: FAIL',
                    style: pw.TextStyle(color: isPass ? PdfColors.green : PdfColors.red, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              if (teacherRemarks != null && teacherRemarks.isNotEmpty) ...[
                pw.SizedBox(height: 16),
                pw.Text('Remarks: $teacherRemarks'),
              ],
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/report_card_${studentCode}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}