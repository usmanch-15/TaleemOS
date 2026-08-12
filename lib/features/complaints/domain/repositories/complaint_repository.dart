import '../entities/complaint_entity.dart';

abstract class ComplaintRepository {
  Future<ComplaintEntity> createComplaint(ComplaintEntity complaint);
  Future<List<ComplaintEntity>> getMyComplaints(String userId);
  Future<List<ComplaintEntity>> getSchoolComplaints({required String schoolId, String? statusFilter});
  Future<ComplaintEntity> getComplaintById(String complaintId);
  Future<void> updateStatus(String complaintId, String status);
  Future<void> assignTo(String complaintId, String userId);
  Future<List<ComplaintResponseEntity>> getResponses(String complaintId);
  Future<void> addResponse({required String complaintId, required String respondedBy, required String message});
}

