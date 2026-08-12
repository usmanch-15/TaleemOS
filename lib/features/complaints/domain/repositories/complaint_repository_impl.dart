import '../../domain/entities/complaint_entity.dart';
import '../../domain/repositories/complaint_repository.dart';
import '../datasources/complaint_remote_datasource.dart';
import '../models/complaint_model.dart';

class ComplaintRepositoryImpl implements ComplaintRepository {
  final ComplaintRemoteDatasource remote;
  ComplaintRepositoryImpl(this.remote);

  @override
  Future<ComplaintEntity> createComplaint(ComplaintEntity complaint) {
    final model = ComplaintModel(
      id: complaint.id,
      schoolId: complaint.schoolId,
      raisedBy: complaint.raisedBy,
      raisedByName: complaint.raisedByName,
      studentId: complaint.studentId,
      category: complaint.category,
      subject: complaint.subject,
      description: complaint.description,
      status: complaint.status,
      priority: complaint.priority,
      createdAt: complaint.createdAt,
    );
    return remote.createComplaint(model);
  }

  @override
  Future<List<ComplaintEntity>> getMyComplaints(String userId) => remote.getMyComplaints(userId);

  @override
  Future<List<ComplaintEntity>> getSchoolComplaints({required String schoolId, String? statusFilter}) {
    return remote.getSchoolComplaints(schoolId: schoolId, statusFilter: statusFilter);
  }

  @override
  Future<ComplaintEntity> getComplaintById(String complaintId) => remote.getComplaintById(complaintId);

  @override
  Future<void> updateStatus(String complaintId, String status) => remote.updateStatus(complaintId, status);

  @override
  Future<void> assignTo(String complaintId, String userId) => remote.assignTo(complaintId, userId);

  @override
  Future<List<ComplaintResponseEntity>> getResponses(String complaintId) => remote.getResponses(complaintId);

  @override
  Future<void> addResponse({required String complaintId, required String respondedBy, required String message}) {
    return remote.addResponse(complaintId: complaintId, respondedBy: respondedBy, message: message);
  }
}