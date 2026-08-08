import 'package:equatable/equatable.dart';

class TeacherAssignmentEntity extends Equatable {
  final String id;
  final String classId;
  final String className;
  final String? sectionId;
  final String? sectionName;
  final String subjectId;
  final String subjectName;

  const TeacherAssignmentEntity({
    required this.id,
    required this.classId,
    required this.className,
    this.sectionId,
    this.sectionName,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  List<Object?> get props => [id, classId, className, sectionId, sectionName, subjectId, subjectName];
}

class TeacherEntity extends Equatable {
  final String id;
  final String schoolId;
  final String userId;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final String? employeeCode;
  final DateTime joiningDate;
  final String status;
  final List<TeacherAssignmentEntity> assignments;

  const TeacherEntity({
    required this.id,
    required this.schoolId,
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.employeeCode,
    required this.joiningDate,
    required this.status,
    this.assignments = const [],
  });

  @override
  List<Object?> get props => [id, schoolId, userId, name, email, phone, photoUrl, employeeCode, joiningDate, status];
}