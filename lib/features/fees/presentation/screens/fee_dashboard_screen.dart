
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/fee_provider.dart';
import '../widgets/fee_summary_card.dart';

class FeeDashboardScreen extends ConsumerWidget {
  const FeeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(collectionSummaryProvider);
    final selectedMonth = ref.watch(selectedFeeMonthProvider);
    final pendingAsync = ref.watch(pendingFeesReportProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Fee Dashboard')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => ref.read(selectedFeeMonthProvider.notifier).state =
                      DateTime(selectedMonth.year, selectedMonth.month - 1),
                ),
                Text(DateFormat('MMMM yyyy').format(selectedMonth), style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => ref.read(selectedFeeMonthProvider.notifier).state =
                      DateTime(selectedMonth.year, selectedMonth.month + 1),
                ),
              ],
            ),
          ),
          summaryAsync.when(
            data: (summary) => summary != null ? FeeSummaryCard(summary: summary) : const SizedBox.shrink(),
            loading: () => const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.list_alt),
                    label: const Text('All Invoices'),
                    onPressed: () => context.push('/fees/invoices'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('Fee Structures'),
                    onPressed: () => context.push('/fees/structures'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Pending Fees (${pendingAsync.value?.length ?? 0})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 8),
          pendingAsync.when(
            data: (invoices) {
              if (invoices.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text('Koi pending fee nahi hai 🎉'));
              return Column(
                children: invoices.take(10).map((inv) => Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    title: Text(inv.studentName),
                    subtitle: Text(inv.title),
                    trailing: Text('Rs. ${inv.balance.toStringAsFixed(0)}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                    onTap: () => context.push('/fees/invoice/${inv.id}'),
                  ),
                )).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}