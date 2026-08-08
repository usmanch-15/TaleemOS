import '../entities/teacher_entity.dart';

abstract class TeacherRepository {
  Future<List<TeacherEntity>> getTeachers(String schoolId);
  Future<TeacherEntity> getTeacherById(String teacherId);
  Future<void> inviteTeacher({required String schoolId, required String name, required String email, required String phone});
  Future<void> updateTeacherStatus(String teacherId, String status);
  Future<void> updateEmployeeCode(String teacherId, String code);
  Future<void> deleteTeacher(String teacherId);
  Future<List<Map<String, dynamic>>> getAssignments(String teacherId);
  Future<void> assignClass({
    required String schoolId,
    required String teacherId,
    required String classId,
    String? sectionId,
    required String subjectId,
  });
  Future<void> removeAssignment(String assignmentId);
}