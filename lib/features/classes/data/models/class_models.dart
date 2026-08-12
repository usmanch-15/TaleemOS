import '../../domain/entities/class_entities.dart';

class ClassModel extends ClassEntity {
  const ClassModel({
    required super.id,
    required super.schoolId,
    super.sessionId,
    required super.name,
    required super.orderIndex,
  });

  factory ClassModel.fromMap(Map<String, dynamic> map) => ClassModel(
    id: map['id'] as String,
    schoolId: map['school_id'] as String,
    sessionId: map['session_id'] as String?,
    name: map['name'] as String,
    orderIndex: map['order_index'] as int? ?? 0,
  );
}

class SectionModel extends SectionEntity {
  const SectionModel({
    required super.id,
    required super.schoolId,
    required super.classId,
    required super.name,
  });

  factory SectionModel.fromMap(Map<String, dynamic> map) => SectionModel(
    id: map['id'] as String,
    schoolId: map['school_id'] as String,
    classId: map['class_id'] as String,
    name: map['name'] as String,
  );
}

class SubjectModel extends SubjectEntity {
  const SubjectModel({
    required super.id,
    required super.schoolId,
    required super.classId,
    required super.name,
    super.code,
  });

  factory SubjectModel.fromMap(Map<String, dynamic> map) => SubjectModel(
    id: map['id'] as String,
    schoolId: map['school_id'] as String,
    classId: map['class_id'] as String,
    name: map['name'] as String,
    code: map['code'] as String?,
  );
}