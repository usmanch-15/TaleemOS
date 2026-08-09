import 'dart:io';
import '../entities/homework_entity.dart';

abstract class HomeworkRepository {
  Future<HomeworkEntity> createHomework(HomeworkEntity homework);
  Future<void> updateHomework(String homeworkId, HomeworkEntity homework);
  Future<void> publishHomework(String homeworkId);
  Future<void> deleteHomework(String homeworkId);
  Future<String> uploadAttachment({required String homeworkId, required File file, required String bucket});

  Future<List<HomeworkEntity>> getTeacherHomework(String teacherId);
  Future<List<HomeworkEntity>> getStudentHomework({required String classId, String? sectionId});
  Future<HomeworkEntity> getHomeworkById(String homeworkId);

  Future<List<SubmissionEntity>> getSubmissionsForHomework(String homeworkId);
  Future<SubmissionEntity?> getStudentSubmission({required String homeworkId, required String studentId});
  Future<List<SubmissionEntity>> getStudentAllSubmissions(String studentId);

  Future<void> submitAnswer({
    required String homeworkId,
    required String studentId,
    String? textAnswer,
    String? attachmentUrl,
    String? attachmentName,
  });

  Future<String> uploadSubmissionFile({required String homeworkId, required String studentId, required File file});

  Future<void> gradeSubmission({required String submissionId, required double obtainedMarks, String? feedback});
  Future<void> returnSubmission(String submissionId);
  Future<HomeworkCompletionStats> getCompletionStats(String homeworkId);
}