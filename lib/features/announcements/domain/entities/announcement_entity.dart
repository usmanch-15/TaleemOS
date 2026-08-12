import 'package:equatable/equatable.dart';

enum TargetAudience { all, admins, teachers, parents, students, classSpecific }

extension TargetAudienceX on TargetAudience {
  String toDbString() {
    switch (this) {
      case TargetAudience.all:
        return 'all';
      case TargetAudience.admins:
        return 'admins';
      case TargetAudience.teachers:
        return 'teachers';
      case TargetAudience.parents:
        return 'parents';
      case TargetAudience.students:
        return 'students';
      case TargetAudience.classSpecific:
        return 'class';
    }
  }

  static TargetAudience fromString(String value) {
    switch (value) {
      case 'admins':
        return TargetAudience.admins;
      case 'teachers':
        return TargetAudience.teachers;
      case 'parents':
        return TargetAudience.parents;
      case 'students':
        return TargetAudience.students;
      case 'class':
        return TargetAudience.classSpecific;
      default:
        return TargetAudience.all;
    }
  }

  String get label {
    switch (this) {
      case TargetAudience.all:
        return 'Everyone';
      case TargetAudience.admins:
        return 'Admins Only';
      case TargetAudience.teachers:
        return 'Teachers Only';
      case TargetAudience.parents:
        return 'Parents Only';
      case TargetAudience.students:
        return 'Students Only';
      case TargetAudience.classSpecific:
        return 'Specific Class';
    }
  }
}

class AnnouncementEntity extends Equatable {
  final String id;
  final String schoolId;
  final String createdBy;
  final String createdByName;
  final String title;
  final String message;
  final TargetAudience targetAudience;
  final String? classId;
  final String? className;
  final String? sectionId;
  final String? attachmentUrl;
  final String? attachmentName;
  final bool isPinned;
  final DateTime createdAt;
  final bool isRead;

  const AnnouncementEntity({
    required this.id,
    required this.schoolId,
    required this.createdBy,
    required this.createdByName,
    required this.title,
    required this.message,
    required this.targetAudience,
    this.classId,
    this.className,
    this.sectionId,
    this.attachmentUrl,
    this.attachmentName,
    required this.isPinned,
    required this.createdAt,
    this.isRead = false,
  });

  @override
  List<Object?> get props => [id, schoolId, title, message, targetAudience, createdAt, isRead];
}