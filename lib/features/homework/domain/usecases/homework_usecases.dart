import 'dart:io';
import '../entities/homework_entity.dart';
import '../repositories/homework_repository.dart';

class CreateHomeworkUsecase {
  final HomeworkRepository repository;
  CreateHomeworkUsecase(this.repository);
  Future<HomeworkEntity> call(HomeworkEntity homework) => repository.createHomework(homework);
}

class PublishHomeworkUsecase {
  final HomeworkRepository repository;
  PublishHomeworkUsecase(this.repository);
  Future<void> call(String homeworkId) => repository.publishHomework(homeworkId);
}

class GetTeacherHomeworkUsecase {
  final HomeworkRepository repository;
  GetTeacherHomeworkUsecase(this.repository);
  Future<List<HomeworkEntity>> call(String teacherId) => repository.getTeacherHomework(teacherId);
}

class GetStudentHomeworkUsecase {
  final HomeworkRepository repository;
  GetStudentHomeworkUsecase(this.repository);
  Future<List<HomeworkEntity>> call({required String classId, String? sectionId}) {
    return repository.getStudentHomework(classId: classId, sectionId: sectionId);
  }
}

class SubmitHomeworkUsecase {
  final HomeworkRepository repository;
  SubmitHomeworkUsecase(this.repository);

  Future<void> call({
    required String homeworkId,
    required String studentId,
    String? textAnswer,
    File? attachmentFile,
  }) async {
    String? attachmentUrl;
    String? attachmentName;

    if (attachmentFile != null) {
      attachmentUrl = await repository.uploadSubmissionFile(
        homeworkId: homeworkId,
        studentId: studentId,
        file: attachmentFile,
      );
      attachmentName = attachmentFile.path.split('/').last;
    }

    await repository.submitAnswer(
      homeworkId: homeworkId,
      studentId: studentId,
      textAnswer: textAnswer,
      attachmentUrl: attachmentUrl,
      attachmentName: attachmentName,
    );
  }
}

class GradeSubmissionUsecase {
  final HomeworkRepository repository;
  GradeSubmissionUsecase(this.repository);
  Future<void> call({required String submissionId, required double obtainedMarks, String? feedback}) {
    return repository.gradeSubmission(submissionId: submissionId, obtainedMarks: obtainedMarks, feedback: feedback);
  }
}