import 'dart:io';
import '../entities/school_entity.dart';

abstract class SchoolRepository {
  Future<SchoolEntity> getSchool(String schoolId);
  Future<void> updateSchoolProfile(SchoolEntity school);
  Future<String> uploadLogo(String schoolId, File file);
  Future<void> createAcademicSession({
    required String schoolId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required bool isCurrent,
  });
  Future<List<Map<String, dynamic>>> getAcademicSessions(String schoolId);
  Future<void> completeSetup(String schoolId);
}