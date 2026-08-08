import '../entities/attendance_entity.dart';

abstract class AttendanceRepository {
  Future<void> markBulkAttendance({
    required String schoolId,
    required String classId,
    String? sectionId,
    String? subjectId,
    required DateTime date,
    required String markedBy,
    required Map<String, String> studentStatusMap,
    Map<String, String>? remarksMap,
  });

  Future<List<AttendanceEntity>> getAttendanceForClassDate({
    required String classId,
    String? sectionId,
    String? subjectId,
    required DateTime date,
  });

  Future<List<AttendanceEntity>> getStudentAttendanceHistory({
    required String studentId,
    required int month,
    required int year,
  });

  Future<double> getStudentAttendancePercentage({
    required String studentId,
    required int month,
    required int year,
  });

  Future<AttendanceSummary> getClassAttendanceSummary({
    required String classId,
    String? sectionId,
    required DateTime date,
  });

  Future<List<LowAttendanceStudent>> getLowAttendanceStudents({
    required String schoolId,
    required int month,
    required int year,
    double threshold = 75,
  });

  Future<void> updateAttendanceRecord({
    required String attendanceId,
    required String status,
    String? remarks,
  });

  Future<bool> attendanceAlreadyMarked({
    required String classId,
    String? sectionId,
    String? subjectId,
    required DateTime date,
  });
}