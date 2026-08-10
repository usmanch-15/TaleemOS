import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/fee_remote_datasource.dart';
import '../../data/repositories/fee_repository_impl.dart';
import '../../domain/entities/fee_entity.dart';
import '../../domain/repositories/fee_repository.dart';
import '../../domain/usecases/fee_usecases.dart';

final feeRemoteDatasourceProvider = Provider<FeeRemoteDatasource>((ref) {
  return FeeRemoteDatasource(ref.watch(supabaseClientProvider));
});

final feeRepositoryProvider = Provider<FeeRepository>((ref) {
  return FeeRepositoryImpl(ref.watch(feeRemoteDatasourceProvider));
});

final createFeeStructureUsecaseProvider = Provider((ref) => CreateFeeStructureUsecase(ref.watch(feeRepositoryProvider)));
final generateMonthlyInvoicesUsecaseProvider =
Provider((ref) => GenerateMonthlyInvoicesUsecase(ref.watch(feeRepositoryProvider)));
final recordPaymentUsecaseProvider = Provider((ref) => RecordPaymentUsecase(ref.watch(feeRepositoryProvider)));
final getPendingFeesReportUsecaseProvider =
Provider((ref) => GetPendingFeesReportUsecase(ref.watch(feeRepositoryProvider)));

final feeStructuresProvider = FutureProvider.autoDispose<List<FeeStructureEntity>>((ref) async {
  final schoolId = ref.watch(authControllerProvider).user?.schoolId;
  if (schoolId == null) return [];
  return ref.watch(feeRepositoryProvider).getFeeStructures(schoolId);
});

final schoolInvoicesFilterProvider = StateProvider<String?>((ref) => null);

final schoolInvoicesProvider = FutureProvider.autoDispose<List<FeeInvoiceEntity>>((ref) async {
  final schoolId = ref.watch(authControllerProvider).user?.schoolId;
  if (schoolId == null) return [];
  final statusFilter = ref.watch(schoolInvoicesFilterProvider);
  return ref.watch(feeRepositoryProvider).getSchoolInvoices(schoolId: schoolId, statusFilter: statusFilter);
});

final invoiceDetailProvider = FutureProvider.autoDispose.family<FeeInvoiceEntity, String>((ref, invoiceId) async {
  return ref.watch(feeRepositoryProvider).getInvoiceById(invoiceId);
});

final invoicePaymentsProvider =
FutureProvider.autoDispose.family<List<PaymentEntity>, String>((ref, invoiceId) async {
  return ref.watch(feeRepositoryProvider).getInvoicePayments(invoiceId);
});

final studentInvoicesProvider = FutureProvider.autoDispose.family<List<FeeInvoiceEntity>, String>((ref, studentId) async {
  return ref.watch(feeRepositoryProvider).getStudentInvoices(studentId);
});

final studentPaymentHistoryProvider =
FutureProvider.autoDispose.family<List<PaymentEntity>, String>((ref, studentId) async {
  return ref.watch(feeRepositoryProvider).getStudentPaymentHistory(studentId);
});

final selectedFeeMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

final collectionSummaryProvider = FutureProvider.autoDispose<FeeCollectionSummary?>((ref) async {
  final schoolId = ref.watch(authControllerProvider).user?.schoolId;
  if (schoolId == null) return null;
  final month = ref.watch(selectedFeeMonthProvider);
  return ref.watch(feeRepositoryProvider).getCollectionSummary(schoolId: schoolId, month: month.month, year: month.year);
});

final pendingFeesReportProvider = FutureProvider.autoDispose<List<FeeInvoiceEntity>>((ref) async {
  final schoolId = ref.watch(authControllerProvider).user?.schoolId;
  if (schoolId == null) return [];
  return ref.watch(getPendingFeesReportUsecaseProvider).call(schoolId);
});

// ---- Controllers ----
class FeeStructureController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  FeeStructureController(this.ref) : super(const AsyncValue.data(null));

  Future<bool> create(FeeStructureEntity structure) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(createFeeStructureUsecaseProvider).call(structure);
      ref.invalidate(feeStructuresProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> toggleActive(String id, bool isActive) async {
    await ref.read(feeRepositoryProvider).toggleFeeStructureActive(id, isActive);
    ref.invalidate(feeStructuresProvider);
  }

  Future<void> delete(String id) async {
    await ref.read(feeRepositoryProvider).deleteFeeStructure(id);
    ref.invalidate(feeStructuresProvider);
  }
}

final feeStructureControllerProvider =
StateNotifierProvider<FeeStructureController, AsyncValue<void>>((ref) => FeeStructureController(ref));

class InvoiceGenerationController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  InvoiceGenerationController(this.ref) : super(const AsyncValue.data(null));

  Future<int?> generateForMonth({required int month, required int year, required DateTime dueDate}) async {
    final schoolId = ref.read(authControllerProvider).user?.schoolId;
    if (schoolId == null) return null;

    state = const AsyncValue.loading();
    try {
      final count = await ref.read(generateMonthlyInvoicesUsecaseProvider).call(
        schoolId: schoolId,
        month: month,
        year: year,
        dueDate: dueDate,
      );
      ref.invalidate(schoolInvoicesProvider);
      state = const AsyncValue.data(null);
      return count;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final invoiceGenerationControllerProvider =
StateNotifierProvider<InvoiceGenerationController, AsyncValue<void>>((ref) => InvoiceGenerationController(ref));

class PaymentController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  PaymentController(this.ref) : super(const AsyncValue.data(null));

  Future<PaymentEntity?> recordPayment({
    required String invoiceId,
    required String studentId,
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
    String? notes,
  }) async {
    final authState = ref.read(authControllerProvider);
    final schoolId = authState.user?.schoolId;
    final userId = authState.user?.id;
    if (schoolId == null || userId == null) return null;

    state = const AsyncValue.loading();
    try {
      final payment = await ref.read(recordPaymentUsecaseProvider).call(
        schoolId: schoolId,
        invoiceId: invoiceId,
        studentId: studentId,
        amount: amount,
        paymentMethod: paymentMethod,
        referenceNumber: referenceNumber,
        collectedBy: userId,
        notes: notes,
      );
      ref.invalidate(invoiceDetailProvider(invoiceId));
      ref.invalidate(invoicePaymentsProvider(invoiceId));
      ref.invalidate(schoolInvoicesProvider);
      ref.invalidate(studentInvoicesProvider(studentId));
      state = const AsyncValue.data(null);
      return payment;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

final paymentControllerProvider =
StateNotifierProvider<PaymentController, AsyncValue<void>>((ref) => PaymentController(ref));