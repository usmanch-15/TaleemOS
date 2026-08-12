import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/announcement_entity.dart';
import '../providers/announcement_provider.dart';

class AnnouncementDetailScreen extends ConsumerWidget {
  final AnnouncementEntity announcement;
  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authControllerProvider).user?.id;
    final canManage = userId == announcement.createdBy;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement'),
        actions: canManage
            ? [
          IconButton(
            icon: Icon(announcement.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: () =>
                ref.read(announcementControllerProvider.notifier).togglePin(announcement.id, !announcement.isPinned),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Announcement'),
                  content: const Text('Kya aap confirm hain?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref.read(announcementControllerProvider.notifier).delete(announcement.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ]
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(announcement.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(radius: 14, child: Text(announcement.createdByName.isNotEmpty ? announcement.createdByName[0] : '?')),
              const SizedBox(width: 8),
              Text(announcement.createdByName, style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Text(DateFormat('dd MMM yyyy, hh:mm a').format(announcement.createdAt),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ],
          ),
          const Divider(height: 32),
          Text(announcement.message, style: const TextStyle(fontSize: 15, height: 1.5)),
          if (announcement.attachmentUrl != null) ...[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: Text(announcement.attachmentName ?? 'Attachment'),
              onPressed: () {}, // launch url_launcher package if download needed
            ),
          ],
        ],
      ),
    );
  }
}