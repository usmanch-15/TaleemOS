import '../entities/class_entities.dart';

abstract class ClassRepository {
  Future<List<ClassEntity>> getClasses(String schoolId);
  Future<ClassEntity> createClass({
    required String schoolId,
    String? sessionId,
    required String name,
    required int orderIndex,
  });
  Future<void> updateClass(String classId, String name);
  Future<void> deleteClass(String classId);

  Future<List<SectionEntity>> getSections(String classId);
  Future<SectionEntity> createSection({required String schoolId, required String classId, required String name});
  Future<void> deleteSection(String sectionId);

  Future<List<SubjectEntity>> getSubjects(String classId);
  Future<SubjectEntity> createSubject({
    required String schoolId,
    required String classId,
    required String name,
    String? code,
  });
  Future<void> deleteSubject(String subjectId);
}
