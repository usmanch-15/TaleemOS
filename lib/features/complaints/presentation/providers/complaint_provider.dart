import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/complaint_remote_datasource.dart';
import '../../data/repositories/complaint_repository_impl.dart';
import '../../domain/entities/complaint_entity.dart';
import '../../domain/repositories/complaint_repository.dart';

final complaintRemoteDatasourceProvider = Provider<ComplaintRemoteDatasource>((ref) {
  return ComplaintRemoteDatasource(ref.watch(supabaseClientProvider));
});

final complaintRepositoryProvider = Provider<ComplaintRepository>((ref) {
  return ComplaintRepositoryImpl(ref.watch(complaintRemoteDatasourceProvider));
});

final myComplaintsProvider = FutureProvider.autoDispose<List<ComplaintEntity>>((ref) async {
  final userId = ref.watch(authControllerProvider).user?.id;
  if (userId == null) return [];
  return ref.watch(complaintRepositoryProvider).getMyComplaints(userId);
});

final schoolComplaintsFilterProvider = StateProvider<String?>((ref) => null);

final schoolComplaintsProvider = FutureProvider.autoDispose<List<ComplaintEntity>>((ref) async {
  final schoolId = ref.watch(authControllerProvider).user?.schoolId;
  if (schoolId == null) return [];
  final filter = ref.watch(schoolComplaintsFilterProvider);
  return ref.watch(complaintRepositoryProvider).getSchoolComplaints(schoolId: schoolId, statusFilter: filter);
});

final complaintDetailProvider = FutureProvider.autoDispose.family<ComplaintEntity, String>((ref, complaintId) async {
  return ref.watch(complaintRepositoryProvider).getComplaintById(complaintId);
});

final complaintResponsesProvider =
FutureProvider.autoDispose.family<List<ComplaintResponseEntity>, String>((ref, complaintId) async {
  return ref.watch(complaintRepositoryProvider).getResponses(complaintId);
});

class ComplaintController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  ComplaintController(this.ref) : super(const AsyncValue.data(null));

  Future<bool> create(ComplaintEntity complaint) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(complaintRepositoryProvider).createComplaint(complaint);
      ref.invalidate(myComplaintsProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> updateStatus(String complaintId, String status) async {
    await ref.read(complaintRepositoryProvider).updateStatus(complaintId, status);
    ref.invalidate(complaintDetailProvider(complaintId));
    ref.invalidate(schoolComplaintsProvider);
  }

  Future<void> assignTo(String complaintId, String userId) async {
    await ref.read(complaintRepositoryProvider).assignTo(complaintId, userId);
    ref.invalidate(complaintDetailProvider(complaintId));
    ref.invalidate(schoolComplaintsProvider);
  }

  Future<bool> addResponse({required String complaintId, required String message}) async {
    final userId = ref.read(authControllerProvider).user?.id;
    if (userId == null) return false;
    try {
      await ref.read(complaintRepositoryProvider).addResponse(complaintId: complaintId, respondedBy: userId, message: message);
      ref.invalidate(complaintResponsesProvider(complaintId));
      return true;
    } catch (_) {
      return false;
    }
  }
}

final complaintControllerProvider =
StateNotifierProvider<ComplaintController, AsyncValue<void>>((ref) => ComplaintController(ref));