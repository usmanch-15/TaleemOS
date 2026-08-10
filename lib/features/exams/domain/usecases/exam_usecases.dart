import '../entities/exam_entity.dart';
import '../entities/result_entity.dart';
import '../repositories/exam_repository.dart';

class CreateExamUsecase {
  final ExamRepository repository;
  CreateExamUsecase(this.repository);
  Future<ExamEntity> call(ExamEntity exam) => repository.createExam(exam);
}

class AddExamSubjectUsecase {
  final ExamRepository repository;
  AddExamSubjectUsecase(this.repository);
  Future<void> call({
    required String examId,
    required String subjectId,
    required double totalMarks,
    required double passingMarks,
  }) {
    return repository.addSubjectToExam(
      examId: examId,
      subjectId: subjectId,
      totalMarks: totalMarks,
      passingMarks: passingMarks,
    );
  }
}

class SaveMarksUsecase {
  final ExamRepository repository;
  SaveMarksUsecase(this.repository);
  Future<void> call({
    required String examId,
    required String examSubjectId,
    required String schoolId,
    required String enteredBy,
    required Map<String, double?> studentMarksMap,
  }) {
    return repository.saveMarksBulk(
      examId: examId,
      examSubjectId: examSubjectId,
      schoolId: schoolId,
      enteredBy: enteredBy,
      studentMarksMap: studentMarksMap,
    );
  }
}

class PublishExamUsecase {
  final ExamRepository repository;
  PublishExamUsecase(this.repository);
  Future<void> call(String examId) => repository.publishExam(examId);
}

class GetReportCardUsecase {
  final ExamRepository repository;
  GetReportCardUsecase(this.repository);

  Future<ExamSummaryEntity?> summary({required String examId, required String studentId}) {
    return repository.getStudentExamSummary(examId: examId, studentId: studentId);
  }

  Future<List<Map<String, dynamic>>> subjectWise({required String examId, required String studentId}) {
    return repository.getStudentSubjectWiseResults(examId: examId, studentId: studentId);
  }
}