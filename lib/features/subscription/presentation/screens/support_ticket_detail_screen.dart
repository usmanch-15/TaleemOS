import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/subscription_provider.dart';

class SupportTicketDetailScreen extends ConsumerStatefulWidget {
  final String ticketId;
  const SupportTicketDetailScreen({super.key, required this.ticketId});

  @override
  ConsumerState<SupportTicketDetailScreen> createState() => _SupportTicketDetailScreenState();
}

class _SupportTicketDetailScreenState extends ConsumerState<SupportTicketDetailScreen> {
  final _responseController = TextEditingController();
  bool _isInternalNote = false;

  Future<void> _send() async {
    if (_responseController.text.trim().isEmpty) return;
    final success = await ref.read(supportTicketControllerProvider.notifier).addResponse(
      ticketId: widget.ticketId,
      message: _responseController.text.trim(),
      isInternal: _isInternalNote,
    );
    if (success) _responseController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final ticketAsync = ref.watch(ticketDetailProvider(widget.ticketId));
    final responsesAsync = ref.watch(ticketResponsesProvider(widget.ticketId));
    final isSuperAdmin = ref.watch(authControllerProvider).user?.role.toDbString() == 'super_admin';

    return Scaffold(
      appBar: AppBar(title: const Text('Support Ticket')),
      body: ticketAsync.when(
        data: (ticket) => Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(ticket['subject'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(DateFormat('dd MMM yyyy').format(DateTime.parse(ticket['created_at'] as String)), style: TextStyle(color: Colors.grey.shade600)),
                  const Divider(height: 24),
                  Text(ticket['description'] as String),
                  if (isSuperAdmin) ...[
                    const SizedBox(height: 20),
                    const Text('Update Status', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['open', 'in_progress', 'resolved', 'closed'].map((s) {
                        return ChoiceChip(
                          label: Text(s.replaceAll('_', ' ')),
                          selected: ticket['status'] == s,
                          onSelected: (_) => ref.read(supportTicketControllerProvider.notifier).updateStatus(widget.ticketId, s),
                        );
                      }).toList(),
                    ),
                  ],
                  const Divider(height: 32),
                  const Text('Conversation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  responsesAsync.when(
                    data: (responses) {
                      if (responses.isEmpty) return const Text('Abhi tak koi response nahi');
                      return Column(
                        children: responses.map((r) {
                          final user = r['users'] as Map<String, dynamic>?;
                          final isInternal = r['is_internal_note'] as bool? ?? false;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isInternal ? Colors.amber.shade50 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(user?['name'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    if (isInternal) ...[
                                      const SizedBox(width: 6),
                                      const Text('(Internal)', style: TextStyle(fontSize: 10, color: Colors.orange)),
                                    ],
                                    const Spacer(),
                                    Text(DateFormat('dd MMM, hh:mm a').format(DateTime.parse(r['created_at'] as String)), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(r['message'] as String),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text('Error: $e'),
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    if (isSuperAdmin)
                      Row(
                        children: [
                          Checkbox(value: _isInternalNote, onChanged: (v) => setState(() => _isInternalNote = v ?? false)),
                          const Text('Internal note (school ko nazar nahi aayega)', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    Row(
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
                        IconButton(icon: const Icon(Icons.send), onPressed: _send),
                      ],
                    ),
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