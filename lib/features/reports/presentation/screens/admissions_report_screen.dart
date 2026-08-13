import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/report_provider.dart';
import '../widgets/bar_chart_widget.dart';

class AdmissionsReportScreen extends ConsumerWidget {
  const AdmissionsReportScreen({super.key});

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(admissionsReportProvider);
    final selectedYear = ref.watch(selectedReportYearProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admissions Trend'),
        actions: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => ref.read(selectedReportYearProvider.notifier).state = selectedYear - 1),
          Center(child: Text('$selectedYear')),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => ref.read(selectedReportYearProvider.notifier).state = selectedYear + 1),
          const SizedBox(width: 8),
        ],
      ),
      body: dataAsync.when(
        data: (list) {
          final byMonth = {for (final d in list) d.month: d.count};
          final chartData = List.generate(12, (i) => (label: _monthNames[i], value: (byMonth[i + 1] ?? 0).toDouble()));
          return SimpleBarChart(data: chartData, color: Colors.teal);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}