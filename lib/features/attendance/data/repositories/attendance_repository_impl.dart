import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_datasource.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDatasource remote;
  AttendanceRepositoryImpl(this.remote);

  @override
  Future<void> markBulkAttendance({
    required String schoolId,
    required String classId,
    String? sectionId,
    String? subjectId,
    required DateTime date,
    required String markedBy,
    required Map<String, String> studentStatusMap,
    Map<String, String>? remarksMap,
  }) {
    return remote.markBulkAttendance(
      schoolId: schoolId,
      classId: classId,
      sectionId: sectionId,
      subjectId: subjectId,
      date: date,
      markedBy: markedBy,
      studentStatusMap: studentStatusMap,
      remarksMap: remarksMap,
    );
  }

  @override
  Future<List<AttendanceEntity>> getAttendanceForClassDate({
    required String classId,
    String? sectionId,
    String? subjectId,
    required DateTime date,
  }) {
    return remote.getAttendanceForClassDate(
      classId: classId,
      sectionId: sectionId,
      subjectId: subjectId,
      date: date,
    );
  }

  @override
  Future<List<AttendanceEntity>> getStudentAttendanceHistory({
    required String studentId,
    required int month,
    required int year,
  }) {
    return remote.getStudentAttendanceHistory(studentId: studentId, month: month, year: year);
  }

  @override
  Future<double> getStudentAttendancePercentage({
    required String studentId,
    required int month,
    required int year,
  }) {
    return remote.getStudentAttendancePercentage(studentId: studentId, month: month, year: year);
  }

  @override
  Future<AttendanceSummary> getClassAttendanceSummary({
    required String classId,
    String? sectionId,
    required DateTime date,
  }) {
    return remote.getClassAttendanceSummary(classId: classId, sectionId: sectionId, date: date);
  }

  @override
  Future<List<LowAttendanceStudent>> getLowAttendanceStudents({
    required String schoolId,
    required int month,
    required int year,
    double threshold = 75,
  }) {
    return remote.getLowAttendanceStudents(schoolId: schoolId, month: month, year: year, threshold: threshold);
  }

  @override
  Future<void> updateAttendanceRecord({
    required String attendanceId,
    required String status,
    String? remarks,
  }) {
    return remote.updateAttendanceRecord(attendanceId: attendanceId, status: status, remarks: remarks);
  }

  @override
  Future<bool> attendanceAlreadyMarked({
    required String classId,
    String? sectionId,
    String? subjectId,
    required DateTime date,
  }) {
    return remote.attendanceAlreadyMarked(
      classId: classId,
      sectionId: sectionId,
      subjectId: subjectId,
      date: date,
    );
  }
}