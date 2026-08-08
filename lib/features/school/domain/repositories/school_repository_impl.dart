import 'dart:io';
import '../../domain/entities/school_entity.dart';
import '../../domain/repositories/school_repository.dart';
import '../datasources/school_remote_datasource.dart';
import '../models/school_model.dart';

class SchoolRepositoryImpl implements SchoolRepository {
  final SchoolRemoteDatasource remote;
  SchoolRepositoryImpl(this.remote);

  @override
  Future<SchoolEntity> getSchool(String schoolId) => remote.getSchool(schoolId);

  @override
  Future<void> updateSchoolProfile(SchoolEntity school) async {
    final model = SchoolModel(
      id: school.id,
      name: school.name,
      schoolCode: school.schoolCode,
      logoUrl: school.logoUrl,
      address: school.address,
      contactNumber: school.contactNumber,
      status: school.status,
      workingDays: school.workingDays,
      startTime: school.startTime,
      endTime: school.endTime,
      gradingSystem: school.gradingSystem,
      setupCompleted: school.setupCompleted,
    );
    await remote.updateSchool(school.id, model.toUpdateMap());
  }

  @override
  Future<String> uploadLogo(String schoolId, File file) => remote.uploadLogo(schoolId, file);

  @override
  Future<void> createAcademicSession({
    required String schoolId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required bool isCurrent,
  }) {
    return remote.createAcademicSession(
      schoolId: schoolId,
      name: name,
      startDate: startDate,
      endDate: endDate,
      isCurrent: isCurrent,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getAcademicSessions(String schoolId) =>
      remote.getAcademicSessions(schoolId);

  @override
  Future<void> completeSetup(String schoolId) {
    return remote.updateSchool(schoolId, {'setup_completed': true});
  }
}