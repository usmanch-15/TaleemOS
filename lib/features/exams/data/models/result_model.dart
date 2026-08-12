import '../../domain/entities/result_entity.dart';

class ResultModel extends ResultEntity {
  const ResultModel({
    required super.id,
    required super.examId,
    required super.examSubjectId,
    required super.studentId,
    required super.studentName,
    super.obtainedMarks,
    super.grade,
    super.remarks,
  });

  factory ResultModel.fromMap(Map<String, dynamic> map) {
    final student = map['students'] as Map<String, dynamic>?;
    return ResultModel(
      id: map['id'] as String,
      examId: map['exam_id'] as String,
      examSubjectId: map['exam_subject_id'] as String,
      studentId: map['student_id'] as String,
      studentName: student?['full_name'] as String? ?? '',
      obtainedMarks: (map['obtained_marks'] as num?)?.toDouble(),
      grade: map['grade'] as String?,
      remarks: map['remarks'] as String?,
    );
  }
}

class ExamSummaryModel extends ExamSummaryEntity {
  const ExamSummaryModel({
    required super.id,
    required super.examId,
    required super.examName,
    required super.studentId,
    required super.studentName,
    required super.totalObtained,
    required super.totalPossible,
    required super.percentage,
    super.overallGrade,
    super.classPosition,
    required super.isPass,
    super.teacherRemarks,
  });

  factory ExamSummaryModel.fromMap(Map<String, dynamic> map) {
    final student = map['students'] as Map<String, dynamic>?;
    final exam = map['exams'] as Map<String, dynamic>?;
    return ExamSummaryModel(
      id: map['id'] as String,
      examId: map['exam_id'] as String,
      examName: exam?['name'] as String? ?? '',
      studentId: map['student_id'] as String,
      studentName: student?['full_name'] as String? ?? '',
      totalObtained: (map['total_obtained'] as num).toDouble(),
      totalPossible: (map['total_possible'] as num).toDouble(),
      percentage: (map['percentage'] as num).toDouble(),
      overallGrade: map['overall_grade'] as String?,
      classPosition: map['class_position'] as int?,
      isPass: map['is_pass'] as bool? ?? true,
      teacherRemarks: map['teacher_remarks'] as String?,
    );
  }
}