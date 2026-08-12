import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/complaint_entity.dart';
import '../providers/complaint_provider.dart';
import '../widgets/complaint_status_badge.dart';

class ComplaintDetailScreen extends ConsumerStatefulWidget {
  final String complaintId;
  const ComplaintDetailScreen({super.key, required this.complaintId});

  @override
  ConsumerState<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends ConsumerState<ComplaintDetailScreen> {
  final _responseController = TextEditingController();

  Future<void> _sendResponse() async {
    if (_responseController.text.trim().isEmpty) return;
    final success = await ref.read(complaintControllerProvider.notifier).addResponse(
      complaintId: widget.complaintId,
      message: _responseController.text.trim(),
    );
    if (success) _responseController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final complaintAsync = ref.watch(complaintDetailProvider(widget.complaintId));
    final responsesAsync = ref.watch(complaintResponsesProvider(widget.complaintId));
    final isAdmin = ref.watch(authControllerProvider).user?.role.toDbString() == 'admin';

    return Scaffold(
      appBar: AppBar(title: const Text('Complaint Detail')),
      body: complaintAsync.when(
        data: (complaint) => Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(complaint.subject, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                      ComplaintStatusBadge(status: complaint.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('${complaint.category.label} • ${DateFormat('dd MMM yyyy').format(complaint.createdAt)}',
                      style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  ComplaintPriorityBadge(priority: complaint.priority),
                  const Divider(height: 24),
                  Text(complaint.description),
                  if (isAdmin) ...[
                    const SizedBox(height: 20),
                    const Text('Update Status', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ComplaintStatus.values.map((s) {
                        return ChoiceChip(
                          label: Text(s.label),
                          selected: complaint.status == s,
                          onSelected: (_) =>
                              ref.read(complaintControllerProvider.notifier).updateStatus(complaint.id, s.toDbString()),
                        );
                      }).toList(),
                    ),
                  ],
                  const Divider(height: 32),
                  const Text('Responses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  responsesAsync.when(
                    data: (responses) {
                      if (responses.isEmpty) return const Text('Abhi tak koi response nahi aaya');
                      return Column(
                        children: responses.map((r) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(r.responderName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    const Spacer(),
                                    Text(DateFormat('dd MMM, hh:mm a').format(r.createdAt),
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(r.message),
                              ],
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
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _responseController,
                        decoration: InputDecoration(
                          hintText: 'Type a response...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.send), onPressed: _sendResponse),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}