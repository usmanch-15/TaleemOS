

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/fee_provider.dart';

class GenerateInvoicesScreen extends ConsumerStatefulWidget {
  const GenerateInvoicesScreen({super.key});

  @override
  ConsumerState<GenerateInvoicesScreen> createState() => _GenerateInvoicesScreenState();
}

class _GenerateInvoicesScreenState extends ConsumerState<GenerateInvoicesScreen> {
  DateTime _selectedMonth = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 10));

  Future<void> _generate() async {
    final count = await ref.read(invoiceGenerationControllerProvider.notifier).generateForMonth(
      month: _selectedMonth.month,
      year: _selectedMonth.year,
      dueDate: _dueDate,
    );

    if (count != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count invoices generate ho gayi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(invoiceGenerationControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Generate Monthly Invoices')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Ye har active student ke liye is mahine ki monthly fees generate karega, jo active fee structures par based hai. Pehle se generated invoices dubara nahi banengi.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              tileColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text('Billing Month: ${DateFormat('MMMM yyyy').format(_selectedMonth)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedMonth,
                  firstDate: DateTime.now().subtract(const Duration(days: 60)),
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                );
                if (picked != null) setState(() => _selectedMonth = picked);
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              tileColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text('Due Date: ${DateFormat('dd MMM yyyy').format(_dueDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                );
                if (picked != null) setState(() => _dueDate = picked);
              },
            ),
            const SizedBox(height: 24),
            AppButton(label: 'Generate Invoices', onPressed: _generate, isLoading: state.isLoading),
          ],
        ),
      ),
    );
  }
}
