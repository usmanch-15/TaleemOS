import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../school/presentation/providers/school_provider.dart';
import '../../data/services/receipt_pdf_service.dart';
import '../providers/fee_provider.dart';
import '../widgets/invoice_status_badge.dart';

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final String invoiceId;
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  void _showPaymentDialog(double maxAmount, String studentId) {
    final amountController = TextEditingController(text: maxAmount.toStringAsFixed(0));
    String paymentMethod = 'cash';
    final referenceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Record Payment'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Amount (Balance: Rs. ${maxAmount.toStringAsFixed(0)})'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Payment Method'),
                  value: paymentMethod,
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
                    DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                    DropdownMenuItem(value: 'online', child: Text('Online')),
                  ],
                  onChanged: (value) => setDialogState(() => paymentMethod = value!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: referenceController,
                  decoration: const InputDecoration(labelText: 'Reference Number (optional)'),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text.trim());
                  if (amount == null || amount <= 0) return;

                  final payment = await ref.read(paymentControllerProvider.notifier).recordPayment(
                    invoiceId: widget.invoiceId,
                    studentId: studentId,
                    amount: amount,
                    paymentMethod: paymentMethod,
                    referenceNumber: referenceController.text.trim().isEmpty ? null : referenceController.text.trim(),
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    if (payment != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Payment record ho gaya — Receipt: ${payment.receiptNumber}')),
                      );
                    }
                  }
                },
                child: const Text('Record Payment'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _shareReceipt(dynamic invoice, dynamic payment) async {
    final school = ref.read(currentSchoolProvider).value;
    if (school == null) return;

    final file = await ReceiptPdfService.instance.generateReceipt(
      schoolName: school.name,
      studentName: invoice.studentName,
      studentCode: invoice.studentId,
      receiptNumber: payment.receiptNumber,
      feeTitle: invoice.title,
      amountPaid: payment.amount,
      totalPayable: invoice.totalPayable,
      balance: invoice.balance,
      paymentMethod: payment.paymentMethod,
      paymentDate: payment.paymentDate,
    );

    await Printing.sharePdf(bytes: await file.readAsBytes(), filename: 'receipt_${payment.receiptNumber}.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final invoiceAsync = ref.watch(invoiceDetailProvider(widget.invoiceId));
    final paymentsAsync = ref.watch(invoicePaymentsProvider(widget.invoiceId));

    return Scaffold(
      appBar: AppBar(title: const Text('Invoice Detail')),
      body: invoiceAsync.when(
        data: (invoice) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(child: Text(invoice.studentName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                InvoiceStatusBadge(status: invoice.status),
              ],
            ),
            Text(invoice.title, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row('Amount', 'Rs. ${invoice.amount.toStringAsFixed(0)}'),
                    if (invoice.discount > 0) _row('Discount', '- Rs. ${invoice.discount.toStringAsFixed(0)}'),
                    if (invoice.fine > 0) _row('Fine', '+ Rs. ${invoice.fine.toStringAsFixed(0)}'),
                    const Divider(),
                    _row('Total Payable', 'Rs. ${invoice.totalPayable.toStringAsFixed(0)}', bold: true),
                    _row('Amount Paid', 'Rs. ${invoice.amountPaid.toStringAsFixed(0)}'),
                    _row('Balance', 'Rs. ${invoice.balance.toStringAsFixed(0)}', color: invoice.balance > 0 ? Colors.red : Colors.green),
                    _row('Due Date', DateFormat('dd MMM yyyy').format(invoice.dueDate)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (invoice.balance > 0)
              AppButton(
                label: 'Record Payment',
                onPressed: () => _showPaymentDialog(invoice.balance, invoice.studentId),
              ),
            const SizedBox(height: 20),
            const Text('Payment History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            paymentsAsync.when(
              data: (payments) {
                if (payments.isEmpty) return const Text('Koi payment record nahi hui abhi tak');
                return Column(
                  children: payments.map((p) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text('Rs. ${p.amount.toStringAsFixed(0)} — ${p.receiptNumber}'),
                        subtitle: Text('${p.paymentMethod} • ${DateFormat('dd MMM yyyy').format(p.paymentDate)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          onPressed: () => _shareReceipt(invoice, p),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: color)),
        ],
      ),
    );
  }
}