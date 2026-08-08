import '../../domain/entities/teacher_entity.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../datasources/teacher_remote_datasource.dart';

class TeacherRepositoryImpl implements TeacherRepository {
  final TeacherRemoteDatasource remote;
  TeacherRepositoryImpl(this.remote);

  @override
  Future<List<TeacherEntity>> getTeachers(String schoolId) => remote.getTeachers(schoolId);

  @override
  Future<TeacherEntity> getTeacherById(String teacherId) => remote.getTeacherById(teacherId);

  @override
  Future<void> inviteTeacher({required String schoolId, required String name, required String email, required String phone}) {
    return remote.inviteTeacher(schoolId: schoolId, name: name, email: email, phone: phone);
  }

  @override
  Future<void> updateTeacherStatus(String teacherId, String status) => remote.updateTeacherStatus(teacherId, status);

  @override
  Future<void> updateEmployeeCode(String teacherId, String code) => remote.updateEmployeeCode(teacherId, code);

  @override
  Future<void> deleteTeacher(String teacherId) => remote.deleteTeacher(teacherId);

  @override
  Future<List<Map<String, dynamic>>> getAssignments(String teacherId) => remote.getAssignments(teacherId);

  @override
  Future<void> assignClass({
    required String schoolId,
    required String teacherId,
    required String classId,
    String? sectionId,
    required String subjectId,
  }) {
    return remote.assignClass(
      schoolId: schoolId,
      teacherId: teacherId,
      classId: classId,
      sectionId: sectionId,
      subjectId: subjectId,
    );
  }

  @override
  Future<void> removeAssignment(String assignmentId) => remote.removeAssignment(assignmentId);
}