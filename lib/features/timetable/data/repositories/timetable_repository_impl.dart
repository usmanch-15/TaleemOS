import '../../domain/entities/timetable_entity.dart';
import '../../domain/repositories/timetable_repository.dart';
import '../datasources/timetable_remote_datasource.dart';
import '../models/timetable_model.dart';

class TimetableRepositoryImpl implements TimetableRepository {
  final TimetableRemoteDatasource remote;
  TimetableRepositoryImpl(this.remote);

  @override
  Future<List<TimetableEntryEntity>> getClassTimetable({required String classId, String? sectionId}) {
    return remote.getClassTimetable(classId: classId, sectionId: sectionId);
  }

  @override
  Future<List<TimetableEntryEntity>> getTeacherTimetable(String teacherId) => remote.getTeacherTimetable(teacherId);

  @override
  Future<TimetableEntryEntity> createEntry(TimetableEntryEntity entry) {
    final model = TimetableEntryModel(
      id: entry.id,
      schoolId: entry.schoolId,
      classId: entry.classId,
      sectionId: entry.sectionId,
      subjectId: entry.subjectId,
      subjectName: entry.subjectName,
      teacherId: entry.teacherId,
      dayOfWeek: entry.dayOfWeek,
      startTime: entry.startTime,
      endTime: entry.endTime,
      roomNumber: entry.roomNumber,
    );
    return remote.createEntry(model);
  }

  @override
  Future<void> deleteEntry(String entryId) => remote.deleteEntry(entryId);
}