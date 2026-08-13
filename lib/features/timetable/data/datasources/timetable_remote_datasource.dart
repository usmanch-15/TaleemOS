import 'package:postgrest/postgrest.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/app_exception.dart';
import '../models/timetable_model.dart';

class TimetableRemoteDatasource {
  final SupabaseClient client;
  TimetableRemoteDatasource(this.client);

  Future<List<TimetableEntryModel>> getClassTimetable({required String classId, String? sectionId}) async {
    var query = client
        .from('timetables')
        .select('*, subjects(name), teachers(users(name))')
        .eq('class_id', classId);
    if (sectionId != null) query = query.eq('section_id', sectionId);

    final data = await query.order('day_of_week').order('start_time');
    return (data as List).map((e) => TimetableEntryModel.fromMap(e)).toList();
  }

  Future<List<TimetableEntryModel>> getTeacherTimetable(String teacherId) async {
    final data = await client
        .from('timetables')
        .select('*, subjects(name), teachers(users(name))')
        .eq('teacher_id', teacherId)
        .order('day_of_week')
        .order('start_time');
    return (data as List).map((e) => TimetableEntryModel.fromMap(e)).toList();
  }

  Future<TimetableEntryModel> createEntry(TimetableEntryModel entry) async {
    try {
      final data = await client
          .from('timetables')
          .insert(entry.toInsertMap())
          .select('*, subjects(name), teachers(users(name))')
          .single();
      return TimetableEntryModel.fromMap(data);
    } on PostgrestException catch (e) {
      if (e.message.toLowerCase().contains('already assigned')) {
        throw const AppException('Ye teacher is waqt doosri class mein assigned hai');
      }
      rethrow;
    }
  }

  Future<void> deleteEntry(String entryId) async {
    await client.from('timetables').delete().eq('id', entryId);
  }
}