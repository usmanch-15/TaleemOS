import '../entities/report_entity.dart';

abstract class ReportRepository {
  Future<SchoolDashboardStats> getSchoolDashboardStats(String schoolId);
  Future<List<ClassStudentCount>> getClassWiseStudentCount(String schoolId);
  Future<List<AdmissionMonthData>> getAdmissionsReport({required String schoolId, required int year});
  Future<List<SubjectPerformance>> getSubjectWisePerformance(String examId);
  Future<List<TeacherMarkingStatus>> getTeacherMarkingStatus({required String schoolId, required DateTime date});
  Future<GlobalPlatformStats> getGlobalPlatformStats();
  Future<List<SchoolSummary>> getSchoolsSummary();
  Future<List<Map<String, dynamic>>> getStudentListExport(String schoolId);
  Future<List<Map<String, dynamic>>> getPendingFeesExport(String schoolId);
}