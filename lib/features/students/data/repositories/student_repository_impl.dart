import 'dart:io';
import '../../../../core/utils/pagination_utils.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_remote_datasource.dart';
import '../models/student_model.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDatasource remote;
  StudentRepositoryImpl(this.remote);

  StudentModel _toModel(StudentEntity e) => StudentModel(
    id: e.id,
    schoolId: e.schoolId,
    userId: e.userId,
    fullName: e.fullName,
    fatherName: e.fatherName,
    dob: e.dob,
    gender: e.gender,
    profileImageUrl: e.profileImageUrl,
    studentCode: e.studentCode,
    rollNumber: e.rollNumber,
    classId: e.classId,
    sectionId: e.sectionId,
    admissionDate: e.admissionDate,
    phone: e.phone,
    address: e.address,
    bloodGroup: e.bloodGroup,
    emergencyContact: e.emergencyContact,
    previousSchool: e.previousSchool,
    status: e.status,
  );

  @override
  Future<String> generateStudentCode(String schoolId) => remote.generateStudentCode(schoolId);

  @override
  Future<StudentEntity> createStudent(StudentEntity student) => remote.createStudent(_toModel(student));

  @override
  Future<void> updateStudent(String studentId, StudentEntity student) =>
      remote.updateStudent(studentId, _toModel(student));

  @override
  Future<void> updateStatus(String studentId, StudentStatus status) {
    final str = status == StudentStatus.active ? 'active' : (status == StudentStatus.inactive ? 'inactive' : 'graduated');
    return remote.updateStatus(studentId, str);
  }

  @override
  Future<void> deleteStudent(String studentId) => remote.deleteStudent(studentId);

  @override
  Future<PaginatedResult<StudentEntity>> getStudents({
    required String schoolId,
    String? classId,
    String? sectionId,
    String? searchQuery,
    PaginationParams pagination = const PaginationParams(),
  }) {
    return remote.getStudents(
      schoolId: schoolId,
      classId: classId,
      sectionId: sectionId,
      searchQuery: searchQuery,
      pagination: pagination,
    );
  }

  @override
  Future<StudentEntity> getStudentById(String studentId) => remote.getStudentById(studentId);

  @override
  Future<String> uploadProfileImage(String studentId, File file) => remote.uploadProfileImage(studentId, file);

  @override
  Future<void> transferStudent({required String studentId, required String newClassId, required String newSectionId}) {
    return remote.transferStudent(studentId: studentId, newClassId: newClassId, newSectionId: newSectionId);
  }

  @override
  Future<void> linkParent({required String studentId, required String parentUserId, required String relation}) {
    return remote.linkParent(studentId: studentId, parentUserId: parentUserId, relation: relation);
  }

  @override
  Future<void> unlinkParent(String studentId, String parentUserId) => remote.unlinkParent(studentId, parentUserId);

  @override
  Future<List<Map<String, dynamic>>> getLinkedParents(String studentId) => remote.getLinkedParents(studentId);

  @override
  Future<int> bulkCreateStudents(List<Map<String, dynamic>> rows) => remote.bulkCreateStudents(rows);
}