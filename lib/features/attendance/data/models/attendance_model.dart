import '../../domain/entities/attendance_entity.dart';

class AttendanceModel extends AttendanceEntity {
  const AttendanceModel({
    required super.id,
    required super.schoolId,
    required super.studentId,
    required super.studentName,
    required super.classId,
    super.sectionId,
    super.subjectId,
    required super.date,
    required super.status,
    super.remarks,
    required super.markedBy,
    required super.isLocked,
    required super.createdAt,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    final student = map['students'] as Map<String, dynamic>?;
    return AttendanceModel(
      id: map['id'] as String,
      schoolId: map['school_id'] as String,
      studentId: map['student_id'] as String,
      studentName: student?['full_name'] as String? ?? '',
      classId: map['class_id'] as String,
      sectionId: map['section_id'] as String?,
      subjectId: map['subject_id'] as String?,
      date: DateTime.parse(map['date'] as String),
      status: AttendanceStatusX.fromString(map['status'] as String),
      remarks: map['remarks'] as String?,
      markedBy: map['marked_by'] as String,
      isLocked: map['is_locked'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class AttendanceSummaryModel extends AttendanceSummary {
  const AttendanceSummaryModel({
    required super.totalStudents,
    required super.presentCount,
    required super.absentCount,
    required super.lateCount,
    required super.leaveCount,
  });

  factory AttendanceSummaryModel.fromMap(Map<String, dynamic> map) {
    return AttendanceSummaryModel(
      totalStudents: (map['total_students'] as num?)?.toInt() ?? 0,
      presentCount: (map['present_count'] as num?)?.toInt() ?? 0,
      absentCount: (map['absent_count'] as num?)?.toInt() ?? 0,
      lateCount: (map['late_count'] as num?)?.toInt() ?? 0,
      leaveCount: (map['leave_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class LowAttendanceStudentModel extends LowAttendanceStudent {
  const LowAttendanceStudentModel({
    required super.studentId,
    required super.fullName,
    required super.studentCode,
    required super.percentage,
  });

  factory LowAttendanceStudentModel.fromMap(Map<String, dynamic> map) {
    return LowAttendanceStudentModel(
      studentId: map['student_id'] as String,
      fullName: map['full_name'] as String,
      studentCode: map['student_code'] as String,
      percentage: (map['percentage'] as num?)?.toDouble() ?? 0,
    );
  }
}