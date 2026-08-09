import 'package:equatable/equatable.dart';

enum HomeworkStatus { draft, published }

extension HomeworkStatusX on HomeworkStatus {
  String toDbString() => this == HomeworkStatus.draft ? 'draft' : 'published';

  static HomeworkStatus fromString(String value) =>
      value == 'published' ? HomeworkStatus.published : HomeworkStatus.draft;
}

enum SubmissionStatus { pending, submitted, late, checked, returned }

extension SubmissionStatusX on SubmissionStatus {
  String toDbString() {
    switch (this) {
      case SubmissionStatus.pending:
        return 'pending';
      case SubmissionStatus.submitted:
        return 'submitted';
      case SubmissionStatus.late:
        return 'late';
      case SubmissionStatus.checked:
        return 'checked';
      case SubmissionStatus.returned:
        return 'returned';
    }
  }

  static SubmissionStatus fromString(String value) {
    switch (value) {
      case 'submitted':
        return SubmissionStatus.submitted;
      case 'late':
        return SubmissionStatus.late;
      case 'checked':
        return SubmissionStatus.checked;
      case 'returned':
        return SubmissionStatus.returned;
      default:
        return SubmissionStatus.pending;
    }
  }

  String get label {
    switch (this) {
      case SubmissionStatus.pending:
        return 'Pending';
      case SubmissionStatus.submitted:
        return 'Submitted';
      case SubmissionStatus.late:
        return 'Late';
      case SubmissionStatus.checked:
        return 'Checked';
      case SubmissionStatus.returned:
        return 'Returned';
    }
  }
}

class HomeworkEntity extends Equatable {
  final String id;
  final String schoolId;
  final String classId;
  final String className;
  final String? sectionId;
  final String subjectId;
  final String subjectName;
  final String teacherId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final double? totalMarks;
  final String? instructions;
  final String? attachmentUrl;
  final String? attachmentName;
  final HomeworkStatus status;
  final DateTime createdAt;

  const HomeworkEntity({
    required this.id,
    required this.schoolId,
    required this.classId,
    required this.className,
    this.sectionId,
    required this.subjectId,
    required this.subjectName,
    required this.teacherId,
    required this.title,
    this.description,
    required this.dueDate,
    this.totalMarks,
    this.instructions,
    this.attachmentUrl,
    this.attachmentName,
    required this.status,
    required this.createdAt,
  });

  bool get isOverdue => DateTime.now().isAfter(dueDate) && status == HomeworkStatus.published;

  @override
  List<Object?> get props => [id, schoolId, classId, sectionId, subjectId, teacherId, title, dueDate, status];
}

class SubmissionEntity extends Equatable {
  final String id;
  final String homeworkId;
  final String studentId;
  final String studentName;
  final String schoolId;
  final String? textAnswer;
  final String? attachmentUrl;
  final String? attachmentName;
  final SubmissionStatus status;
  final double? obtainedMarks;
  final String? teacherFeedback;
  final DateTime? submittedAt;
  final DateTime? checkedAt;

  const SubmissionEntity({
    required this.id,
    required this.homeworkId,
    required this.studentId,
    required this.studentName,
    required this.schoolId,
    this.textAnswer,
    this.attachmentUrl,
    this.attachmentName,
    required this.status,
    this.obtainedMarks,
    this.teacherFeedback,
    this.submittedAt,
    this.checkedAt,
  });

  @override
  List<Object?> get props => [id, homeworkId, studentId, status, obtainedMarks, submittedAt];
}

class HomeworkCompletionStats extends Equatable {
  final int totalStudents;
  final int submittedCount;
  final int lateCount;
  final int checkedCount;
  final int pendingCount;

  const HomeworkCompletionStats({
    required this.totalStudents,
    required this.submittedCount,
    required this.lateCount,
    required this.checkedCount,
    required this.pendingCount,
  });

  double get completionPercentage =>
      totalStudents == 0 ? 0 : ((submittedCount + lateCount + checkedCount) / totalStudents) * 100;

  @override
  List<Object?> get props => [totalStudents, submittedCount, lateCount, checkedCount, pendingCount];
}