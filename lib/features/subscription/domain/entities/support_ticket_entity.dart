import 'package:equatable/equatable.dart';

enum TicketCategory { billing, technical, featureRequest, bug, general }

extension TicketCategoryX on TicketCategory {
  String toDbString() {
    switch (this) {
      case TicketCategory.billing:
        return 'billing';
      case TicketCategory.technical:
        return 'technical';
      case TicketCategory.featureRequest:
        return 'feature_request';
      case TicketCategory.bug:
        return 'bug';
      case TicketCategory.general:
        return 'general';
    }
  }

  static TicketCategory fromString(String value) {
    switch (value) {
      case 'billing':
        return TicketCategory.billing;
      case 'technical':
        return TicketCategory.technical;
      case 'feature_request':
        return TicketCategory.featureRequest;
      case 'bug':
        return TicketCategory.bug;
      default:
        return TicketCategory.general;
    }
  }

  String get label {
    switch (this) {
      case TicketCategory.billing:
        return 'Billing';
      case TicketCategory.technical:
        return 'Technical';
      case TicketCategory.featureRequest:
        return 'Feature Request';
      case TicketCategory.bug:
        return 'Bug Report';
      case TicketCategory.general:
        return 'General';
    }
  }
}

enum TicketStatus { open, inProgress, resolved, closed }

extension TicketStatusX on TicketStatus {
  String toDbString() {
    switch (this) {
      case TicketStatus.open:
        return 'open';
      case TicketStatus.inProgress:
        return 'in_progress';
      case TicketStatus.resolved:
        return 'resolved';
      case TicketStatus.closed:
        return 'closed';
    }
  }

  static TicketStatus fromString(String value) {
    switch (value) {
      case 'in_progress':
        return TicketStatus.inProgress;
      case 'resolved':
        return TicketStatus.resolved;
      case 'closed':
        return TicketStatus.closed;
      default:
        return TicketStatus.open;
    }
  }

  String get label {
    switch (this) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
    }
  }
}

class TicketResponseEntity extends Equatable {
  final String id;
  final String ticketId;
  final String respondedBy;
  final String responderName;
  final String message;
  final bool isInternalNote;
  final DateTime createdAt;

  const TicketResponseEntity({
    required this.id,
    required this.ticketId,
    required this.respondedBy,
    required this.responderName,
    required this.message,
    required this.isInternalNote,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, ticketId, message, createdAt];
}

class SupportTicketEntity extends Equatable {
  final String id;
  final String schoolId;
  final String schoolName;
  final String raisedBy;
  final String raisedByName;
  final String subject;
  final String description;
  final TicketCategory category;
  final String priority;
  final TicketStatus status;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const SupportTicketEntity({
    required this.id,
    required this.schoolId,
    required this.schoolName,
    required this.raisedBy,
    required this.raisedByName,
    required this.subject,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.assignedTo,
    required this.createdAt,
    this.resolvedAt,
  });

  @override
  List<Object?> get props => [id, schoolId, subject, status, createdAt];
}