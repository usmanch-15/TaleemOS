import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/subscription_provider.dart';
import '../widgets/subscription_status_badge.dart';

class SchoolsSubscriptionScreen extends ConsumerWidget {
  const SchoolsSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subsAsync = ref.watch(allSchoolSubscriptionsProvider);
    final overviewAsync = ref.watch(subscriptionOverviewProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('School Subscriptions')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allSchoolSubscriptionsProvider);
          ref.invalidate(subscriptionOverviewProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            overviewAsync.when(
              data: (overview) => GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _statBox('Active', '${overview.activeCount}', Colors.green),
                  _statBox('Expiring Soon', '${overview.expiringSoonCount}', Colors.orange),
                  _statBox('Expired', '${overview.expiredCount}', Colors.red),
                  _statBox('MRR', 'Rs. ${overview.mrr.toStringAsFixed(0)}', Colors.indigo),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 20),
            const Text('Schools', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            subsAsync.when(
              data: (subs) {
                if (subs.isEmpty) return const Text('Koi subscription nahi hai');
                return Column(
                  children: subs.map((s) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(s.schoolName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          '${s.planName ?? "No plan"} • Expires: ${DateFormat('dd MMM yyyy').format(s.expiryDate)}',
                        ),
                        trailing: SubscriptionStatusBadge(status: s.status),
                        onTap: () => context.push('/subscription/schools/${s.schoolId}', extra: s),
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
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}