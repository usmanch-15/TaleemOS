import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/teacher_model.dart';

class TeacherRemoteDatasource {
  final SupabaseClient client;
  TeacherRemoteDatasource(this.client);

  Future<List<TeacherModel>> getTeachers(String schoolId) async {
    final data = await client
        .from('teachers')
        .select('*, users(name, email, phone, photo_url)')
        .eq('school_id', schoolId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => TeacherModel.fromMap(e)).toList();
  }

  Future<TeacherModel> getTeacherById(String teacherId) async {
    final data = await client
        .from('teachers')
        .select('*, users(name, email, phone, photo_url)')
        .eq('id', teacherId)
        .single();
    return TeacherModel.fromMap(data);
  }

  /// Creates auth user + users row + teachers row via Edge Function
  /// (service_role key required to create auth users — client SDK can't do this directly)
  Future<void> inviteTeacher({
    required String schoolId,
    required String name,
    required String email,
    required String phone,
  }) async {
    await client.functions.invoke('invite-teacher', body: {
      'school_id': schoolId,
      'name': name,
      'email': email,
      'phone': phone,
    });
  }

  Future<void> updateTeacherStatus(String teacherId, String status) async {
    await client.from('teachers').update({'status': status}).eq('id', teacherId);
  }

  Future<void> updateEmployeeCode(String teacherId, String code) async {
    await client.from('teachers').update({'employee_code': code}).eq('id', teacherId);
  }

  Future<void> deleteTeacher(String teacherId) async {
    await client.from('teachers').delete().eq('id', teacherId);
  }

  Future<List<Map<String, dynamic>>> getAssignments(String teacherId) async {
    final data = await client
        .from('teacher_assignments')
        .select('id, class_id, classes(name), section_id, sections(name), subject_id, subjects(name)')
        .eq('teacher_id', teacherId);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> assignClass({
    required String schoolId,
    required String teacherId,
    required String classId,
    String? sectionId,
    required String subjectId,
  }) async {
    await client.from('teacher_assignments').insert({
      'school_id': schoolId,
      'teacher_id': teacherId,
      'class_id': classId,
      'section_id': sectionId,
      'subject_id': subjectId,
    });
  }

  Future<void> removeAssignment(String assignmentId) async {
    await client.from('teacher_assignments').delete().eq('id', assignmentId);
  }
}