import '../../domain/entities/homework_entity.dart';

class HomeworkModel extends HomeworkEntity {
  const HomeworkModel({
    required super.id,
    required super.schoolId,
    required super.classId,
    required super.className,
    super.sectionId,
    required super.subjectId,
    required super.subjectName,
    required super.teacherId,
    required super.title,
    super.description,
    required super.dueDate,
    super.totalMarks,
    super.instructions,
    super.attachmentUrl,
    super.attachmentName,
    required super.status,
    required super.createdAt,
  });

  factory HomeworkModel.fromMap(Map<String, dynamic> map) {
    final classData = map['classes'] as Map<String, dynamic>?;
    final subjectData = map['subjects'] as Map<String, dynamic>?;

    return HomeworkModel(
      id: map['id'] as String,
      schoolId: map['school_id'] as String,
      classId: map['class_id'] as String,
      className: classData?['name'] as String? ?? '',
      sectionId: map['section_id'] as String?,
      subjectId: map['subject_id'] as String,
      subjectName: subjectData?['name'] as String? ?? '',
      teacherId: map['teacher_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: DateTime.parse(map['due_date'] as String),
      totalMarks: (map['total_marks'] as num?)?.toDouble(),
      instructions: map['instructions'] as String?,
      attachmentUrl: map['attachment_url'] as String?,
      attachmentName: map['attachment_name'] as String?,
      status: HomeworkStatusX.fromString(map['status'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'school_id': schoolId,
      'class_id': classId,
      'section_id': sectionId,
      'subject_id': subjectId,
      'teacher_id': teacherId,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String().split('T')[0],
      'total_marks': totalMarks,
      'instructions': instructions,
      'attachment_url': attachmentUrl,
      'attachment_name': attachmentName,
      'status': status.toDbString(),
    };
  }
}

class SubmissionModel extends SubmissionEntity {
  const SubmissionModel({
    required super.id,
    required super.homeworkId,
    required super.studentId,
    required super.studentName,
    required super.schoolId,
    super.textAnswer,
    super.attachmentUrl,
    super.attachmentName,
    required super.status,
    super.obtainedMarks,
    super.teacherFeedback,
    super.submittedAt,
    super.checkedAt,
  });

  factory SubmissionModel.fromMap(Map<String, dynamic> map) {
    final student = map['students'] as Map<String, dynamic>?;
    return SubmissionModel(
      id: map['id'] as String,
      homeworkId: map['homework_id'] as String,
      studentId: map['student_id'] as String,
      studentName: student?['full_name'] as String? ?? '',
      schoolId: map['school_id'] as String,
      textAnswer: map['text_answer'] as String?,
      attachmentUrl: map['attachment_url'] as String?,
      attachmentName: map['attachment_name'] as String?,
      status: SubmissionStatusX.fromString(map['status'] as String),
      obtainedMarks: (map['obtained_marks'] as num?)?.toDouble(),
      teacherFeedback: map['teacher_feedback'] as String?,
      submittedAt: map['submitted_at'] != null ? DateTime.parse(map['submitted_at'] as String) : null,
      checkedAt: map['checked_at'] != null ? DateTime.parse(map['checked_at'] as String) : null,
    );
  }
}

class HomeworkCompletionStatsModel extends HomeworkCompletionStats {
  const HomeworkCompletionStatsModel({
    required super.totalStudents,
    required super.submittedCount,
    required super.lateCount,
    required super.checkedCount,
    required super.pendingCount,
  });

  factory HomeworkCompletionStatsModel.fromMap(Map<String, dynamic> map) {
    return HomeworkCompletionStatsModel(
      totalStudents: (map['total_students'] as num?)?.toInt() ?? 0,
      submittedCount: (map['submitted_count'] as num?)?.toInt() ?? 0,
      lateCount: (map['late_count'] as num?)?.toInt() ?? 0,
      checkedCount: (map['checked_count'] as num?)?.toInt() ?? 0,
      pendingCount: (map['pending_count'] as num?)?.toInt() ?? 0,
    );
  }
}