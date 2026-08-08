import '../entities/attendance_entity.dart';
import '../repositories/attendance_repository.dart';

class MarkAttendanceUsecase {
  final AttendanceRepository repository;
  MarkAttendanceUsecase(this.repository);

  Future<void> call({
    required String schoolId,
    required String classId,
    String? sectionId,
    String? subjectId,
    required DateTime date,
    required String markedBy,
    required Map<String, String> studentStatusMap,
    Map<String, String>? remarksMap,
  }) {
    return repository.markBulkAttendance(
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
}

class GetClassAttendanceUsecase {
  final AttendanceRepository repository;
  GetClassAttendanceUsecase(this.repository);

  Future<List<AttendanceEntity>> call({
    required String classId,
    String? sectionId,
    String? subjectId,
    required DateTime date,
  }) {
    return repository.getAttendanceForClassDate(
      classId: classId,
      sectionId: sectionId,
      subjectId: subjectId,
      date: date,
    );
  }
}

class GetStudentAttendanceHistoryUsecase {
  final AttendanceRepository repository;
  GetStudentAttendanceHistoryUsecase(this.repository);

  Future<List<AttendanceEntity>> call({required String studentId, required int month, required int year}) {
    return repository.getStudentAttendanceHistory(studentId: studentId, month: month, year: year);
  }
}

class GetAttendanceReportUsecase {
  final AttendanceRepository repository;
  GetAttendanceReportUsecase(this.repository);

  Future<AttendanceSummary> classSummary({required String classId, String? sectionId, required DateTime date}) {
    return repository.getClassAttendanceSummary(classId: classId, sectionId: sectionId, date: date);
  }

  Future<List<LowAttendanceStudent>> lowAttendanceStudents({
    required String schoolId,
    required int month,
    required int year,
    double threshold = 75,
  }) {
    return repository.getLowAttendanceStudents(schoolId: schoolId, month: month, year: year, threshold: threshold);
  }
}