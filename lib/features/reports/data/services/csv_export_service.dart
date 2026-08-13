import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

class CsvExportService {
  CsvExportService._();
  static final CsvExportService instance = CsvExportService._();

  Future<File> exportStudentList(List<Map<String, dynamic>> students) async {
    final rows = <List<dynamic>>[
      ['Student Code', 'Full Name', 'Father Name', 'Class', 'Section', 'Status', 'Phone'],
      ...students.map((s) => [
        s['student_code'] ?? '',
        s['full_name'] ?? '',
        s['father_name'] ?? '',
        (s['classes'] as Map?)?['name'] ?? '',
        (s['sections'] as Map?)?['name'] ?? '',
        s['status'] ?? '',
        s['phone'] ?? '',
      ]),
    ];
    return _writeCsv(rows, 'student_list');
  }

  Future<File> exportPendingFees(List<Map<String, dynamic>> invoices) async {
    final rows = <List<dynamic>>[
      ['Student', 'Student Code', 'Fee Title', 'Total Payable', 'Amount Paid', 'Balance', 'Due Date', 'Status'],
      ...invoices.map((inv) {
        final student = inv['students'] as Map?;
        final total = (inv['total_payable'] as num?)?.toDouble() ?? 0;
        final paid = (inv['amount_paid'] as num?)?.toDouble() ?? 0;
        return [
          student?['full_name'] ?? '',
          student?['student_code'] ?? '',
          inv['title'] ?? '',
          total,
          paid,
          total - paid,
          inv['due_date'] ?? '',
          inv['status'] ?? '',
        ];
      }),
    ];
    return _writeCsv(rows, 'pending_fees');
  }

  Future<File> _writeCsv(List<List<dynamic>> rows, String prefix) async {
    final csvData = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${prefix}_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvData);
    return file;
  }
}