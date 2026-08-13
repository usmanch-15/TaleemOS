import 'package:equatable/equatable.dart';

class TimetableEntryEntity extends Equatable {
  final String id;
  final String schoolId;
  final String classId;
  final String? sectionId;
  final String subjectId;
  final String subjectName;
  final String? teacherId;
  final String? teacherName;
  final int dayOfWeek; // 1 = Monday ... 7 = Sunday
  final String startTime; // "08:00"
  final String endTime; // "08:45"
  final String? roomNumber;

  const TimetableEntryEntity({
    required this.id,
    required this.schoolId,
    required this.classId,
    this.sectionId,
    required this.subjectId,
    required this.subjectName,
    this.teacherId,
    this.teacherName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.roomNumber,
  });

  static const dayNames = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };

  String get dayName => dayNames[dayOfWeek] ?? '';

  @override
  List<Object?> get props => [id, schoolId, classId, sectionId, subjectId, teacherId, dayOfWeek, startTime, endTime];
}