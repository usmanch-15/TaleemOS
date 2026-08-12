import '../../domain/entities/announcement_entity.dart';

class AnnouncementModel extends AnnouncementEntity {
  const AnnouncementModel({
    required super.id,
    required super.schoolId,
    required super.createdBy,
    required super.createdByName,
    required super.title,
    required super.message,
    required super.targetAudience,
    super.classId,
    super.className,
    super.sectionId,
    super.attachmentUrl,
    super.attachmentName,
    required super.isPinned,
    required super.createdAt,
    super.isRead,
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> map, {bool isRead = false}) {
    final creator = map['users'] as Map<String, dynamic>?;
    final classData = map['classes'] as Map<String, dynamic>?;

    return AnnouncementModel(
      id: map['id'] as String,
      schoolId: map['school_id'] as String,
      createdBy: map['created_by'] as String,
      createdByName: creator?['name'] as String? ?? '',
      title: map['title'] as String,
      message: map['message'] as String,
      targetAudience: TargetAudienceX.fromString(map['target_audience'] as String),
      classId: map['class_id'] as String?,
      className: classData?['name'] as String?,
      sectionId: map['section_id'] as String?,
      attachmentUrl: map['attachment_url'] as String?,
      attachmentName: map['attachment_name'] as String?,
      isPinned: map['is_pinned'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      isRead: isRead,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'school_id': schoolId,
      'created_by': createdBy,
      'title': title,
      'message': message,
      'target_audience': targetAudience.toDbString(),
      'class_id': classId,
      'section_id': sectionId,
      'attachment_url': attachmentUrl,
      'attachment_name': attachmentName,
      'is_pinned': isPinned,
    };
  }
}