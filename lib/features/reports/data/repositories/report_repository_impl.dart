import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDatasource remote;
  ReportRepositoryImpl(this.remote);

  @override
  Future<SchoolDashboardStats> getSchoolDashboardStats(String schoolId) => remote.getSchoolDashboardStats(schoolId);

  @override
  Future<List<ClassStudentCount>> getClassWiseStudentCount(String schoolId) => remote.getClassWiseStudentCount(schoolId);

  @override
  Future<List<AdmissionMonthData>> getAdmissionsReport({required String schoolId, required int year}) {
    return remote.getAdmissionsReport(schoolId: schoolId, year: year);
  }

  @override
  Future<List<SubjectPerformance>> getSubjectWisePerformance(String examId) => remote.getSubjectWisePerformance(examId);

  @override
  Future<List<TeacherMarkingStatus>> getTeacherMarkingStatus({required String schoolId, required DateTime date}) {
    return remote.getTeacherMarkingStatus(schoolId: schoolId, date: date);
  }

  @override
  Future<GlobalPlatformStats> getGlobalPlatformStats() => remote.getGlobalPlatformStats();

  @override
  Future<List<SchoolSummary>> getSchoolsSummary() => remote.getSchoolsSummary();

  @override
  Future<List<Map<String, dynamic>>> getStudentListExport(String schoolId) => remote.getStudentListExport(schoolId);

  @override
  Future<List<Map<String, dynamic>>> getPendingFeesExport(String schoolId) => remote.getPendingFeesExport(schoolId);
}