import 'dart:io';
import '../entities/school_entity.dart';
import '../repositories/school_repository.dart';

class GetSchoolUsecase {
  final SchoolRepository repository;
  GetSchoolUsecase(this.repository);
  Future<SchoolEntity> call(String schoolId) => repository.getSchool(schoolId);
}

class UpdateSchoolProfileUsecase {
  final SchoolRepository repository;
  UpdateSchoolProfileUsecase(this.repository);
  Future<void> call(SchoolEntity school) => repository.updateSchoolProfile(school);
}

class UploadSchoolLogoUsecase {
  final SchoolRepository repository;
  UploadSchoolLogoUsecase(this.repository);
  Future<String> call(String schoolId, File file) => repository.uploadLogo(schoolId, file);
}

class CreateAcademicSessionUsecase {
  final SchoolRepository repository;
  CreateAcademicSessionUsecase(this.repository);
  Future<void> call({
    required String schoolId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required bool isCurrent,
  }) {
    return repository.createAcademicSession(
      schoolId: schoolId,
      name: name,
      startDate: startDate,
      endDate: endDate,
      isCurrent: isCurrent,
    );
  }
}

class CompleteSchoolSetupUsecase {
  final SchoolRepository repository;
  CompleteSchoolSetupUsecase(this.repository);
  Future<void> call(String schoolId) => repository.completeSetup(schoolId);
}