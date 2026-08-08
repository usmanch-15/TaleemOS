import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/attendance_remote_datasource.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/usecases/attendance_usecases.dart';

final attendanceRemoteDatasourceProvider = Provider<AttendanceRemoteDatasource>((ref) {
  return AttendanceRemoteDatasource(ref.watch(supabaseClientProvider));
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepositoryImpl(ref.watch(attendanceRemoteDatasourceProvider));
});

final markAttendanceUsecaseProvider =
Provider((ref) => MarkAttendanceUsecase(ref.watch(attendanceRepositoryProvider)));
final getClassAttendanceUsecaseProvider =
Provider((ref) => GetClassAttendanceUsecase(ref.watch(attendanceRepositoryProvider)));
final getStudentAttendanceHistoryUsecaseProvider =
Provider((ref) => GetStudentAttendanceHistoryUsecase(ref.watch(attendanceRepositoryProvider)));
final getAttendanceReportUsecaseProvider =
Provider((ref) => GetAttendanceReportUsecase(ref.watch(attendanceRepositoryProvider)));

/// Selected date for the mark-attendance screen
final selectedAttendanceDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Local draft state: studentId -> status, while teacher is marking (before submit)
class AttendanceDraft {
  final Map<String, AttendanceStatus> statusMap;
  final Map<String, String> remarksMap;

  const AttendanceDraft({this.statusMap = const {}, this.remarksMap = const {}});

  AttendanceDraft copyWith({Map<String, AttendanceStatus>? statusMap, Map<String, String>? remarksMap}) {
    return AttendanceDraft(
      statusMap: statusMap ?? this.statusMap,
      remarksMap: remarksMap ?? this.remarksMap,
    );
  }
}

class AttendanceDraftController extends StateNotifier<AttendanceDraft> {
  AttendanceDraftController() : super(const AttendanceDraft());

  void setStatus(String studentId, AttendanceStatus status) {
    final updated = Map<String, AttendanceStatus>.from(state.statusMap);
    updated[studentId] = status;
    state = state.copyWith(statusMap: updated);
  }

  void markAllPresent(List<String> studentIds) {
    final updated = <String, AttendanceStatus>{};
    for (final id in studentIds) {
      updated[id] = AttendanceStatus.present;
    }
    state = state.copyWith(statusMap: updated);
  }

  void setRemark(String studentId, String remark) {
    final updated = Map<String, String>.from(state.remarksMap);
    updated[studentId] = remark;
    state = state.copyWith(remarksMap: updated);
  }

  void reset() => state = const AttendanceDraft();

  void loadExisting(List<AttendanceEntity> records) {
    final statusMap = <String, AttendanceStatus>{};
    final remarksMap = <String, String>{};
    for (final r in records) {
      statusMap[r.studentId] = r.status;
      if (r.remarks != null) remarksMap[r.studentId] = r.remarks!;
    }
    state = AttendanceDraft(statusMap: statusMap, remarksMap: remarksMap);
  }
}

final attendanceDraftProvider =
StateNotifierProvider.autoDispose<AttendanceDraftController, AttendanceDraft>((ref) => AttendanceDraftController());

/// Existing attendance for the selected class/section/subject/date (to detect if already marked)
final existingAttendanceProvider = FutureProvider.autoDispose
    .family<List<AttendanceEntity>, ({String classId, String? sectionId, String? subjectId, DateTime date})>(
        (ref, params) async {
      return ref.watch(getClassAttendanceUsecaseProvider).call(
        classId: params.classId,
        sectionId: params.sectionId,
        subjectId: params.subjectId,
        date: params.date,
      );
    });

class AttendanceSubmitController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  AttendanceSubmitController(this.ref) : super(const AsyncValue.data(null));

  Future<bool> submit({
    required String classId,
    String? sectionId,
    String? subjectId,
    required DateTime date,
  }) async {
    final authState = ref.read(authControllerProvider);
    final schoolId = authState.user?.schoolId;
    final userId = authState.user?.id;
    if (schoolId == null || userId == null) return false;

    final draft = ref.read(attendanceDraftProvider);
    if (draft.statusMap.isEmpty) return false;

    state = const AsyncValue.loading();
    try {
      final statusStringMap = draft.statusMap.map((k, v) => MapEntry(k, v.toDbString()));
      await ref.read(markAttendanceUsecaseProvider).call(
        schoolId: schoolId,
        classId: classId,
        sectionId: sectionId,
        subjectId: subjectId,
        date: date,
        markedBy: userId,
        studentStatusMap: statusStringMap,
        remarksMap: draft.remarksMap,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final attendanceSubmitControllerProvider =
StateNotifierProvider.autoDispose<AttendanceSubmitController, AsyncValue<void>>(
        (ref) => AttendanceSubmitController(ref));

/// Parent/Student: monthly attendance
final selectedAttendanceMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

final studentAttendanceHistoryProvider =
FutureProvider.autoDispose.family<List<AttendanceEntity>, String>((ref, studentId) async {
  final month = ref.watch(selectedAttendanceMonthProvider);
  return ref.watch(getStudentAttendanceHistoryUsecaseProvider).call(
    studentId: studentId,
    month: month.month,
    year: month.year,
  );
});

final studentAttendancePercentageProvider =
FutureProvider.autoDispose.family<double, String>((ref, studentId) async {
  final month = ref.watch(selectedAttendanceMonthProvider);
  final repo = ref.watch(attendanceRepositoryProvider);
  return repo.getStudentAttendancePercentage(studentId: studentId, month: month.month, year: month.year);
});

/// Admin: low attendance report
final lowAttendanceStudentsProvider = FutureProvider.autoDispose<List<LowAttendanceStudent>>((ref) async {
  final schoolId = ref.watch(authControllerProvider).user?.schoolId;
  if (schoolId == null) return [];
  final month = ref.watch(selectedAttendanceMonthProvider);
  return ref.watch(getAttendanceReportUsecaseProvider).lowAttendanceStudents(
    schoolId: schoolId,
    month: month.month,
    year: month.year,
  );
});