import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/pagination_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../school/presentation/providers/school_provider.dart';
import '../../data/datasources/student_remote_datasource.dart';
import '../../data/repositories/student_repository_impl.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/usecases/student_usecases.dart';

final studentRemoteDatasourceProvider = Provider<StudentRemoteDatasource>((ref) {
  return StudentRemoteDatasource(ref.watch(supabaseClientProvider), ref.watch(imagePickerServiceProvider));
});

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepositoryImpl(ref.watch(studentRemoteDatasourceProvider));
});

final createStudentUsecaseProvider = Provider((ref) => CreateStudentUsecase(ref.watch(studentRepositoryProvider)));
final updateStudentUsecaseProvider = Provider((ref) => UpdateStudentUsecase(ref.watch(studentRepositoryProvider)));
final deleteStudentUsecaseProvider = Provider((ref) => DeleteStudentUsecase(ref.watch(studentRepositoryProvider)));
final getStudentsUsecaseProvider = Provider((ref) => GetStudentsUsecase(ref.watch(studentRepositoryProvider)));
final transferStudentUsecaseProvider = Provider((ref) => TransferStudentUsecase(ref.watch(studentRepositoryProvider)));
final uploadStudentPhotoUsecaseProvider =
Provider((ref) => UploadStudentPhotoUsecase(ref.watch(studentRepositoryProvider)));
final linkParentUsecaseProvider = Provider((ref) => LinkParentUsecase(ref.watch(studentRepositoryProvider)));

class StudentFilterState {
  final String? classId;
  final String? sectionId;
  final String searchQuery;

  const StudentFilterState({this.classId, this.sectionId, this.searchQuery = ''});

  StudentFilterState copyWith({String? classId, String? sectionId, String? searchQuery}) {
    return StudentFilterState(
      classId: classId ?? this.classId,
      sectionId: sectionId ?? this.sectionId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final studentFilterProvider = StateProvider<StudentFilterState>((ref) => const StudentFilterState());

final studentsListProvider = FutureProvider.autoDispose<PaginatedResult<StudentEntity>>((ref) async {
  final authState = ref.watch(authControllerProvider);
  final schoolId = authState.user?.schoolId;
  if (schoolId == null) return const PaginatedResult(items: [], totalCount: 0, hasMore: false);

  final filter = ref.watch(studentFilterProvider);
  return ref.watch(getStudentsUsecaseProvider).call(
    schoolId: schoolId,
    classId: filter.classId,
    sectionId: filter.sectionId,
    searchQuery: filter.searchQuery,
    pagination: const PaginationParams(pageSize: 50),
  );
});

final studentDetailProvider =
FutureProvider.autoDispose.family<StudentEntity, String>((ref, studentId) async {
  return ref.watch(studentRepositoryProvider).getStudentById(studentId);
});

final linkedParentsProvider =
FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>((ref, studentId) async {
  return ref.watch(studentRepositoryProvider).getLinkedParents(studentId);
});

class StudentFormController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  StudentFormController(this.ref) : super(const AsyncValue.data(null));

  Future<bool> saveStudent(StudentEntity student, {File? photo}) async {
    state = const AsyncValue.loading();
    try {
      final created = await ref.read(createStudentUsecaseProvider).call(student);
      if (photo != null) {
        final url = await ref.read(uploadStudentPhotoUsecaseProvider).call(created.id, photo);
        await ref.read(updateStudentUsecaseProvider).call(
          created.id,
          StudentEntity(
            id: created.id,
            schoolId: created.schoolId,
            fullName: created.fullName,
            studentCode: created.studentCode,
            admissionDate: created.admissionDate,
            status: created.status,
            profileImageUrl: url,
          ),
        );
      }
      ref.invalidate(studentsListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateStudent(String studentId, StudentEntity student) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(updateStudentUsecaseProvider).call(studentId, student);
      ref.invalidate(studentsListProvider);
      ref.invalidate(studentDetailProvider(studentId));
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteStudent(String studentId) async {
    try {
      await ref.read(deleteStudentUsecaseProvider).call(studentId);
      ref.invalidate(studentsListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> transferStudent(String studentId, String newClassId, String newSectionId) async {
    try {
      await ref.read(transferStudentUsecaseProvider).call(
        studentId: studentId,
        newClassId: newClassId,
        newSectionId: newSectionId,
      );
      ref.invalidate(studentsListProvider);
      ref.invalidate(studentDetailProvider(studentId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> linkParent(String studentId, String parentUserId, String relation) async {
    try {
      await ref.read(linkParentUsecaseProvider).call(studentId: studentId, parentUserId: parentUserId, relation: relation);
      ref.invalidate(linkedParentsProvider(studentId));
      return true;
    } catch (_) {
      return false;
    }
  }
}

final studentFormControllerProvider =
StateNotifierProvider<StudentFormController, AsyncValue<void>>((ref) => StudentFormController(ref));