import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/homework_entity.dart';
import 'homework_status_badge.dart';

class HomeworkCard extends StatelessWidget {
  final HomeworkEntity homework;
  final VoidCallback onTap;
  final Widget? trailing;

  const HomeworkCard({super.key, required this.homework, required this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
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
                  Expanded(
                    child: Text(homework.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  HomeworkStatusBadge(status: homework.status, isOverdue: homework.isOverdue),
                ],
              ),
              const SizedBox(height: 6),
              Text('${homework.subjectName} • ${homework.className}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text('Due: ${DateFormat('dd MMM yyyy').format(homework.dueDate)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  if (homework.attachmentUrl != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.attach_file, size: 14, color: Colors.grey.shade500),
                  ],
                  const Spacer(),
                  if (trailing != null) trailing!,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}