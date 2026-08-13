import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/report_models.dart';

class ReportRemoteDatasource {
  final SupabaseClient client;
  ReportRemoteDatasource(this.client);

  Future<SchoolDashboardStatsModel> getSchoolDashboardStats(String schoolId) async {
    final result = await client.rpc('get_school_dashboard_stats', params: {'p_school_id': schoolId});
    final row = (result as List).first as Map<String, dynamic>;
    return SchoolDashboardStatsModel.fromMap(row);
  }

  Future<List<ClassStudentCountModel>> getClassWiseStudentCount(String schoolId) async {
    final result = await client.rpc('get_class_wise_student_count', params: {'p_school_id': schoolId});
    return (result as List).map((e) => ClassStudentCountModel.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<List<AdmissionMonthDataModel>> getAdmissionsReport({required String schoolId, required int year}) async {
    final result = await client.rpc('get_admissions_report', params: {'p_school_id': schoolId, 'p_year': year});
    return (result as List).map((e) => AdmissionMonthDataModel.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<List<SubjectPerformanceModel>> getSubjectWisePerformance(String examId) async {
    final result = await client.rpc('get_subject_wise_performance', params: {'p_exam_id': examId});
    return (result as List).map((e) => SubjectPerformanceModel.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<List<TeacherMarkingStatusModel>> getTeacherMarkingStatus({required String schoolId, required DateTime date}) async {
    final result = await client.rpc('get_teacher_marking_status', params: {
      'p_school_id': schoolId,
      'p_date': date.toIso8601String().split('T')[0],
    });
    return (result as List).map((e) => TeacherMarkingStatusModel.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<GlobalPlatformStatsModel> getGlobalPlatformStats() async {
    final result = await client.rpc('get_global_platform_stats');
    final row = (result as List).first as Map<String, dynamic>;
    return GlobalPlatformStatsModel.fromMap(row);
  }

  Future<List<SchoolSummaryModel>> getSchoolsSummary() async {
    final result = await client.rpc('get_schools_summary');
    return (result as List).map((e) => SchoolSummaryModel.fromMap(e as Map<String, dynamic>)).toList();
  }

  // Reusable exports: student list, attendance rows, fees rows for CSV
  Future<List<Map<String, dynamic>>> getStudentListExport(String schoolId) async {
    final data = await client
        .from('students')
        .select('student_code, full_name, father_name, classes(name), sections(name), status, phone')
        .eq('school_id', schoolId)
        .order('full_name');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getPendingFeesExport(String schoolId) async {
    final data = await client
        .from('fee_invoices')
        .select('students(full_name, student_code), title, total_payable, amount_paid, due_date, status')
        .eq('school_id', schoolId)
        .inFilter('status', ['pending', 'partially_paid', 'overdue'])
        .order('due_date');
    return List<Map<String, dynamic>>.from(data);
  }
}