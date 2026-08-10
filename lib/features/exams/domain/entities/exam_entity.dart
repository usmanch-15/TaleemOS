import 'package:equatable/equatable.dart';

enum ExamType { midterm, finalTerm, monthlyTest, quiz }

extension ExamTypeX on ExamType {
  String toDbString() {
    switch (this) {
      case ExamType.midterm:
        return 'midterm';
      case ExamType.finalTerm:
        return 'final_term';
      case ExamType.monthlyTest:
        return 'monthly_test';
      case ExamType.quiz:
        return 'quiz';
    }
  }

  static ExamType fromString(String value) {
    switch (value) {
      case 'midterm':
        return ExamType.midterm;
      case 'final_term':
        return ExamType.finalTerm;
      case 'monthly_test':
        return ExamType.monthlyTest;
      default:
        return ExamType.quiz;
    }
  }

  String get label {
    switch (this) {
      case ExamType.midterm:
        return 'Midterm';
      case ExamType.finalTerm:
        return 'Final Term';
      case ExamType.monthlyTest:
        return 'Monthly Test';
      case ExamType.quiz:
        return 'Quiz';
    }
  }
}

enum ExamStatus { draft, ongoing, completed, published }

extension ExamStatusX on ExamStatus {
  String toDbString() {
    switch (this) {
      case ExamStatus.draft:
        return 'draft';
      case ExamStatus.ongoing:
        return 'ongoing';
      case ExamStatus.completed:
        return 'completed';
      case ExamStatus.published:
        return 'published';
    }
  }

  static ExamStatus fromString(String value) {
    switch (value) {
      case 'ongoing':
        return ExamStatus.ongoing;
      case 'completed':
        return ExamStatus.completed;
      case 'published':
        return ExamStatus.published;
      default:
        return ExamStatus.draft;
    }
  }

  String get label {
    switch (this) {
      case ExamStatus.draft:
        return 'Draft';
      case ExamStatus.ongoing:
        return 'Ongoing';
      case ExamStatus.completed:
        return 'Completed';
      case ExamStatus.published:
        return 'Published';
    }
  }
}

class ExamSubjectEntity extends Equatable {
  final String id;
  final String examId;
  final String subjectId;
  final String subjectName;
  final double totalMarks;
  final double passingMarks;
  final DateTime? examDate;

  const ExamSubjectEntity({
    required this.id,
    required this.examId,
    required this.subjectId,
    required this.subjectName,
    required this.totalMarks,
    required this.passingMarks,
    this.examDate,
  });

  @override
  List<Object?> get props => [id, examId, subjectId, totalMarks, passingMarks];
}

class ExamEntity extends Equatable {
  final String id;
  final String schoolId;
  final String classId;
  final String className;
  final String? sessionId;
  final String name;
  final ExamType examType;
  final DateTime startDate;
  final DateTime endDate;
  final ExamStatus status;
  final List<ExamSubjectEntity> subjects;

  const ExamEntity({
    required this.id,
    required this.schoolId,
    required this.classId,
    required this.className,
    this.sessionId,
    required this.name,
    required this.examType,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.subjects = const [],
  });

  @override
  List<Object?> get props => [id, schoolId, classId, name, examType, startDate, endDate, status];
}