import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/school_remote_datasource.dart';
import '../../data/repositories/school_repository_impl.dart';
import '../../domain/entities/school_entity.dart';
import '../../domain/repositories/school_repository.dart';
import '../../domain/usecases/school_usecases.dart';

final imagePickerServiceProvider = Provider<ImagePickerService>((ref) {
  return ImagePickerService(ref.watch(supabaseClientProvider));
});

final schoolRemoteDatasourceProvider = Provider<SchoolRemoteDatasource>((ref) {
  return SchoolRemoteDatasource(ref.watch(supabaseClientProvider), ref.watch(imagePickerServiceProvider));
});

final schoolRepositoryProvider = Provider<SchoolRepository>((ref) {
  return SchoolRepositoryImpl(ref.watch(schoolRemoteDatasourceProvider));
});

final getSchoolUsecaseProvider = Provider((ref) => GetSchoolUsecase(ref.watch(schoolRepositoryProvider)));
final updateSchoolProfileUsecaseProvider =
Provider((ref) => UpdateSchoolProfileUsecase(ref.watch(schoolRepositoryProvider)));
final uploadSchoolLogoUsecaseProvider =
Provider((ref) => UploadSchoolLogoUsecase(ref.watch(schoolRepositoryProvider)));
final createAcademicSessionUsecaseProvider =
Provider((ref) => CreateAcademicSessionUsecase(ref.watch(schoolRepositoryProvider)));
final completeSchoolSetupUsecaseProvider =
Provider((ref) => CompleteSchoolSetupUsecase(ref.watch(schoolRepositoryProvider)));

// Current logged-in user's school data
final currentSchoolProvider = FutureProvider.autoDispose<SchoolEntity?>((ref) async {
  final authState = ref.watch(authControllerProvider);
  final schoolId = authState.user?.schoolId;
  if (schoolId == null) return null;
  return ref.watch(getSchoolUsecaseProvider).call(schoolId);
});

class SchoolSetupController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  SchoolSetupController(this.ref) : super(const AsyncValue.data(null));

  Future<bool> saveProfile(SchoolEntity school) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(updateSchoolProfileUsecaseProvider).call(school);
      ref.invalidate(currentSchoolProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<String?> uploadLogo(String schoolId, File file) async {
    try {
      return await ref.read(uploadSchoolLogoUsecaseProvider).call(schoolId, file);
    } catch (e) {
      return null;
    }
  }

  Future<bool> finishSetup(String schoolId) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(completeSchoolSetupUsecaseProvider).call(schoolId);
      ref.invalidate(currentSchoolProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final schoolSetupControllerProvider =
StateNotifierProvider<SchoolSetupController, AsyncValue<void>>((ref) => SchoolSetupController(ref));