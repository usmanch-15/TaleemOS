import 'package:equatable/equatable.dart';

class ResultEntity extends Equatable {
  final String id;
  final String examId;
  final String examSubjectId;
  final String studentId;
  final String studentName;
  final double? obtainedMarks;
  final String? grade;
  final String? remarks;

  const ResultEntity({
    required this.id,
    required this.examId,
    required this.examSubjectId,
    required this.studentId,
    required this.studentName,
    this.obtainedMarks,
    this.grade,
    this.remarks,
  });

  @override
  List<Object?> get props => [id, examId, examSubjectId, studentId, obtainedMarks, grade];
}

class ExamSummaryEntity extends Equatable {
  final String id;
  final String examId;
  final String examName;
  final String studentId;
  final String studentName;
  final double totalObtained;
  final double totalPossible;
  final double percentage;
  final String? overallGrade;
  final int? classPosition;
  final bool isPass;
  final String? teacherRemarks;

  const ExamSummaryEntity({
    required this.id,
    required this.examId,
    required this.examName,
    required this.studentId,
    required this.studentName,
    required this.totalObtained,
    required this.totalPossible,
    required this.percentage,
    this.overallGrade,
    this.classPosition,
    required this.isPass,
    this.teacherRemarks,
  });

  @override
  List<Object?> get props => [id, examId, studentId, totalObtained, percentage, overallGrade, classPosition, isPass];
}

class SubjectResultDetail extends Equatable {
  final String subjectName;
  final double? obtainedMarks;
  final double totalMarks;
  final String? grade;

  const SubjectResultDetail({
    required this.subjectName,
    this.obtainedMarks,
    required this.totalMarks,
    this.grade,
  });

  @override
  List<Object?> get props => [subjectName, obtainedMarks, totalMarks, grade];
}