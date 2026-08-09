import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../school/presentation/providers/school_provider.dart';
import '../../data/datasources/homework_remote_datasource.dart';
import '../../data/repositories/homework_repository_impl.dart';
import '../../domain/entities/homework_entity.dart';
import '../../domain/repositories/homework_repository.dart';
import '../../domain/usecases/homework_usecases.dart';

final homeworkRemoteDatasourceProvider = Provider<HomeworkRemoteDatasource>((ref) {
  return HomeworkRemoteDatasource(ref.watch(supabaseClientProvider), ref.watch(imagePickerServiceProvider));
});

final homeworkRepositoryProvider = Provider<HomeworkRepository>((ref) {
  return HomeworkRepositoryImpl(ref.watch(homeworkRemoteDatasourceProvider));
});

final createHomeworkUsecaseProvider = Provider((ref) => CreateHomeworkUsecase(ref.watch(homeworkRepositoryProvider)));
final publishHomeworkUsecaseProvider = Provider((ref) => PublishHomeworkUsecase(ref.watch(homeworkRepositoryProvider)));
final getTeacherHomeworkUsecaseProvider =
Provider((ref) => GetTeacherHomeworkUsecase(ref.watch(homeworkRepositoryProvider)));
final getStudentHomeworkUsecaseProvider =
Provider((ref) => GetStudentHomeworkUsecase(ref.watch(homeworkRepositoryProvider)));
final submitHomeworkUsecaseProvider = Provider((ref) => SubmitHomeworkUsecase(ref.watch(homeworkRepositoryProvider)));
final gradeSubmissionUsecaseProvider = Provider((ref) => GradeSubmissionUsecase(ref.watch(homeworkRepositoryProvider)));

// ---- Teacher: list of own homework ----
final teacherHomeworkListProvider = FutureProvider.autoDispose.family<List<HomeworkEntity>, String>((ref, teacherId) async {
  return ref.watch(getTeacherHomeworkUsecaseProvider).call(teacherId);
});

// ---- Homework detail ----
final homeworkDetailProvider = FutureProvider.autoDispose.family<HomeworkEntity, String>((ref, homeworkId) async {
  return ref.watch(homeworkRepositoryProvider).getHomeworkById(homeworkId);
});

// ---- Submissions for a homework (teacher checking) ----
final homeworkSubmissionsProvider =
FutureProvider.autoDispose.family<List<SubmissionEntity>, String>((ref, homeworkId) async {
  return ref.watch(homeworkRepositoryProvider).getSubmissionsForHomework(homeworkId);
});

final homeworkCompletionStatsProvider =
FutureProvider.autoDispose.family<HomeworkCompletionStats, String>((ref, homeworkId) async {
  return ref.watch(homeworkRepositoryProvider).getCompletionStats(homeworkId);
});

// ---- Student: homework list for their class ----
final studentHomeworkListProvider = FutureProvider.autoDispose<List<HomeworkEntity>>((ref) async {
  final authState = ref.watch(authControllerProvider);
  final schoolId = authState.user?.schoolId;
  if (schoolId == null) return [];

  // Fetch the student's own record to know classId/sectionId
  final studentData = await ref
      .watch(supabaseClientProvider)
      .from('students')
      .select('id, class_id, section_id')
      .eq('user_id', authState.user!.id)
      .maybeSingle();

  if (studentData == null) return [];
  return ref.watch(getStudentHomeworkUsecaseProvider).call(
    classId: studentData['class_id'] as String,
    sectionId: studentData['section_id'] as String?,
  );
});

// ---- Student: own submission for a specific homework ----
final myStudentIdProvider = FutureProvider.autoDispose<String?>((ref) async {
  final authState = ref.watch(authControllerProvider);
  if (authState.user == null) return null;
  final data = await ref
      .watch(supabaseClientProvider)
      .from('students')
      .select('id')
      .eq('user_id', authState.user!.id)
      .maybeSingle();
  return data?['id'] as String?;
});

