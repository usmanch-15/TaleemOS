import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/image_picker_service.dart';
import '../models/homework_model.dart';

class HomeworkRemoteDatasource {
  final SupabaseClient client;
  final ImagePickerService imagePickerService;

  HomeworkRemoteDatasource(this.client, this.imagePickerService);

  Future<HomeworkModel> createHomework(HomeworkModel homework) async {
    final data = await client.from('homework').insert(homework.toInsertMap()).select('*, classes(name), subjects(name)').single();
    return HomeworkModel.fromMap(data);
  }

  Future<void> updateHomework(String homeworkId, HomeworkModel homework) async {
    await client.from('homework').update(homework.toInsertMap()).eq('id', homeworkId);
  }

  Future<void> publishHomework(String homeworkId) async {
    await client.from('homework').update({'status': 'published'}).eq('id', homeworkId);
  }

  Future<void> deleteHomework(String homeworkId) async {
    await client.from('homework').delete().eq('id', homeworkId);
  }

  Future<String> uploadAttachment({
    required String homeworkId,
    required File file,
    required String bucket,
  }) async {
    final fileName = file.path.split('/').last;
    final path = '$homeworkId/$fileName';
    return imagePickerService.uploadImage(file: file, bucket: bucket, path: path);
  }

  Future<List<HomeworkModel>> getTeacherHomework(String teacherId) async {
    final data = await client
        .from('homework')
        .select('*, classes(name), subjects(name)')
        .eq('teacher_id', teacherId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => HomeworkModel.fromMap(e)).toList();
  }

  Future<List<HomeworkModel>> getStudentHomework({
    required String classId,
    String? sectionId,
  }) async {
    var query = client
        .from('homework')
        .select('*, classes(name), subjects(name)')
        .eq('class_id', classId)
        .eq('status', 'published');
    final data = await query.order('due_date');
    return (data as List).map((e) => HomeworkModel.fromMap(e)).toList();
  }

  Future<HomeworkModel> getHomeworkById(String homeworkId) async {
    final data = await client.from('homework').select('*, classes(name), subjects(name)').eq('id', homeworkId).single();
    return HomeworkModel.fromMap(data);
  }

  Future<List<SubmissionModel>> getSubmissionsForHomework(String homeworkId) async {
    final data = await client
        .from('submissions')
        .select('*, students(full_name)')
        .eq('homework_id', homeworkId)
        .order('submitted_at', ascending: true, nullsFirst: false);
    return (data as List).map((e) => SubmissionModel.fromMap(e)).toList();
  }

  Future<SubmissionModel?> getStudentSubmission({
    required String homeworkId,
    required String studentId,
  }) async {
    final data = await client
        .from('submissions')
        .select('*, students(full_name)')
        .eq('homework_id', homeworkId)
        .eq('student_id', studentId)
        .maybeSingle();
    if (data == null) return null;
    return SubmissionModel.fromMap(data);
  }

  Future<List<SubmissionModel>> getStudentAllSubmissions(String studentId) async {
    final data = await client
        .from('submissions')
        .select('*, students(full_name), homework(title, due_date)')
        .eq('student_id', studentId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => SubmissionModel.fromMap(e)).toList();
  }

  Future<void> submitAnswer({
    required String homeworkId,
    required String studentId,
    String? textAnswer,
    String? attachmentUrl,
    String? attachmentName,
  }) async {
    await client
        .from('submissions')
        .update({
      'text_answer': textAnswer,
      'attachment_url': attachmentUrl,
      'attachment_name': attachmentName,
      'submitted_at': DateTime.now().toIso8601String(),
    })
        .eq('homework_id', homeworkId)
        .eq('student_id', studentId);
  }

  Future<String> uploadSubmissionFile({
    required String homeworkId,
    required String studentId,
    required File file,
  }) async {
    final fileName = file.path.split('/').last;
    final path = '$homeworkId/$studentId/$fileName';
    return imagePickerService.uploadImage(file: file, bucket: 'submission-files', path: path);
  }

  Future<void> gradeSubmission({
    required String submissionId,
    required double obtainedMarks,
    String? feedback,
  }) async {
    await client.from('submissions').update({
      'obtained_marks': obtainedMarks,
      'teacher_feedback': feedback,
      'status': 'checked',
      'checked_at': DateTime.now().toIso8601String(),
    }).eq('id', submissionId);
  }

  Future<void> returnSubmission(String submissionId) async {
    await client.from('submissions').update({'status': 'returned'}).eq('id', submissionId);
  }

  Future<HomeworkCompletionStatsModel> getCompletionStats(String homeworkId) async {
    final result = await client.rpc('get_homework_completion_stats', params: {'p_homework_id': homeworkId});
    final row = (result as List).first as Map<String, dynamic>;
    return HomeworkCompletionStatsModel.fromMap(row);
  }
}