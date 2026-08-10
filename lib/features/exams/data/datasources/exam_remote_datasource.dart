import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exam_model.dart';
import '../models/result_model.dart';

class ExamRemoteDatasource {
  final SupabaseClient client;
  ExamRemoteDatasource(this.client);

  Future<ExamModel> createExam(ExamModel exam) async {
    final data = await client.from('exams').insert(exam.toInsertMap()).select('*, classes(name)').single();
    return ExamModel.fromMap(data);
  }

  Future<void> addSubjectToExam({
    required String examId,
    required String subjectId,
    required double totalMarks,
    required double passingMarks,
    DateTime? examDate,
  }) async {
    await client.from('exam_subjects').insert({
      'exam_id': examId,
      'subject_id': subjectId,
      'total_marks': totalMarks,
      'passing_marks': passingMarks,
      'exam_date': examDate?.toIso8601String().split('T')[0],
    });
  }

  Future<void> removeExamSubject(String examSubjectId) async {
    await client.from('exam_subjects').delete().eq('id', examSubjectId);
  }

  Future<List<ExamModel>> getExamsForSchool(String schoolId) async {
    final data = await client
        .from('exams')
        .select('*, classes(name), exam_subjects(*, subjects(name))')
        .eq('school_id', schoolId)
        .order('start_date', ascending: false);
    return (data as List).map((e) => ExamModel.fromMap(e)).toList();
  }

  Future<List<ExamModel>> getPublishedExamsForClass(String classId) async {
    final data = await client
        .from('exams')
        .select('*, classes(name), exam_subjects(*, subjects(name))')
        .eq('class_id', classId)
        .eq('status', 'published')
        .order('start_date', ascending: false);
    return (data as List).map((e) => ExamModel.fromMap(e)).toList();
  }

  Future<ExamModel> getExamById(String examId) async {
    final data = await client
        .from('exams')
        .select('*, classes(name), exam_subjects(*, subjects(name))')
        .eq('id', examId)
        .single();
    return ExamModel.fromMap(data);
  }

  Future<void> updateExamStatus(String examId, String status) async {
    await client.from('exams').update({'status': status}).eq('id', examId);
  }

  Future<void> publishExam(String examId) async {
    await client.rpc('publish_exam', params: {'p_exam_id': examId});
  }

  Future<void> deleteExam(String examId) async {
    await client.from('exams').delete().eq('id', examId);
  }

  /// Get marks-entry sheet: all students of the class with existing results (if any) for one subject
  Future<List<ResultModel>> getMarksSheet({
    required String examSubjectId,
    required String classId,
    String? sectionId,
  }) async {
    var studentsQuery = client.from('students').select('id, full_name').eq('class_id', classId).eq('status', 'active');
    if (sectionId != null) studentsQuery = studentsQuery.eq('section_id', sectionId);
    final students = await studentsQuery.order('full_name');

    final existingResults = await client
        .from('results')
        .select('*, students(full_name)')
        .eq('exam_subject_id', examSubjectId);

    final resultsByStudent = {
      for (final r in existingResults) r['student_id'] as String: r,
    };

    return (students as List).map((s) {
      final studentId = s['id'] as String;
      final existing = resultsByStudent[studentId];
      if (existing != null) {
        return ResultModel.fromMap(existing);
      }
      return ResultModel(
        id: '',
        examId: '',
        examSubjectId: examSubjectId,
        studentId: studentId,
        studentName: s['full_name'] as String,
      );
    }).toList();
  }

  Future<void> saveMarksBulk({
    required String examId,
    required String examSubjectId,
    required String schoolId,
    required String enteredBy,
    required Map<String, double?> studentMarksMap, // studentId -> marks
  }) async {
    final rows = studentMarksMap.entries
        .where((e) => e.value != null)
        .map((e) => {
      'school_id': schoolId,
      'exam_id': examId,
      'exam_subject_id': examSubjectId,
      'student_id': e.key,
      'obtained_marks': e.value,
      'entered_by': enteredBy,
    })
        .toList();

    if (rows.isEmpty) return;

    await client.from('results').upsert(rows, onConflict: 'exam_subject_id,student_id');
  }

  Future<ExamSummaryModel?> getStudentExamSummary({required String examId, required String studentId}) async {
    final data = await client
        .from('exam_summaries')
        .select('*, students(full_name), exams(name)')
        .eq('exam_id', examId)
        .eq('student_id', studentId)
        .maybeSingle();
    if (data == null) return null;
    return ExamSummaryModel.fromMap(data);
  }

  Future<List<Map<String, dynamic>>> getStudentSubjectWiseResults({
    required String examId,
    required String studentId,
  }) async {
    final data = await client
        .from('results')
        .select('obtained_marks, exam_subjects(total_marks, subjects(name))')
        .eq('exam_id', examId)
        .eq('student_id', studentId);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<ExamSummaryModel>> getClassExamSummaries(String examId) async {
    final data = await client
        .from('exam_summaries')
        .select('*, students(full_name), exams(name)')
        .eq('exam_id', examId)
        .order('class_position', ascending: true, nullsFirst: false);
    return (data as List).map((e) => ExamSummaryModel.fromMap(e)).toList();
  }

  Future<List<ExamSummaryModel>> getStudentAllExamSummaries(String studentId) async {
    final data = await client
        .from('exam_summaries')
        .select('*, students(full_name), exams(name, status)')
        .eq('student_id', studentId)
        .order('updated_at', ascending: false);

    // Filter only published exams client-side (defensive; RLS already restricts)
    return (data as List)
        .where((e) => (e['exams'] as Map<String, dynamic>?)?['status'] == 'published')
        .map((e) => ExamSummaryModel.fromMap(e))
        .toList();
  }
}