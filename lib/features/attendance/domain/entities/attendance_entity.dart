import 'package:equatable/equatable.dart';

enum AttendanceStatus { present, absent, late, leave }

extension AttendanceStatusX on AttendanceStatus {
  String toDbString() {
    switch (this) {
      case AttendanceStatus.present:
        return 'present';
      case AttendanceStatus.absent:
        return 'absent';
      case AttendanceStatus.late:
        return 'late';
      case AttendanceStatus.leave:
        return 'leave';
    }
  }

  static AttendanceStatus fromString(String value) {
    switch (value) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'late':
        return AttendanceStatus.late;
      case 'leave':
        return AttendanceStatus.leave;
      default:
        return AttendanceStatus.absent;
    }
  }

  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.leave:
        return 'Leave';
    }
  }
}

class AttendanceEntity extends Equatable {
  final String id;
  final String schoolId;
  final String studentId;
  final String studentName;
  final String classId;
  final String? sectionId;
  final String? subjectId;
  final DateTime date;
  final AttendanceStatus status;
  final String? remarks;
  final String markedBy;
  final bool isLocked;
  final DateTime createdAt;

  const AttendanceEntity({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.studentName,
    required this.classId,
    this.sectionId,
    this.subjectId,
    required this.date,
    required this.status,
    this.remarks,
    required this.markedBy,
    required this.isLocked,
    required this.createdAt,
  });

  bool get isEditable => !isLocked && DateTime.now().difference(createdAt).inHours < 24;

  @override
  List<Object?> get props =>
      [id, schoolId, studentId, classId, sectionId, subjectId, date, status, remarks, markedBy, isLocked];
}

class AttendanceSummary extends Equatable {
  final int totalStudents;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int leaveCount;

  const AttendanceSummary({
    required this.totalStudents,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.leaveCount,
  });

  double get presentPercentage => totalStudents == 0 ? 0 : (presentCount / totalStudents) * 100;

  @override
  List<Object?> get props => [totalStudents, presentCount, absentCount, lateCount, leaveCount];
}

class LowAttendanceStudent extends Equatable {
  final String studentId;
  final String fullName;
  final String studentCode;
  final double percentage;

  const LowAttendanceStudent({
    required this.studentId,
    required this.fullName,
    required this.studentCode,
    required this.percentage,
  });

  @override
  List<Object?> get props => [studentId, fullName, studentCode, percentage];
}