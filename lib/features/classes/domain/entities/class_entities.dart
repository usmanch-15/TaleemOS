import 'package:equatable/equatable.dart';

class ClassEntity extends Equatable {
  final String id;
  final String schoolId;
  final String? sessionId;
  final String name;
  final int orderIndex;

  const ClassEntity({
    required this.id,
    required this.schoolId,
    this.sessionId,
    required this.name,
    required this.orderIndex,
  });

  @override
  List<Object?> get props => [id, schoolId, sessionId, name, orderIndex];
}

class SectionEntity extends Equatable {
  final String id;
  final String schoolId;
  final String classId;
  final String name;

  const SectionEntity({
    required this.id,
    required this.schoolId,
    required this.classId,
    required this.name,
  });

  @override
  List<Object?> get props => [id, schoolId, classId, name];
}

class SubjectEntity extends Equatable {
  final String id;
  final String schoolId;
  final String classId;
  final String name;
  final String? code;

  const SubjectEntity({
    required this.id,
    required this.schoolId,
    required this.classId,
    required this.name,
    this.code,
  });

  @override
  List<Object?> get props => [id, schoolId, classId, name, code];
}