final studentSubmissionProvider =
FutureProvider.autoDispose.family<SubmissionEntity?, String>((ref, homeworkId) async {
  final studentId = await ref.watch(myStudentIdProvider.future);
  if (studentId == null) return null;
  return ref.watch(homeworkRepositoryProvider).getStudentSubmission(homeworkId: homeworkId, studentId: studentId);
});

// ---- Parent: child's all submissions ----
final childSubmissionsProvider =
FutureProvider.autoDispose.family<List<SubmissionEntity>, String>((ref, studentId) async {
  return ref.watch(homeworkRepositoryProvider).getStudentAllSubmissions(studentId);
});

// ---- Controllers ----
class HomeworkFormController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  HomeworkFormController(this.ref) : super(const AsyncValue.data(null));

  Future<bool> createAndPublish(HomeworkEntity homework, {File? attachment, required bool publishNow}) async {
    state = const AsyncValue.loading();
    try {
      final created = await ref.read(createHomeworkUsecaseProvider).call(homework);

      String? attachmentUrl;
      String? attachmentName;
      if (attachment != null) {
        attachmentUrl = await ref
            .read(homeworkRepositoryProvider)
            .uploadAttachment(homeworkId: created.id, file: attachment, bucket: 'homework-attachments');
        attachmentName = attachment.path.split('/').last;
        await ref.read(homeworkRepositoryProvider).updateHomework(
          created.id,
          HomeworkEntity(
            id: created.id,
            schoolId: created.schoolId,
            classId: created.classId,
            className: created.className,
            sectionId: created.sectionId,
            subjectId: created.subjectId,
            subjectName: created.subjectName,
            teacherId: created.teacherId,
            title: created.title,
            description: created.description,
            dueDate: created.dueDate,
            totalMarks: created.totalMarks,
            instructions: created.instructions,
            attachmentUrl: attachmentUrl,
            attachmentName: attachmentName,
            status: created.status,
            createdAt: created.createdAt,
          ),
        );
      }

      if (publishNow) {
        await ref.read(publishHomeworkUsecaseProvider).call(created.id);
      }

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> publish(String homeworkId, String teacherId) async {
    try {
      await ref.read(publishHomeworkUsecaseProvider).call(homeworkId);
      ref.invalidate(teacherHomeworkListProvider(teacherId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteHomework(String homeworkId, String teacherId) async {
    try {
      await ref.read(homeworkRepositoryProvider).deleteHomework(homeworkId);
      ref.invalidate(teacherHomeworkListProvider(teacherId));
      return true;
    } catch (_) {
      return false;
    }
  }
}

final homeworkFormControllerProvider =
StateNotifierProvider<HomeworkFormController, AsyncValue<void>>((ref) => HomeworkFormController(ref));

class SubmissionController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  SubmissionController(this.ref) : super(const AsyncValue.data(null));

  Future<bool> submit({
    required String homeworkId,
    String? textAnswer,
    File? attachmentFile,
  }) async {
    final studentId = await ref.read(myStudentIdProvider.future);
    if (studentId == null) return false;

    state = const AsyncValue.loading();
    try {
      await ref.read(submitHomeworkUsecaseProvider).call(
        homeworkId: homeworkId,
        studentId: studentId,
        textAnswer: textAnswer,
        attachmentFile: attachmentFile,
      );
      ref.invalidate(studentSubmissionProvider(homeworkId));
      ref.invalidate(studentHomeworkListProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> gradeSubmission({
    required String submissionId,
    required double obtainedMarks,
    String? feedback,
    required String homeworkId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(gradeSubmissionUsecaseProvider).call(
        submissionId: submissionId,
        obtainedMarks: obtainedMarks,
        feedback: feedback,
      );
      ref.invalidate(homeworkSubmissionsProvider(homeworkId));
      ref.invalidate(homeworkCompletionStatsProvider(homeworkId));
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> returnSubmission(String submissionId, String homeworkId) async {
    await ref.read(homeworkRepositoryProvider).returnSubmission(submissionId);
    ref.invalidate(homeworkSubmissionsProvider(homeworkId));
  }
}

final submissionControllerProvider =
StateNotifierProvider<SubmissionController, AsyncValue<void>>((ref) => SubmissionController(ref));