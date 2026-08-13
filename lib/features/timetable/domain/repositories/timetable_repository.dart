import '../entities/timetable_entity.dart';

abstract class TimetableRepository {
  Future<List<TimetableEntryEntity>> getClassTimetable({required String classId, String? sectionId});
  Future<List<TimetableEntryEntity>> getTeacherTimetable(String teacherId);
  Future<TimetableEntryEntity> createEntry(TimetableEntryEntity entry);
  Future<void> deleteEntry(String entryId);
}