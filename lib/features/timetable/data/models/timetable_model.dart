import '../../domain/entities/timetable_entity.dart';

class TimetableEntryModel extends TimetableEntryEntity {
  const TimetableEntryModel({
    required super.id,
    required super.schoolId,
    required super.classId,
    super.sectionId,
    required super.subjectId,
    required super.subjectName,
    super.teacherId,
    super.teacherName,
    required super.dayOfWeek,
    required super.startTime,
    required super.endTime,
    super.roomNumber,
  });

  factory TimetableEntryModel.fromMap(Map<String, dynamic> map) {
    final subject = map['subjects'] as Map<String, dynamic>?;
    final teacher = map['teachers'] as Map<String, dynamic>?;
    final teacherUser = teacher?['users'] as Map<String, dynamic>?;

    return TimetableEntryModel(
      id: map['id'] as String,
      schoolId: map['school_id'] as String,
      classId: map['class_id'] as String,
      sectionId: map['section_id'] as String?,
      subjectId: map['subject_id'] as String,
      subjectName: subject?['name'] as String? ?? '',
      teacherId: map['teacher_id'] as String?,
      teacherName: teacherUser?['name'] as String?,
      dayOfWeek: map['day_of_week'] as int,
      startTime: (map['start_time'] as String).substring(0, 5),
      endTime: (map['end_time'] as String).substring(0, 5),
      roomNumber: map['room_number'] as String?,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'school_id': schoolId,
      'class_id': classId,
      'section_id': sectionId,
      'subject_id': subjectId,
      'teacher_id': teacherId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'room_number': roomNumber,
    };
  }
}