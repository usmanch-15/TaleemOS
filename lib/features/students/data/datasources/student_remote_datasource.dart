import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/utils/pagination_utils.dart';
import '../models/student_model.dart';

class StudentRemoteDatasource {
  final SupabaseClient client;
  final ImagePickerService imagePickerService;

  StudentRemoteDatasource(this.client, this.imagePickerService);

  Future<String> generateStudentCode(String schoolId) async {
    final result = await client.rpc('generate_student_code', params: {'p_school_id': schoolId});
    return result as String;
  }

  Future<StudentModel> createStudent(StudentModel student) async {
    final data = await client.from('students').insert(student.toInsertMap(student.schoolId)).select().single();
    return StudentModel.fromMap(data);
  }

  Future<void> updateStudent(String studentId, StudentModel student) async {
    await client.from('students').update(student.toUpdateMap()).eq('id', studentId);
  }

  Future<void> updateStatus(String studentId, String status) async {
    await client.from('students').update({'status': status}).eq('id', studentId);
  }

  Future<void> deleteStudent(String studentId) async {
    await client.from('students').delete().eq('id', studentId);
  }

  Future<PaginatedResult<StudentModel>> getStudents({
    required String schoolId,
    String? classId,
    String? sectionId,
    String? searchQuery,
    PaginationParams pagination = const PaginationParams(),
  }) async {
    var query = client.from('students').select('*, classes(name), sections(name)').eq('school_id', schoolId);

    if (classId != null) query = query.eq('class_id', classId);
    if (sectionId != null) query = query.eq('section_id', sectionId);
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.or('full_name.ilike.%$searchQuery%,student_code.ilike.%$searchQuery%');
    }

    final countResponse = await client
        .from('students')
        .select('id')
        .eq('school_id', schoolId)
        .count(CountOption.exact);
    final totalCount = countResponse.count;

    final data = await query.order('full_name').range(pagination.from, pagination.to);
    final items = (data as List).map((e) => StudentModel.fromMap(e)).toList();

    return PaginatedResult(
      items: items,
      totalCount: totalCount,
      hasMore: pagination.to + 1 < totalCount,
    );
  }

  Future<StudentModel> getStudentById(String studentId) async {
    final data = await client.from('students').select().eq('id', studentId).single();
    return StudentModel.fromMap(data);
  }

  Future<String> uploadProfileImage(String studentId, File file) async {
    final ext = file.path.split('.').last;
    final path = '$studentId/profile.$ext';
    return imagePickerService.uploadImage(file: file, bucket: 'student-photos', path: path);
  }

  Future<void> transferStudent({
    required String studentId,
    required String newClassId,
    required String newSectionId,
  }) async {
    await client.from('students').update({'class_id': newClassId, 'section_id': newSectionId}).eq('id', studentId);
  }

  Future<void> linkParent({
    required String studentId,
    required String parentUserId,
    required String relation,
  }) async {
    await client.from('student_parents').insert({
      'student_id': studentId,
      'parent_user_id': parentUserId,
      'relation': relation,
    });
  }

  Future<void> unlinkParent(String studentId, String parentUserId) async {
    await client
        .from('student_parents')
        .delete()
        .eq('student_id', studentId)
        .eq('parent_user_id', parentUserId);
  }

  Future<List<Map<String, dynamic>>> getLinkedParents(String studentId) async {
    final data = await client
        .from('student_parents')
        .select('relation, users(id, name, email, phone)')
        .eq('student_id', studentId);
    return List<Map<String, dynamic>>.from(data);
  }

  /// Bulk insert for CSV import
  Future<int> bulkCreateStudents(List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) return 0;
    await client.from('students').insert(rows);
    return rows.length;
  }
}