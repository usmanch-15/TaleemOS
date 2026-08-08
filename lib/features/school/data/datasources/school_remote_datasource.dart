import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/image_picker_service.dart';
import '../models/school_model.dart';

class SchoolRemoteDatasource {
  final SupabaseClient client;
  final ImagePickerService imagePickerService;

  SchoolRemoteDatasource(this.client, this.imagePickerService);

  Future<SchoolModel> getSchool(String schoolId) async {
    final data = await client.from('schools').select().eq('id', schoolId).single();
    return SchoolModel.fromMap(data);
  }

  Future<void> updateSchool(String schoolId, Map<String, dynamic> updateMap) async {
    await client.from('schools').update(updateMap).eq('id', schoolId);
  }

  Future<String> uploadLogo(String schoolId, File file) async {
    final ext = file.path.split('.').last;
    final path = '$schoolId/logo.$ext';
    return imagePickerService.uploadImage(file: file, bucket: 'school-logos', path: path);
  }

  Future<void> createAcademicSession({
    required String schoolId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required bool isCurrent,
  }) async {
    if (isCurrent) {
      await client.from('academic_sessions').update({'is_current': false}).eq('school_id', schoolId);
    }
    await client.from('academic_sessions').insert({
      'school_id': schoolId,
      'name': name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_current': isCurrent,
    });
  }

  Future<List<Map<String, dynamic>>> getAcademicSessions(String schoolId) async {
    final data = await client
        .from('academic_sessions')
        .select()
        .eq('school_id', schoolId)
        .order('start_date', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }
}