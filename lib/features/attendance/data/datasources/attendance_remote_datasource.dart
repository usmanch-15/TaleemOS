import 'package:intl/intl.dart';
import 'package:postgrest/postgrest.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/app_exception.dart';
import '../models/attendance_model.dart';

class AttendanceRemoteDatasource {
  final SupabaseClient client;
  AttendanceRemoteDatasource(this.client);

  static final _dateFormat = DateFormat('yyyy-MM-dd');

  /// Bulk mark attendance for a whole class in one go.
  /// Uses upsert to prevent duplicate rows for same student/date/subject.
  Future<void> markBulkAttendance({
    required String schoolId,
    required String classId,
    String? sectionId,
    String? subjectId,
    required DateTime date,
    required String markedBy,
    required Map<String, String> studentStatusMap, // studentId -> status
    Map<String, String>? remarksMap,
  }) async {
    final dateStr = _dateFormat.format(date);

    final rows = studentStatusMap.entries.map((entry) {
      return {
        'school_id': schoolId,
        'student_id': entry.key,
        'class_id': classId,
        'section_id': sectionId,
        'subject_id': subjectId,
        'date': dateStr,
        'status': entry.value,
        'remarks': remarksMap?[entry.key],
        'marked_by': markedBy,
      };
    }).toList();

    try {
      await client.from('attendance').upsert(
        rows,
        onConflict: 'student_id,date,subject_id',
      );
    } on PostgrestException catch (e) {
      if (e.message.toLowerCase().contains('locked') || e.message.toLowerCase().contains('edit window')) {
        throw const AppException('Attendance edit window khatam ho chuki hai, admin se rabta karein');
      }
      rethrow;
    }
  }

  Future<List<AttendanceModel>> getAttendanceForClassDate({
    required String classId,
    String? sectionId,
    String? subjectId,
    required DateTime date,
  }) async {
    var query = client
        .from('attendance')
        .select('*, students(full_name)')
        .eq('class_id', classId)
        .eq('date', _dateFormat.format(date));

    if (sectionId != null) query = query.eq('section_id', sectionId);
    if (subjectId != null) query = query.eq('subject_id', subjectId);

    final data = await query;
    return (data as List).map((e) => AttendanceModel.fromMap(e)).toList();
  }

  Future<List<AttendanceModel>> getStudentAttendanceHistory({
    required String studentId,
    required int month,
    required int year,
  }) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0);

    final data = await client
        .from('attendance')
        .select('*, students(full_name)')
        .eq('student_id', studentId)
        .gte('date', _dateFormat.format(start))
        .lte('date', _dateFormat.format(end))
        .order('date');

    return (data as List).map((e) => AttendanceModel.fromMap(e)).toList();
  }

  Future<double> getStudentAttendancePercentage({
    required String studentId,
    required int month,
    required int year,
  }) async {
    final result = await client.rpc('get_student_attendance_percentage', params: {
      'p_student_id': studentId,
      'p_month': month,
      'p_year': year,
    });
    return (result as num).toDouble();
  }

  Future<AttendanceSummaryModel> getClassAttendanceSummary({
    required String classId,
    String? sectionId,
    required DateTime date,
  }) async {
    final result = await client.rpc('get_class_attendance_summary', params: {
      'p_class_id': classId,
      'p_section_id': sectionId,
      'p_date': _dateFormat.format(date),
    });
    final row = (result as List).first as Map<String, dynamic>;
    return AttendanceSummaryModel.fromMap(row);
  }

  Future<List<LowAttendanceStudentModel>> getLowAttendanceStudents({
    required String schoolId,
    required int month,
    required int year,
    double threshold = 75,
  }) async {
    final result = await client.rpc('get_low_attendance_students', params: {
      'p_school_id': schoolId,
      'p_month': month,
      'p_year': year,
      'p_threshold': threshold,
    });
    return (result as List).map((e) => LowAttendanceStudentModel.fromMap(e)).toList();
  }

  Future<void> updateAttendanceRecord({
    required String attendanceId,
    required String status,
    String? remarks,
  }) async {
    try {
      await client.from('attendance').update({
        'status': status,
        'remarks': remarks,
      }).eq('id', attendanceId);
    } on PostgrestException catch (e) {
      if (e.message.toLowerCase().contains('locked') || e.message.toLowerCase().contains('window')) {
        throw const AppException('Attendance edit window khatam ho chuki hai');
      }
      rethrow;
    }
  }

  Future<bool> attendanceAlreadyMarked({
    required String classId,
    String? sectionId,
    String? subjectId,
    required DateTime date,
  }) async {
    var query = client
        .from('attendance')
        .select('id')
        .eq('class_id', classId)
        .eq('date', _dateFormat.format(date));
    if (sectionId != null) query = query.eq('section_id', sectionId);
    if (subjectId != null) query = query.eq('subject_id', subjectId);

    final data = await query.limit(1);
    return (data as List).isNotEmpty;
  }
}