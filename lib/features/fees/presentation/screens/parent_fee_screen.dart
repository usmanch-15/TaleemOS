
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/fee_provider.dart';
import '../widgets/invoice_status_badge.dart';

class ParentFeeScreen extends ConsumerWidget {
  final String studentId;
  final String studentName;
  const ParentFeeScreen({super.key, required this.studentId, required this.studentName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(studentInvoicesProvider(studentId));

    return Scaffold(
      appBar: AppBar(title: Text('$studentName — Fees')),
      body: invoicesAsync.when(
        data: (invoices) {
          if (invoices.isEmpty) return const Center(child: Text('Koi fee record nahi hai'));

          final totalDue = invoices.fold<double>(0, (sum, i) => sum + i.balance);

          return ListView(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: totalDue > 0 ? Colors.red.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text('Total Due', style: TextStyle(color: Colors.grey.shade700)),
                    const SizedBox(height: 4),
                    Text(
                      'Rs. ${totalDue.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: totalDue > 0 ? Colors.red.shade700 : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              ...invoices.map((inv) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  title: Text(inv.title),
                  subtitle: Text('Due: ${DateFormat('dd MMM yyyy').format(inv.dueDate)}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Rs. ${inv.balance.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      InvoiceStatusBadge(status: inv.status),
                    ],
                  ),
                ),
              )),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}