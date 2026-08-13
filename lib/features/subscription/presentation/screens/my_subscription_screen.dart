import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/subscription_provider.dart';
import '../widgets/subscription_status_badge.dart';

class MySubscriptionScreen extends ConsumerWidget {
  const MySubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subAsync = ref.watch(mySchoolSubscriptionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Subscription')),
      body: subAsync.when(
        data: (sub) {
          if (sub == null) return const Center(child: Text('Koi subscription nahi mili, admin se rabta karein'));

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (sub.isExpiringSoon)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Aapki subscription ${sub.daysRemaining} din mein khatam ho rahi hai. Renew karne ke liye support se rabta karein.',
                          style: const TextStyle(fontSize: 12.5),
                        ),
                      ),
                    ],
                  ),
                ),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(sub.planName ?? 'No Plan', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          SubscriptionStatusBadge(status: sub.status),
                        ],
                      ),
                      const Divider(height: 28),
                      _row('Start Date', DateFormat('dd MMM yyyy').format(sub.startDate)),
                      _row('Expiry Date', DateFormat('dd MMM yyyy').format(sub.expiryDate)),
                      _row('Days Remaining', '${sub.daysRemaining}'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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