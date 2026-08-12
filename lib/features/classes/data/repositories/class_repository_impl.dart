import '../../domain/entities/class_entities.dart';
import '../../domain/repositories/class_repository.dart';
import '../datasources/class_remote_datasource.dart';

class ClassRepositoryImpl implements ClassRepository {
  final ClassRemoteDatasource remote;
  ClassRepositoryImpl(this.remote);

  @override
  Future<List<ClassEntity>> getClasses(String schoolId) => remote.getClasses(schoolId);

  @override
  Future<ClassEntity> createClass({
    required String schoolId,
    String? sessionId,
    required String name,
    required int orderIndex,
  }) {
    return remote.createClass(schoolId: schoolId, sessionId: sessionId, name: name, orderIndex: orderIndex);
  }

  @override
  Future<void> updateClass(String classId, String name) => remote.updateClass(classId, name);

  @override
  Future<void> deleteClass(String classId) => remote.deleteClass(classId);

  @override
  Future<List<SectionEntity>> getSections(String classId) => remote.getSections(classId);

  @override
  Future<SectionEntity> createSection({required String schoolId, required String classId, required String name}) {
    return remote.createSection(schoolId: schoolId, classId: classId, name: name);
  }

  @override
  Future<void> deleteSection(String sectionId) => remote.deleteSection(sectionId);

  @override
  Future<List<SubjectEntity>> getSubjects(String classId) => remote.getSubjects(classId);

  @override
  Future<SubjectEntity> createSubject({
    required String schoolId,
    required String classId,
    required String name,
    String? code,
  }) {
    return remote.createSubject(schoolId: schoolId, classId: classId, name: name, code: code);
  }

  @override
  Future<void> deleteSubject(String subjectId) => remote.deleteSubject(subjectId);
}