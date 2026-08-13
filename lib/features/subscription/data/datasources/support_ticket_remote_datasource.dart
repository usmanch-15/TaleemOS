import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/support_ticket_entity.dart';

class SupportTicketRemoteDatasource {
  final SupabaseClient client;
  SupportTicketRemoteDatasource(this.client);

  static const _selectQuery = '*, schools(name), users!support_tickets_raised_by_fkey(name)';

  Future<Map<String, dynamic>> createTicket({
    required String schoolId,
    required String raisedBy,
    required String subject,
    required String description,
    required String category,
    required String priority,
  }) async {
    final data = await client
        .from('support_tickets')
        .insert({
      'school_id': schoolId,
      'raised_by': raisedBy,
      'subject': subject,
      'description': description,
      'category': category,
      'priority': priority,
    })
        .select(_selectQuery)
        .single();
    return data;
  }

  Future<List<Map<String, dynamic>>> getMyTickets(String userId) async {
    final data = await client
        .from('support_tickets')
        .select(_selectQuery)
        .eq('raised_by', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getAllTickets({String? statusFilter}) async {
    var query = client.from('support_tickets').select(_selectQuery);
    if (statusFilter != null) query = query.eq('status', statusFilter);
    final data = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> getTicketById(String ticketId) async {
    final data = await client.from('support_tickets').select(_selectQuery).eq('id', ticketId).single();
    return data;
  }

  Future<void> updateStatus(String ticketId, String status) async {
    await client.from('support_tickets').update({'status': status}).eq('id', ticketId);
  }

  Future<List<Map<String, dynamic>>> getResponses(String ticketId, {bool includeInternal = false}) async {
    var query = client.from('support_ticket_responses').select('*, users(name)').eq('ticket_id', ticketId);
    if (!includeInternal) query = query.eq('is_internal_note', false);
    final data = await query.order('created_at');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> addResponse({
    required String ticketId,
    required String respondedBy,
    required String message,
    bool isInternalNote = false,
  }) async {
    await client.from('support_ticket_responses').insert({
      'ticket_id': ticketId,
      'responded_by': respondedBy,
      'message': message,
      'is_internal_note': isInternalNote,
    });
  }
}