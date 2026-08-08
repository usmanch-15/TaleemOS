import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/class_models.dart';

class ClassRemoteDatasource {
  final SupabaseClient client;
  ClassRemoteDatasource(this.client);

  Future<List<ClassModel>> getClasses(String schoolId) async {
    final data = await client
        .from('classes')
        .select()
        .eq('school_id', schoolId)
        .order('order_index', ascending: true);
    return (data as List).map((e) => ClassModel.fromMap(e)).toList();
  }

  Future<ClassModel> createClass({
    required String schoolId,
    String? sessionId,
    required String name,
    required int orderIndex,
  }) async {
    final data = await client
        .from('classes')
        .insert({
      'school_id': schoolId,
      'session_id': sessionId,
      'name': name,
      'order_index': orderIndex,
    })
        .select()
        .single();
    return ClassModel.fromMap(data);
  }

  Future<void> updateClass(String classId, String name) async {
    await client.from('classes').update({'name': name}).eq('id', classId);
  }

  Future<void> deleteClass(String classId) async {
    await client.from('classes').delete().eq('id', classId);
  }

  Future<List<SectionModel>> getSections(String classId) async {
    final data = await client.from('sections').select().eq('class_id', classId).order('name');
    return (data as List).map((e) => SectionModel.fromMap(e)).toList();
  }

  Future<SectionModel> createSection({
    required String schoolId,
    required String classId,
    required String name,
  }) async {
    final data = await client
        .from('sections')
        .insert({'school_id': schoolId, 'class_id': classId, 'name': name})
        .select()
        .single();
    return SectionModel.fromMap(data);
  }

  Future<void> deleteSection(String sectionId) async {
    await client.from('sections').delete().eq('id', sectionId);
  }

  Future<List<SubjectModel>> getSubjects(String classId) async {
    final data = await client.from('subjects').select().eq('class_id', classId).order('name');
    return (data as List).map((e) => SubjectModel.fromMap(e)).toList();
  }

  Future<SubjectModel> createSubject({
    required String schoolId,
    required String classId,
    required String name,
    String? code,
  }) async {
    final data = await client
        .from('subjects')
        .insert({'school_id': schoolId, 'class_id': classId, 'name': name, 'code': code})
        .select()
        .single();
    return SubjectModel.fromMap(data);
  }

  Future<void> deleteSubject(String subjectId) async {
    await client.from('subjects').delete().eq('id', subjectId);
  }
}