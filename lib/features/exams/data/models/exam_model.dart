import '../../domain/entities/exam_entity.dart';

class ExamSubjectModel extends ExamSubjectEntity {
  const ExamSubjectModel({
    required super.id,
    required super.examId,
    required super.subjectId,
    required super.subjectName,
    required super.totalMarks,
    required super.passingMarks,
    super.examDate,
  });

  factory ExamSubjectModel.fromMap(Map<String, dynamic> map) {
    final subject = map['subjects'] as Map<String, dynamic>?;
    return ExamSubjectModel(
      id: map['id'] as String,
      examId: map['exam_id'] as String,
      subjectId: map['subject_id'] as String,
      subjectName: subject?['name'] as String? ?? '',
      totalMarks: (map['total_marks'] as num).toDouble(),
      passingMarks: (map['passing_marks'] as num).toDouble(),
      examDate: map['exam_date'] != null ? DateTime.parse(map['exam_date'] as String) : null,
    );
  }
}

class ExamModel extends ExamEntity {
  const ExamModel({
    required super.id,
    required super.schoolId,
    required super.classId,
    required super.className,
    super.sessionId,
    required super.name,
    required super.examType,
    required super.startDate,
    required super.endDate,
    required super.status,
    super.subjects,
  });

  factory ExamModel.fromMap(Map<String, dynamic> map) {
    final classData = map['classes'] as Map<String, dynamic>?;
    final subjectsList = (map['exam_subjects'] as List<dynamic>?)
        ?.map((e) => ExamSubjectModel.fromMap(e as Map<String, dynamic>))
        .toList() ??
        [];

    return ExamModel(
      id: map['id'] as String,
      schoolId: map['school_id'] as String,
      classId: map['class_id'] as String,
      className: classData?['name'] as String? ?? '',
      sessionId: map['session_id'] as String?,
      name: map['name'] as String,
      examType: ExamTypeX.fromString(map['exam_type'] as String),
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      status: ExamStatusX.fromString(map['status'] as String),
      subjects: subjectsList,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'school_id': schoolId,
      'class_id': classId,
      'session_id': sessionId,
      'name': name,
      'exam_type': examType.toDbString(),
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'status': status.toDbString(),
    };
  }
}