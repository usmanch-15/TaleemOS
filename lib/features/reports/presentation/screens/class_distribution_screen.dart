import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/report_provider.dart';
import '../widgets/bar_chart_widget.dart';

class ClassDistributionScreen extends ConsumerWidget {
  const ClassDistributionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(classWiseStudentCountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Class-wise Distribution')),
      body: dataAsync.when(
        data: (list) {
          if (list.isEmpty) return const Center(child: Text('Koi data nahi mila'));
          final chartData = list.map((c) => (label: c.className, value: c.studentCount.toDouble())).toList();
          return SingleChildScrollView(
            child: Column(
              children: [
                SimpleBarChart(data: chartData, color: Colors.indigo),
                const Divider(),
                ...list.map((c) => ListTile(title: Text(c.className), trailing: Text('${c.studentCount} students'))),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}