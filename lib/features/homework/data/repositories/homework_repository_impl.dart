import 'dart:io';
import '../../domain/entities/homework_entity.dart';
import '../../domain/repositories/homework_repository.dart';
import '../datasources/homework_remote_datasource.dart';
import '../models/homework_model.dart';

class HomeworkRepositoryImpl implements HomeworkRepository {
  final HomeworkRemoteDatasource remote;
  HomeworkRepositoryImpl(this.remote);

  HomeworkModel _toModel(HomeworkEntity e) => HomeworkModel(
    id: e.id,
    schoolId: e.schoolId,
    classId: e.classId,
    className: e.className,
    sectionId: e.sectionId,
    subjectId: e.subjectId,
    subjectName: e.subjectName,
    teacherId: e.teacherId,
    title: e.title,
    description: e.description,
    dueDate: e.dueDate,
    totalMarks: e.totalMarks,
    instructions: e.instructions,
    attachmentUrl: e.attachmentUrl,
    attachmentName: e.attachmentName,
    status: e.status,
    createdAt: e.createdAt,
  );

  @override
  Future<HomeworkEntity> createHomework(HomeworkEntity homework) => remote.createHomework(_toModel(homework));

  @override
  Future<void> updateHomework(String homeworkId, HomeworkEntity homework) =>
      remote.updateHomework(homeworkId, _toModel(homework));

  @override
  Future<void> publishHomework(String homeworkId) => remote.publishHomework(homeworkId);

  @override
  Future<void> deleteHomework(String homeworkId) => remote.deleteHomework(homeworkId);

  @override
  Future<String> uploadAttachment({required String homeworkId, required File file, required String bucket}) {
    return remote.uploadAttachment(homeworkId: homeworkId, file: file, bucket: bucket);
  }

  @override
  Future<List<HomeworkEntity>> getTeacherHomework(String teacherId) => remote.getTeacherHomework(teacherId);

  @override
  Future<List<HomeworkEntity>> getStudentHomework({required String classId, String? sectionId}) {
    return remote.getStudentHomework(classId: classId, sectionId: sectionId);
  }

  @override
  Future<HomeworkEntity> getHomeworkById(String homeworkId) => remote.getHomeworkById(homeworkId);

  @override
  Future<List<SubmissionEntity>> getSubmissionsForHomework(String homeworkId) =>
      remote.getSubmissionsForHomework(homeworkId);

  @override
  Future<SubmissionEntity?> getStudentSubmission({required String homeworkId, required String studentId}) {
    return remote.getStudentSubmission(homeworkId: homeworkId, studentId: studentId);
  }

  @override
  Future<List<SubmissionEntity>> getStudentAllSubmissions(String studentId) =>
      remote.getStudentAllSubmissions(studentId);

  @override
  Future<void> submitAnswer({
    required String homeworkId,
    required String studentId,
    String? textAnswer,
    String? attachmentUrl,
    String? attachmentName,
  }) {
    return remote.submitAnswer(
      homeworkId: homeworkId,
      studentId: studentId,
      textAnswer: textAnswer,
      attachmentUrl: attachmentUrl,
      attachmentName: attachmentName,
    );
  }

  @override
  Future<String> uploadSubmissionFile({required String homeworkId, required String studentId, required File file}) {
    return remote.uploadSubmissionFile(homeworkId: homeworkId, studentId: studentId, file: file);
  }

  @override
  Future<void> gradeSubmission({required String submissionId, required double obtainedMarks, String? feedback}) {
    return remote.gradeSubmission(submissionId: submissionId, obtainedMarks: obtainedMarks, feedback: feedback);
  }

  @override
  Future<void> returnSubmission(String submissionId) => remote.returnSubmission(submissionId);

  @override
  Future<HomeworkCompletionStats> getCompletionStats(String homeworkId) => remote.getCompletionStats(homeworkId);
}