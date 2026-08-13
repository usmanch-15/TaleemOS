import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/timetable_remote_datasource.dart';
import '../../data/repositories/timetable_repository_impl.dart';
import '../../domain/entities/timetable_entity.dart';
import '../../domain/repositories/timetable_repository.dart';

final timetableRemoteDatasourceProvider = Provider<TimetableRemoteDatasource>((ref) {
  return TimetableRemoteDatasource(ref.watch(supabaseClientProvider));
});

final timetableRepositoryProvider = Provider<TimetableRepository>((ref) {
  return TimetableRepositoryImpl(ref.watch(timetableRemoteDatasourceProvider));
});

final classTimetableProvider = FutureProvider.autoDispose
    .family<List<TimetableEntryEntity>, ({String classId, String? sectionId})>((ref, params) async {
  return ref.watch(timetableRepositoryProvider).getClassTimetable(classId: params.classId, sectionId: params.sectionId);
});

final teacherTimetableProvider = FutureProvider.autoDispose.family<List<TimetableEntryEntity>, String>((ref, teacherId) async {
  return ref.watch(timetableRepositoryProvider).getTeacherTimetable(teacherId);
});

class TimetableController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  TimetableController(this.ref) : super(const AsyncValue.data(null));

  Future<bool> addEntry(TimetableEntryEntity entry) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(timetableRepositoryProvider).createEntry(entry);
      ref.invalidate(classTimetableProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> deleteEntry(String entryId) async {
    await ref.read(timetableRepositoryProvider).deleteEntry(entryId);
    ref.invalidate(classTimetableProvider);
  }
}

final timetableControllerProvider =
StateNotifierProvider<TimetableController, AsyncValue<void>>((ref) => TimetableController(ref));