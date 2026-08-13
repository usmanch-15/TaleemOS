import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/report_remote_datasource.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/report_repository.dart';

final reportRemoteDatasourceProvider = Provider<ReportRemoteDatasource>((ref) {
  return ReportRemoteDatasource(ref.watch(supabaseClientProvider));
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepositoryImpl(ref.watch(reportRemoteDatasourceProvider));
});

final schoolDashboardStatsProvider = FutureProvider.autoDispose<SchoolDashboardStats?>((ref) async {
  final schoolId = ref.watch(authControllerProvider).user?.schoolId;
  if (schoolId == null) return null;
  return ref.watch(reportRepositoryProvider).getSchoolDashboardStats(schoolId);
});

final classWiseStudentCountProvider = FutureProvider.autoDispose<List<ClassStudentCount>>((ref) async {
  final schoolId = ref.watch(authControllerProvider).user?.schoolId;
  if (schoolId == null) return [];
  return ref.watch(reportRepositoryProvider).getClassWiseStudentCount(schoolId);
});

final selectedReportYearProvider = StateProvider<int>((ref) => DateTime.now().year);

final admissionsReportProvider = FutureProvider.autoDispose<List<AdmissionMonthData>>((ref) async {
  final schoolId = ref.watch(authControllerProvider).user?.schoolId;
  if (schoolId == null) return [];
  final year = ref.watch(selectedReportYearProvider);
  return ref.watch(reportRepositoryProvider).getAdmissionsReport(schoolId: schoolId, year: year);
});

final subjectWisePerformanceProvider =
FutureProvider.autoDispose.family<List<SubjectPerformance>, String>((ref, examId) async {
  return ref.watch(reportRepositoryProvider).getSubjectWisePerformance(examId);
});

final selectedComplianceDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final teacherMarkingStatusProvider = FutureProvider.autoDispose<List<TeacherMarkingStatus>>((ref) async {
  final schoolId = ref.watch(authControllerProvider).user?.schoolId;
  if (schoolId == null) return [];
  final date = ref.watch(selectedComplianceDateProvider);
  return ref.watch(reportRepositoryProvider).getTeacherMarkingStatus(schoolId: schoolId, date: date);
});

final globalPlatformStatsProvider = FutureProvider.autoDispose<GlobalPlatformStats>((ref) async {
  return ref.watch(reportRepositoryProvider).getGlobalPlatformStats();
});

final schoolsSummaryProvider = FutureProvider.autoDispose<List<SchoolSummary>>((ref) async {
  return ref.watch(reportRepositoryProvider).getSchoolsSummary();
});