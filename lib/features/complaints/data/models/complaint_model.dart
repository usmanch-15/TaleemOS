import '../../domain/entities/complaint_entity.dart';

class ComplaintResponseModel extends ComplaintResponseEntity {
  const ComplaintResponseModel({
    required super.id,
    required super.complaintId,
    required super.respondedBy,
    required super.responderName,
    required super.message,
    required super.createdAt,
  });

  factory ComplaintResponseModel.fromMap(Map<String, dynamic> map) {
    final responder = map['users'] as Map<String, dynamic>?;
    return ComplaintResponseModel(
      id: map['id'] as String,
      complaintId: map['complaint_id'] as String,
      respondedBy: map['responded_by'] as String,
      responderName: responder?['name'] as String? ?? '',
      message: map['message'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class ComplaintModel extends ComplaintEntity {
  const ComplaintModel({
    required super.id,
    required super.schoolId,
    required super.raisedBy,
    required super.raisedByName,
    super.studentId,
    super.studentName,
    required super.category,
    required super.subject,
    required super.description,
    required super.status,
    required super.priority,
    super.assignedTo,
    super.assignedToName,
    required super.createdAt,
    super.resolvedAt,
  });

  factory ComplaintModel.fromMap(Map<String, dynamic> map) {
    final raiser = map['raised_by_user'] as Map<String, dynamic>?;
    final student = map['students'] as Map<String, dynamic>?;
    final assignee = map['assigned_to_user'] as Map<String, dynamic>?;

    return ComplaintModel(
      id: map['id'] as String,
      schoolId: map['school_id'] as String,
      raisedBy: map['raised_by'] as String,
      raisedByName: raiser?['name'] as String? ?? '',
      studentId: map['student_id'] as String?,
      studentName: student?['full_name'] as String?,
      category: ComplaintCategoryX.fromString(map['category'] as String),
      subject: map['subject'] as String,
      description: map['description'] as String,
      status: ComplaintStatusX.fromString(map['status'] as String),
      priority: ComplaintPriorityX.fromString(map['priority'] as String),
      assignedTo: map['assigned_to'] as String?,
      assignedToName: assignee?['name'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      resolvedAt: map['resolved_at'] != null ? DateTime.parse(map['resolved_at'] as String) : null,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'school_id': schoolId,
      'raised_by': raisedBy,
      'student_id': studentId,
      'category': category.toDbString(),
      'subject': subject,
      'description': description,
      'priority': priority.toDbString(),
    };
  }
}