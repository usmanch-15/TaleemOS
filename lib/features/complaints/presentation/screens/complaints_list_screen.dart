import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/complaint_entity.dart';
import '../providers/complaint_provider.dart';
import '../widgets/complaint_status_badge.dart';

class ComplaintsListScreen extends ConsumerWidget {
  const ComplaintsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(authControllerProvider).user?.role.toDbString() == 'admin';
    final complaintsAsync = isAdmin ? ref.watch(schoolComplaintsProvider) : ref.watch(myComplaintsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(isAdmin ? 'All Complaints' : 'My Complaints')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/complaints/create'),
        icon: const Icon(Icons.add),
        label: const Text('Raise Complaint'),
      ),
      body: Column(
        children: [
          if (isAdmin)
            Consumer(
              builder: (context, ref, _) {
                final filter = ref.watch(schoolComplaintsFilterProvider);
                return SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    children: [
                      _chip('All', filter == null, () => ref.read(schoolComplaintsFilterProvider.notifier).state = null),
                      _chip('Open', filter == 'open', () => ref.read(schoolComplaintsFilterProvider.notifier).state = 'open'),
                      _chip('In Progress', filter == 'in_progress',
                              () => ref.read(schoolComplaintsFilterProvider.notifier).state = 'in_progress'),
                      _chip('Resolved', filter == 'resolved',
                              () => ref.read(schoolComplaintsFilterProvider.notifier).state = 'resolved'),
                    ],
                  ),
                );
              },
            ),
          Expanded(
            child: complaintsAsync.when(
              data: (complaints) {
                if (complaints.isEmpty) return const Center(child: Text('Koi complaint nahi hai'));
                return ListView.builder(
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    final c = complaints[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        title: Text(c.subject, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${c.category.label} • ${DateFormat('dd MMM').format(c.createdAt)}'),
                            const SizedBox(height: 4),
                            ComplaintPriorityBadge(priority: c.priority),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: ComplaintStatusBadge(status: c.status),
                        onTap: () => context.push('/complaints/${c.id}'),
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
}