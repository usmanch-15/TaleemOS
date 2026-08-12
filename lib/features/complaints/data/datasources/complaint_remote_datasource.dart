

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/complaint_model.dart';

class ComplaintRemoteDatasource {
  final SupabaseClient client;
  ComplaintRemoteDatasource(this.client);

  static const _selectQuery =
      '*, raised_by_user:users!complaints_raised_by_fkey(name), students(full_name), assigned_to_user:users!complaints_assigned_to_fkey(name)';

  Future<ComplaintModel> createComplaint(ComplaintModel complaint) async {
    final data = await client.from('complaints').insert(complaint.toInsertMap()).select(_selectQuery).single();
    return ComplaintModel.fromMap(data);
  }

  Future<List<ComplaintModel>> getMyComplaints(String userId) async {
    final data = await client
        .from('complaints')
        .select(_selectQuery)
        .eq('raised_by', userId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => ComplaintModel.fromMap(e)).toList();
  }

  Future<List<ComplaintModel>> getSchoolComplaints({
    required String schoolId,
    String? statusFilter,
  }) async {
    var query = client.from('complaints').select(_selectQuery).eq('school_id', schoolId);
    if (statusFilter != null) query = query.eq('status', statusFilter);
    final data = await query.order('created_at', ascending: false);
    return (data as List).map((e) => ComplaintModel.fromMap(e)).toList();
  }

  Future<ComplaintModel> getComplaintById(String complaintId) async {
    final data = await client.from('complaints').select(_selectQuery).eq('id', complaintId).single();
    return ComplaintModel.fromMap(data);
  }

  Future<void> updateStatus(String complaintId, String status) async {
    await client.from('complaints').update({'status': status}).eq('id', complaintId);
  }

  Future<void> assignTo(String complaintId, String userId) async {
    await client.from('complaints').update({'assigned_to': userId, 'status': 'in_progress'}).eq('id', complaintId);
  }

  Future<List<ComplaintResponseModel>> getResponses(String complaintId) async {
    final data = await client
        .from('complaint_responses')
        .select('*, users(name)')
        .eq('complaint_id', complaintId)
        .order('created_at');
    return (data as List).map((e) => ComplaintResponseModel.fromMap(e)).toList();
  }

  Future<void> addResponse({
    required String complaintId,
    required String respondedBy,
    required String message,
  }) async {
    await client.from('complaint_responses').insert({
      'complaint_id': complaintId,
      'responded_by': respondedBy,
      'message': message,
    });
  }
}