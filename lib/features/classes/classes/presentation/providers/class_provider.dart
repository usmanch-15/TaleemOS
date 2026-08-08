import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/class_remote_datasource.dart';
import '../../data/repositories/class_repository_impl.dart';
import '../../domain/entities/class_entities.dart';
import '../../domain/repositories/class_repository.dart';

final classRemoteDatasourceProvider = Provider<ClassRemoteDatasource>((ref) {
  return ClassRemoteDatasource(ref.watch(supabaseClientProvider));
});

final classRepositoryProvider = Provider<ClassRepository>((ref) {
  return ClassRepositoryImpl(ref.watch(classRemoteDatasourceProvider));
});

final classesListProvider = FutureProvider.autoDispose<List<ClassEntity>>((ref) async {
  final authState = ref.watch(authControllerProvider);
  final schoolId = authState.user?.schoolId;
  if (schoolId == null) return [];
  return ref.watch(classRepositoryProvider).getClasses(schoolId);
});

final sectionsForClassProvider =
FutureProvider.autoDispose.family<List<SectionEntity>, String>((ref, classId) async {
  return ref.watch(classRepositoryProvider).getSections(classId);
});

final subjectsForClassProvider =
FutureProvider.autoDispose.family<List<SubjectEntity>, String>((ref, classId) async {
  return ref.watch(classRepositoryProvider).getSubjects(classId);
});

class ClassManagementController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  ClassManagementController(this.ref) : super(const AsyncValue.data(null));

  Future<bool> addClass(String name, int orderIndex) async {
    final schoolId = ref.read(authControllerProvider).user?.schoolId;
    if (schoolId == null) return false;
    state = const AsyncValue.loading();
    try {
      await ref.read(classRepositoryProvider).createClass(schoolId: schoolId, name: name, orderIndex: orderIndex);
      ref.invalidate(classesListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> addSection(String classId, String name) async {
    final schoolId = ref.read(authControllerProvider).user?.schoolId;
    if (schoolId == null) return false;
    try {
      await ref.read(classRepositoryProvider).createSection(schoolId: schoolId, classId: classId, name: name);
      ref.invalidate(sectionsForClassProvider(classId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addSubject(String classId, String name, String? code) async {
    final schoolId = ref.read(authControllerProvider).user?.schoolId;
    if (schoolId == null) return false;
    try {
      await ref.read(classRepositoryProvider).createSubject(schoolId: schoolId, classId: classId, name: name, code: code);
      ref.invalidate(subjectsForClassProvider(classId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteClass(String classId) async {
    await ref.read(classRepositoryProvider).deleteClass(classId);
    ref.invalidate(classesListProvider);
  }

  Future<void> deleteSection(String sectionId, String classId) async {
    await ref.read(classRepositoryProvider).deleteSection(sectionId);
    ref.invalidate(sectionsForClassProvider(classId));
  }

  Future<void> deleteSubject(String subjectId, String classId) async {
    await ref.read(classRepositoryProvider).deleteSubject(subjectId);
    ref.invalidate(subjectsForClassProvider(classId));
  }
}

final classManagementControllerProvider =
StateNotifierProvider<ClassManagementController, AsyncValue<void>>((ref) => ClassManagementController(ref));