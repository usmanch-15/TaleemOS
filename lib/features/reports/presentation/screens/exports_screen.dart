import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/services/csv_export_service.dart';
import '../providers/report_provider.dart';

class ExportsScreen extends ConsumerStatefulWidget {
  const ExportsScreen({super.key});

  @override
  ConsumerState<ExportsScreen> createState() => _ExportsScreenState();
}

class _ExportsScreenState extends ConsumerState<ExportsScreen> {
  bool _isExporting = false;

  Future<void> _export(Future<void> Function() action) async {
    setState(() => _isExporting = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final schoolId = ref.watch(authControllerProvider).user?.schoolId;

    return Scaffold(
      appBar: AppBar(title: const Text('Export Data')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ExportTile(
            icon: Icons.people_outline,
            title: 'Student List',
            subtitle: 'Names, classes, contact info',
            isLoading: _isExporting,
            onTap: schoolId == null
                ? null
                : () => _export(() async {
              final data = await ref.read(reportRepositoryProvider).getStudentListExport(schoolId);
              final file = await CsvExportService.instance.exportStudentList(data);
              await Printing.sharePdf(bytes: await file.readAsBytes(), filename: file.path.split('/').last);
            }),
          ),
          _ExportTile(
            icon: Icons.receipt_long_outlined,
            title: 'Pending Fees Report',
            subtitle: 'All pending/overdue invoices',
            isLoading: _isExporting,
            onTap: schoolId == null
                ? null
                : () => _export(() async {
              final data = await ref.read(reportRepositoryProvider).getPendingFeesExport(schoolId);
              final file = await CsvExportService.instance.exportPendingFees(data);
              await Printing.sharePdf(bytes: await file.readAsBytes(), filename: file.path.split('/').last);
            }),
          ),
        ],
      ),
    );
  }
}

class _ExportTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ExportTile({required this.icon, required this.title, required this.subtitle, required this.isLoading, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.indigo.shade50, child: Icon(icon, color: Colors.indigo)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.download),
        onTap: isLoading ? null : onTap,
      ),
    );
  }
}