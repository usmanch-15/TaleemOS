import 'dart:io';
import '../../../../core/utils/pagination_utils.dart';
import '../entities/student_entity.dart';

abstract class StudentRepository {
  Future<String> generateStudentCode(String schoolId);
  Future<StudentEntity> createStudent(StudentEntity student);
  Future<void> updateStudent(String studentId, StudentEntity student);
  Future<void> updateStatus(String studentId, StudentStatus status);
  Future<void> deleteStudent(String studentId);
  Future<PaginatedResult<StudentEntity>> getStudents({
    required String schoolId,
    String? classId,
    String? sectionId,
    String? searchQuery,
    PaginationParams pagination = const PaginationParams(),
  });
  Future<StudentEntity> getStudentById(String studentId);
  Future<String> uploadProfileImage(String studentId, File file);
  Future<void> transferStudent({required String studentId, required String newClassId, required String newSectionId});
  Future<void> linkParent({required String studentId, required String parentUserId, required String relation});
  Future<void> unlinkParent(String studentId, String parentUserId);
  Future<List<Map<String, dynamic>>> getLinkedParents(String studentId);
  Future<int> bulkCreateStudents(List<Map<String, dynamic>> rows);
}