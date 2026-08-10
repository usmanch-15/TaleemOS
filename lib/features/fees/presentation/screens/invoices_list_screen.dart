import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/fee_provider.dart';
import '../widgets/invoice_status_badge.dart';

class InvoicesListScreen extends ConsumerWidget {
  const InvoicesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(schoolInvoicesProvider);
    final filter = ref.watch(schoolInvoicesFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Fee Invoices')),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'generate',
            onPressed: () => context.push('/fees/generate-invoices'),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate'),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                _FilterChip(label: 'All', selected: filter == null, onTap: () => ref.read(schoolInvoicesFilterProvider.notifier).state = null),
                _FilterChip(label: 'Pending', selected: filter == 'pending', onTap: () => ref.read(schoolInvoicesFilterProvider.notifier).state = 'pending'),
                _FilterChip(label: 'Paid', selected: filter == 'paid', onTap: () => ref.read(schoolInvoicesFilterProvider.notifier).state = 'paid'),
                _FilterChip(label: 'Overdue', selected: filter == 'overdue', onTap: () => ref.read(schoolInvoicesFilterProvider.notifier).state = 'overdue'),
              ],
            ),
          ),
          Expanded(
            child: invoicesAsync.when(
              data: (invoices) {
                if (invoices.isEmpty) return const Center(child: Text('Koi invoice nahi mili'));
                return ListView.builder(
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    final inv = invoices[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        title: Text(inv.studentName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${inv.title} • Due: ${DateFormat('dd MMM').format(inv.dueDate)}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Rs. ${inv.balance.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            InvoiceStatusBadge(status: inv.status),
                          ],
                        ),
                        onTap: () => context.push('/fees/invoice/${inv.id}'),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap()),
    );
  }
}