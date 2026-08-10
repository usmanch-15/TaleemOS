import '../entities/exam_entity.dart';
import '../entities/result_entity.dart';

abstract class ExamRepository {
  Future<ExamEntity> createExam(ExamEntity exam);
  Future<void> addSubjectToExam({
    required String examId,
    required String subjectId,
    required double totalMarks,
    required double passingMarks,
    DateTime? examDate,
  });
  Future<void> removeExamSubject(String examSubjectId);
  Future<List<ExamEntity>> getExamsForSchool(String schoolId);
  Future<List<ExamEntity>> getPublishedExamsForClass(String classId);
  Future<ExamEntity> getExamById(String examId);
  Future<void> updateExamStatus(String examId, String status);
  Future<void> publishExam(String examId);
  Future<void> deleteExam(String examId);

  Future<List<ResultEntity>> getMarksSheet({required String examSubjectId, required String classId, String? sectionId});
  Future<void> saveMarksBulk({
    required String examId,
    required String examSubjectId,
    required String schoolId,
    required String enteredBy,
    required Map<String, double?> studentMarksMap,
  });

  Future<ExamSummaryEntity?> getStudentExamSummary({required String examId, required String studentId});
  Future<List<Map<String, dynamic>>> getStudentSubjectWiseResults({required String examId, required String studentId});
  Future<List<ExamSummaryEntity>> getClassExamSummaries(String examId);
  Future<List<ExamSummaryEntity>> getStudentAllExamSummaries(String studentId);
}