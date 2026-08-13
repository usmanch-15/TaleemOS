import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../domain/entities/notification_entity.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _iconFor(IconIdentifier type) {
    switch (type) {
      case IconIdentifier.attendance:
        return Icons.event_busy_outlined;
      case IconIdentifier.fee:
        return Icons.receipt_long_outlined;
      case IconIdentifier.transport:
        return Icons.directions_bus_outlined;
      case IconIdentifier.general:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => ref.read(notificationControllerProvider.notifier).markAllAsRead(),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(notificationsListProvider),
        child: notificationsAsync.when(
          data: (list) {
            if (list.isEmpty) {
              return ListView(children: const [SizedBox(height: 100), Center(child: Text('Koi notification nahi hai'))]);
            }
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final n = list[index];
                return ListTile(
                  tileColor: n.isRead ? null : Colors.indigo.shade50.withOpacity(0.4),
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade50,
                    child: Icon(_iconFor(n.iconType), color: Colors.indigo, size: 20),
                  ),
                  title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold)),
                  subtitle: Text(n.body ?? ''),
                  trailing: Text(timeago.format(n.createdAt), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  onTap: () => ref.read(notificationControllerProvider.notifier).markAsRead(n.id),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}