import '../../domain/entities/exam_entity.dart';
import '../../domain/entities/result_entity.dart';
import '../../domain/repositories/exam_repository.dart';
import '../datasources/exam_remote_datasource.dart';
import '../models/exam_model.dart';

class ExamRepositoryImpl implements ExamRepository {
  final ExamRemoteDatasource remote;
  ExamRepositoryImpl(this.remote);

  @override
  Future<ExamEntity> createExam(ExamEntity exam) {
    final model = ExamModel(
      id: exam.id,
      schoolId: exam.schoolId,
      classId: exam.classId,
      className: exam.className,
      sessionId: exam.sessionId,
      name: exam.name,
      examType: exam.examType,
      startDate: exam.startDate,
      endDate: exam.endDate,
      status: exam.status,
    );
    return remote.createExam(model);
  }

  @override
  Future<void> addSubjectToExam({
    required String examId,
    required String subjectId,
    required double totalMarks,
    required double passingMarks,
    DateTime? examDate,
  }) {
    return remote.addSubjectToExam(
      examId: examId,
      subjectId: subjectId,
      totalMarks: totalMarks,
      passingMarks: passingMarks,
      examDate: examDate,
    );
  }

  @override
  Future<void> removeExamSubject(String examSubjectId) => remote.removeExamSubject(examSubjectId);

  @override
  Future<List<ExamEntity>> getExamsForSchool(String schoolId) => remote.getExamsForSchool(schoolId);

  @override
  Future<List<ExamEntity>> getPublishedExamsForClass(String classId) => remote.getPublishedExamsForClass(classId);

  @override
  Future<ExamEntity> getExamById(String examId) => remote.getExamById(examId);

  @override
  Future<void> updateExamStatus(String examId, String status) => remote.updateExamStatus(examId, status);

  @override
  Future<void> publishExam(String examId) => remote.publishExam(examId);

  @override
  Future<void> deleteExam(String examId) => remote.deleteExam(examId);

  @override
  Future<List<ResultEntity>> getMarksSheet({required String examSubjectId, required String classId, String? sectionId}) {
    return remote.getMarksSheet(examSubjectId: examSubjectId, classId: classId, sectionId: sectionId);
  }

  @override
  Future<void> saveMarksBulk({
    required String examId,
    required String examSubjectId,
    required String schoolId,
    required String enteredBy,
    required Map<String, double?> studentMarksMap,
  }) {
    return remote.saveMarksBulk(
      examId: examId,
      examSubjectId: examSubjectId,
      schoolId: schoolId,
      enteredBy: enteredBy,
      studentMarksMap: studentMarksMap,
    );
  }

  @override
  Future<ExamSummaryEntity?> getStudentExamSummary({required String examId, required String studentId}) {
    return remote.getStudentExamSummary(examId: examId, studentId: studentId);
  }

  @override
  Future<List<Map<String, dynamic>>> getStudentSubjectWiseResults({required String examId, required String studentId}) {
    return remote.getStudentSubjectWiseResults(examId: examId, studentId: studentId);
  }

  @override
  Future<List<ExamSummaryEntity>> getClassExamSummaries(String examId) => remote.getClassExamSummaries(examId);

  @override
  Future<List<ExamSummaryEntity>> getStudentAllExamSummaries(String studentId) =>
      remote.getStudentAllExamSummaries(studentId);
}