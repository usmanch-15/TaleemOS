import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/subscription_provider.dart';

class SupportTicketsListScreen extends ConsumerWidget {
  const SupportTicketsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSuperAdmin = ref.watch(authControllerProvider).user?.role.toDbString() == 'super_admin';
    final ticketsAsync = isSuperAdmin ? ref.watch(allTicketsProvider) : ref.watch(myTicketsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(isSuperAdmin ? 'All Support Tickets' : 'My Support Tickets')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/support/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Ticket'),
      ),
      body: Column(
        children: [
          if (isSuperAdmin)
            Consumer(
              builder: (context, ref, _) {
                final filter = ref.watch(ticketFilterProvider);
                return SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    children: [
                      _chip('All', filter == null, () => ref.read(ticketFilterProvider.notifier).state = null),
                      _chip('Open', filter == 'open', () => ref.read(ticketFilterProvider.notifier).state = 'open'),
                      _chip('In Progress', filter == 'in_progress', () => ref.read(ticketFilterProvider.notifier).state = 'in_progress'),
                      _chip('Resolved', filter == 'resolved', () => ref.read(ticketFilterProvider.notifier).state = 'resolved'),
                    ],
                  ),
                );
              },
            ),
          Expanded(
            child: ticketsAsync.when(
              data: (tickets) {
                if (tickets.isEmpty) return const Center(child: Text('Koi ticket nahi hai'));
                return ListView.builder(
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final t = tickets[index];
                    final school = t['schools'] as Map<String, dynamic>?;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        title: Text(t['subject'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          '${isSuperAdmin ? "${school?['name'] ?? ''} • " : ""}${DateFormat('dd MMM yyyy').format(DateTime.parse(t['created_at'] as String))}',
                        ),
                        trailing: _statusChip(t['status'] as String),
                        onTap: () => context.push('/support/${t['id']}'),
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

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap()),
    );
  }

  Widget _statusChip(String status) {
    final colors = {'open': Colors.orange, 'in_progress': Colors.blue, 'resolved': Colors.green, 'closed': Colors.grey};
    final color = colors[status] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(status.replaceAll('_', ' '), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}