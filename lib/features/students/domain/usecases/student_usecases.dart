import 'dart:io';
import '../../../../core/utils/pagination_utils.dart';
import '../entities/student_entity.dart';
import '../repositories/student_repository.dart';

class CreateStudentUsecase {
  final StudentRepository repository;
  CreateStudentUsecase(this.repository);
  Future<StudentEntity> call(StudentEntity student) => repository.createStudent(student);
}

class UpdateStudentUsecase {
  final StudentRepository repository;
  UpdateStudentUsecase(this.repository);
  Future<void> call(String studentId, StudentEntity student) => repository.updateStudent(studentId, student);
}

class DeleteStudentUsecase {
  final StudentRepository repository;
  DeleteStudentUsecase(this.repository);
  Future<void> call(String studentId) => repository.deleteStudent(studentId);
}

class GetStudentsUsecase {
  final StudentRepository repository;
  GetStudentsUsecase(this.repository);
  Future<PaginatedResult<StudentEntity>> call({
    required String schoolId,
    String? classId,
    String? sectionId,
    String? searchQuery,
    PaginationParams pagination = const PaginationParams(),
  }) {
    return repository.getStudents(
      schoolId: schoolId,
      classId: classId,
      sectionId: sectionId,
      searchQuery: searchQuery,
      pagination: pagination,
    );
  }
}

class TransferStudentUsecase {
  final StudentRepository repository;
  TransferStudentUsecase(this.repository);
  Future<void> call({required String studentId, required String newClassId, required String newSectionId}) {
    return repository.transferStudent(studentId: studentId, newClassId: newClassId, newSectionId: newSectionId);
  }
}

class UploadStudentPhotoUsecase {
  final StudentRepository repository;
  UploadStudentPhotoUsecase(this.repository);
  Future<String> call(String studentId, File file) => repository.uploadProfileImage(studentId, file);
}

class LinkParentUsecase {
  final StudentRepository repository;
  LinkParentUsecase(this.repository);
  Future<void> call({required String studentId, required String parentUserId, required String relation}) {
    return repository.linkParent(studentId: studentId, parentUserId: parentUserId, relation: relation);
  }
}