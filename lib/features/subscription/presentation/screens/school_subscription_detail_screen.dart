import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/subscription_entity.dart';
import '../providers/subscription_provider.dart';
import '../widgets/subscription_status_badge.dart';
import 'package:go_router/go_router.dart';
class SchoolSubscriptionDetailScreen extends ConsumerWidget {
  final SchoolSubscriptionEntity subscription;
  const SchoolSubscriptionDetailScreen({super.key, required this.subscription});

  void _showRecordPaymentDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController(text: subscription.planPrice?.toStringAsFixed(0) ?? '');
    final refController = TextEditingController();
    String method = 'manual';
    final extendController = TextEditingController(text: '30');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Record Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Method'),
                value: method,
                items: const [
                  DropdownMenuItem(value: 'manual', child: Text('Manual')),
                  DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
                  DropdownMenuItem(value: 'online', child: Text('Online')),
                  DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                ],
                onChanged: (value) => setDialogState(() => method = value!),
              ),
              const SizedBox(height: 10),
              TextField(controller: refController, decoration: const InputDecoration(labelText: 'Reference Number (optional)')),
              const SizedBox(height: 10),
              TextField(controller: extendController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Extend Subscription By (days)')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text.trim());
                if (amount == null) return;
                await ref.read(subscriptionManagementControllerProvider.notifier).recordPayment(
                  schoolSubscriptionId: subscription.id,
                  schoolId: subscription.schoolId,
                  amount: amount,
                  paymentMethod: method,
                  referenceNumber: refController.text.trim().isEmpty ? null : refController.text.trim(),
                  extendDays: int.tryParse(extendController.text.trim()) ?? 30,
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Record'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignPlanDialog(BuildContext context, WidgetRef ref) {
    String? selectedPlanId;
    final durationController = TextEditingController(text: '30');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final plansAsync = ref.watch(subscriptionPlansProvider);
          return AlertDialog(
            title: const Text('Assign / Change Plan'),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  plansAsync.when(
                    data: (plans) => DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Plan'),
                      items: plans.map((p) => DropdownMenuItem(value: p.id, child: Text('${p.name} - Rs.${p.price.toStringAsFixed(0)}'))).toList(),
                      onChanged: (value) => setDialogState(() => selectedPlanId = value),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Error'),
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: durationController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Duration (days)')),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () async {
                  if (selectedPlanId == null) return;
                  await ref.read(subscriptionManagementControllerProvider.notifier).assignPlan(
                    schoolId: subscription.schoolId,
                    planId: selectedPlanId!,
                    durationDays: int.tryParse(durationController.text.trim()) ?? 30,
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Assign'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(subscription.schoolName)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(subscription.planName ?? 'No Plan', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      SubscriptionStatusBadge(status: subscription.status),
                    ],
                  ),
                  const Divider(height: 24),
                  _row('Start Date', DateFormat('dd MMM yyyy').format(subscription.startDate)),
                  _row('Expiry Date', DateFormat('dd MMM yyyy').format(subscription.expiryDate)),
                  _row('Days Remaining', '${subscription.daysRemaining}'),
                  if (subscription.planPrice != null) _row('Price', 'Rs. ${subscription.planPrice!.toStringAsFixed(0)}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppButton(label: 'Record Payment / Renew', onPressed: () => _showRecordPaymentDialog(context, ref)),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: () => _showAssignPlanDialog(context, ref), child: const Text('Assign / Change Plan')),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.block, color: Colors.red),
                  label: const Text('Block School', style: TextStyle(color: Colors.red)),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Block School'),
                        content: const Text('Ye school ke sab users ko access se rok dega. Confirm karein?'),
                        actions: [
                          TextButton(onPressed: () => context.pop(false), child: const Text('Cancel')),
                          TextButton(onPressed: () => context.pop(true), child: const Text('Block')),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await ref.read(subscriptionManagementControllerProvider.notifier).toggleBlock(subscription.schoolId, true);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                  label: const Text('Unblock', style: TextStyle(color: Colors.green)),
                  onPressed: () => ref.read(subscriptionManagementControllerProvider.notifier).toggleBlock(subscription.schoolId, false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}