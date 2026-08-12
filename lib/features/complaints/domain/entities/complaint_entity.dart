import 'package:equatable/equatable.dart';

enum ComplaintCategory { academic, behavioral, facility, fee, transport, other }

extension ComplaintCategoryX on ComplaintCategory {
  String toDbString() => name;

  static ComplaintCategory fromString(String value) {
    return ComplaintCategory.values.firstWhere((e) => e.name == value, orElse: () => ComplaintCategory.other);
  }

  String get label {
    switch (this) {
      case ComplaintCategory.academic:
        return 'Academic';
      case ComplaintCategory.behavioral:
        return 'Behavioral';
      case ComplaintCategory.facility:
        return 'Facility';
      case ComplaintCategory.fee:
        return 'Fee';
      case ComplaintCategory.transport:
        return 'Transport';
      case ComplaintCategory.other:
        return 'Other';
    }
  }
}

enum ComplaintStatus { open, inProgress, resolved, closed }

extension ComplaintStatusX on ComplaintStatus {
  String toDbString() {
    switch (this) {
      case ComplaintStatus.open:
        return 'open';
      case ComplaintStatus.inProgress:
        return 'in_progress';
      case ComplaintStatus.resolved:
        return 'resolved';
      case ComplaintStatus.closed:
        return 'closed';
    }
  }

  static ComplaintStatus fromString(String value) {
    switch (value) {
      case 'in_progress':
        return ComplaintStatus.inProgress;
      case 'resolved':
        return ComplaintStatus.resolved;
      case 'closed':
        return ComplaintStatus.closed;
      default:
        return ComplaintStatus.open;
    }
  }

  String get label {
    switch (this) {
      case ComplaintStatus.open:
        return 'Open';
      case ComplaintStatus.inProgress:
        return 'In Progress';
      case ComplaintStatus.resolved:
        return 'Resolved';
      case ComplaintStatus.closed:
        return 'Closed';
    }
  }
}

enum ComplaintPriority { low, normal, high, urgent }

extension ComplaintPriorityX on ComplaintPriority {
  String toDbString() => name;

  static ComplaintPriority fromString(String value) {
    return ComplaintPriority.values.firstWhere((e) => e.name == value, orElse: () => ComplaintPriority.normal);
  }

  String get label {
    switch (this) {
      case ComplaintPriority.low:
        return 'Low';
      case ComplaintPriority.normal:
        return 'Normal';
      case ComplaintPriority.high:
        return 'High';
      case ComplaintPriority.urgent:
        return 'Urgent';
    }
  }
}

class ComplaintResponseEntity extends Equatable {
  final String id;
  final String complaintId;
  final String respondedBy;
  final String responderName;
  final String message;
  final DateTime createdAt;

  const ComplaintResponseEntity({
    required this.id,
    required this.complaintId,
    required this.respondedBy,
    required this.responderName,
    required this.message,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, complaintId, message, createdAt];
}

class ComplaintEntity extends Equatable {
  final String id;
  final String schoolId;
  final String raisedBy;
  final String raisedByName;
  final String? studentId;
  final String? studentName;
  final ComplaintCategory category;
  final String subject;
  final String description;
  final ComplaintStatus status;
  final ComplaintPriority priority;
  final String? assignedTo;
  final String? assignedToName;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const ComplaintEntity({
    required this.id,
    required this.schoolId,
    required this.raisedBy,
    required this.raisedByName,
    this.studentId,
    this.studentName,
    required this.category,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    this.assignedTo,
    this.assignedToName,
    required this.createdAt,
    this.resolvedAt,
  });

  @override
  List<Object?> get props => [id, schoolId, subject, status, priority, createdAt];
}