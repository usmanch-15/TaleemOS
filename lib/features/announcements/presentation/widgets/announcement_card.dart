import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../domain/entities/announcement_entity.dart';

class AnnouncementCard extends StatelessWidget {
  final AnnouncementEntity announcement;
  final VoidCallback onTap;

  const AnnouncementCard({super.key, required this.announcement, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: announcement.isRead ? Colors.grey.shade200 : Colors.indigo.shade100, width: announcement.isRead ? 1 : 1.5),
      ),
      color: announcement.isRead ? null : Colors.indigo.shade50.withOpacity(0.4),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (announcement.isPinned) ...[
                    Icon(Icons.push_pin, size: 14, color: Colors.orange.shade700),
                    const SizedBox(width: 4),
                  ],
                  if (!announcement.isRead) ...[
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.indigo, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      announcement.title,
                      style: TextStyle(fontSize: 15, fontWeight: announcement.isRead ? FontWeight.w500 : FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                announcement.message,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(announcement.createdByName, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  const SizedBox(width: 8),
                  Text('•', style: TextStyle(color: Colors.grey.shade400)),
                  const SizedBox(width: 8),
                  Text(timeago.format(announcement.createdAt), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  if (announcement.attachmentUrl != null) ...[
                    const Spacer(),
                    Icon(Icons.attach_file, size: 14, color: Colors.grey.shade500),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}