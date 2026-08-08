import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/teacher_remote_datasource.dart';
import '../../data/repositories/teacher_repository_impl.dart';
import '../../domain/entities/teacher_entity.dart';
import '../../domain/repositories/teacher_repository.dart';

final teacherRemoteDatasourceProvider = Provider<TeacherRemoteDatasource>((ref) {
  return TeacherRemoteDatasource(ref.watch(supabaseClientProvider));
});

final teacherRepositoryProvider = Provider<TeacherRepository>((ref) {
  return TeacherRepositoryImpl(ref.watch(teacherRemoteDatasourceProvider));
});

final teachersListProvider = FutureProvider.autoDispose<List<TeacherEntity>>((ref) async {
  final schoolId = ref.watch(authControllerProvider).user?.schoolId;
  if (schoolId == null) return [];
  return ref.watch(teacherRepositoryProvider).getTeachers(schoolId);
});

final teacherDetailProvider = FutureProvider.autoDispose.family<TeacherEntity, String>((ref, teacherId) async {
  return ref.watch(teacherRepositoryProvider).getTeacherById(teacherId);
});

final teacherAssignmentsProvider =
FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>((ref, teacherId) async {
  return ref.watch(teacherRepositoryProvider).getAssignments(teacherId);
});

class TeacherManagementController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  TeacherManagementController(this.ref) : super(const AsyncValue.data(null));

  Future<bool> inviteTeacher({required String name, required String email, required String phone}) async {
    final schoolId = ref.read(authControllerProvider).user?.schoolId;
    if (schoolId == null) return false;
    state = const AsyncValue.loading();
    try {
      await ref.read(teacherRepositoryProvider).inviteTeacher(schoolId: schoolId, name: name, email: email, phone: phone);
      ref.invalidate(teachersListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> toggleStatus(String teacherId, bool isActive) async {
    await ref.read(teacherRepositoryProvider).updateTeacherStatus(teacherId, isActive ? 'active' : 'inactive');
    ref.invalidate(teachersListProvider);
  }

  Future<void> deleteTeacher(String teacherId) async {
    await ref.read(teacherRepositoryProvider).deleteTeacher(teacherId);
    ref.invalidate(teachersListProvider);
  }

  Future<bool> assignClass({
    required String teacherId,
    required String classId,
    String? sectionId,
    required String subjectId,
  }) async {
    final schoolId = ref.read(authControllerProvider).user?.schoolId;
    if (schoolId == null) return false;
    try {
      await ref.read(teacherRepositoryProvider).assignClass(
        schoolId: schoolId,
        teacherId: teacherId,
        classId: classId,
        sectionId: sectionId,
        subjectId: subjectId,
      );
      ref.invalidate(teacherAssignmentsProvider(teacherId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> removeAssignment(String assignmentId, String teacherId) async {
    await ref.read(teacherRepositoryProvider).removeAssignment(assignmentId);
    ref.invalidate(teacherAssignmentsProvider(teacherId));
  }
}

final teacherManagementControllerProvider =
StateNotifierProvider<TeacherManagementController, AsyncValue<void>>((ref) => TeacherManagementController(ref));