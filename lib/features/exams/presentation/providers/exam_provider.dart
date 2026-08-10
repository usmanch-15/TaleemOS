import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/exam_remote_datasource.dart';
import '../../data/repositories/exam_repository_impl.dart';
import '../../domain/entities/exam_entity.dart';
import '../../domain/entities/result_entity.dart';
import '../../domain/repositories/exam_repository.dart';
import '../../domain/usecases/exam_usecases.dart';

final examRemoteDatasourceProvider = Provider<ExamRemoteDatasource>((ref) {
  return ExamRemoteDatasource(ref.watch(supabaseClientProvider));
});

final examRepositoryProvider = Provider<ExamRepository>((ref) {
  return ExamRepositoryImpl(ref.watch(examRemoteDatasourceProvider));
});

final createExamUsecaseProvider = Provider((ref) => CreateExamUsecase(ref.watch(examRepositoryProvider)));
final addExamSubjectUsecaseProvider = Provider((ref) => AddExamSubjectUsecase(ref.watch(examRepositoryProvider)));
final saveMarksUsecaseProvider = Provider((ref) => SaveMarksUsecase(ref.watch(examRepositoryProvider)));
final publishExamUsecaseProvider = Provider((ref) => PublishExamUsecase(ref.watch(examRepositoryProvider)));
final getReportCardUsecaseProvider = Provider((ref) => GetReportCardUsecase(ref.watch(examRepositoryProvider)));

final examsListProvider = FutureProvider.autoDispose<List<ExamEntity>>((ref) async {
  final schoolId = ref.watch(authControllerProvider).user?.schoolId;
  if (schoolId == null) return [];
  return ref.watch(examRepositoryProvider).getExamsForSchool(schoolId);
});

final examDetailProvider = FutureProvider.autoDispose.family<ExamEntity, String>((ref, examId) async {
  return ref.watch(examRepositoryProvider).getExamById(examId);
});

final marksSheetProvider = FutureProvider.autoDispose
    .family<List<ResultEntity>, ({String examSubjectId, String classId, String? sectionId})>((ref, params) async {
  return ref.watch(examRepositoryProvider).getMarksSheet(
    examSubjectId: params.examSubjectId,
    classId: params.classId,
    sectionId: params.sectionId,
  );
});

final classExamSummariesProvider =
FutureProvider.autoDispose.family<List<ExamSummaryEntity>, String>((ref, examId) async {
  return ref.watch(examRepositoryProvider).getClassExamSummaries(examId);
});

final publishedExamsForClassProvider =
FutureProvider.autoDispose.family<List<ExamEntity>, String>((ref, classId) async {
  return ref.watch(examRepositoryProvider).getPublishedExamsForClass(classId);
});

final studentExamSummariesProvider =
FutureProvider.autoDispose.family<List<ExamSummaryEntity>, String>((ref, studentId) async {
  return ref.watch(examRepositoryProvider).getStudentAllExamSummaries(studentId);
});

class ExamManagementController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  ExamManagementController(this.ref) : super(const AsyncValue.data(null));

  Future<String?> createExam(ExamEntity exam) async {
    state = const AsyncValue.loading();
    try {
      final created = await ref.read(createExamUsecaseProvider).call(exam);
      ref.invalidate(examsListProvider);
      state = const AsyncValue.data(null);
      return created.id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> addSubject({
    required String examId,
    required String subjectId,
    required double totalMarks,
    required double passingMarks,
  }) async {
    try {
      await ref.read(addExamSubjectUsecaseProvider).call(
        examId: examId,
        subjectId: subjectId,
        totalMarks: totalMarks,
        passingMarks: passingMarks,
      );
      ref.invalidate(examDetailProvider(examId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> saveMarks({
    required String examId,
    required String examSubjectId,
    required Map<String, double?> marks,
  }) async {
    final authState = ref.read(authControllerProvider);
    final schoolId = authState.user?.schoolId;
    final userId = authState.user?.id;
    if (schoolId == null || userId == null) return false;

    state = const AsyncValue.loading();
    try {
      await ref.read(saveMarksUsecaseProvider).call(
        examId: examId,
        examSubjectId: examSubjectId,
        schoolId: schoolId,
        enteredBy: userId,
        studentMarksMap: marks,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> publishExam(String examId) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(publishExamUsecaseProvider).call(examId);
      ref.invalidate(examsListProvider);
      ref.invalidate(examDetailProvider(examId));
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> deleteExam(String examId) async {
    await ref.read(examRepositoryProvider).deleteExam(examId);
    ref.invalidate(examsListProvider);
  }
}

final examManagementControllerProvider =
StateNotifierProvider<ExamManagementController, AsyncValue<void>>((ref) => ExamManagementController(ref));