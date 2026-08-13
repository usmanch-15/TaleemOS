import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/subscription_remote_datasource.dart';
import '../../data/datasources/support_ticket_remote_datasource.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/subscription_repository.dart';

final subscriptionRemoteDatasourceProvider = Provider<SubscriptionRemoteDatasource>((ref) {
  return SubscriptionRemoteDatasource(ref.watch(supabaseClientProvider));
});

final supportTicketRemoteDatasourceProvider = Provider<SupportTicketRemoteDatasource>((ref) {
  return SupportTicketRemoteDatasource(ref.watch(supabaseClientProvider));
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepositoryImpl(ref.watch(subscriptionRemoteDatasourceProvider));
});

final subscriptionPlansProvider = FutureProvider.autoDispose<List<SubscriptionPlanEntity>>((ref) async {
  return ref.watch(subscriptionRepositoryProvider).getPlans();
});

final allSchoolSubscriptionsProvider = FutureProvider.autoDispose<List<SchoolSubscriptionEntity>>((ref) async {
  return ref.watch(subscriptionRepositoryProvider).getAllSchoolSubscriptions();
});

final mySchoolSubscriptionProvider = FutureProvider.autoDispose<SchoolSubscriptionEntity?>((ref) async {
  final schoolId = ref.watch(authControllerProvider).user?.schoolId;
  if (schoolId == null) return null;
  return ref.watch(subscriptionRepositoryProvider).getSchoolSubscription(schoolId);
});

final subscriptionOverviewProvider = FutureProvider.autoDispose<SubscriptionOverview>((ref) async {
  return ref.watch(subscriptionRepositoryProvider).getOverview();
});

class SubscriptionManagementController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  SubscriptionManagementController(this.ref) : super(const AsyncValue.data(null));

  Future<bool> createPlan(SubscriptionPlanEntity plan) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(subscriptionRepositoryProvider).createPlan(plan);
      ref.invalidate(subscriptionPlansProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> togglePlan(String id, bool isActive) async {
    await ref.read(subscriptionRepositoryProvider).togglePlanActive(id, isActive);
    ref.invalidate(subscriptionPlansProvider);
  }

  Future<bool> assignPlan({required String schoolId, required String planId, required int durationDays}) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(subscriptionRepositoryProvider).assignPlanToSchool(
        schoolId: schoolId,
        planId: planId,
        durationDays: durationDays,
      );
      ref.invalidate(allSchoolSubscriptionsProvider);
      ref.invalidate(subscriptionOverviewProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> recordPayment({
    required String schoolSubscriptionId,
    required String schoolId,
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
    required int extendDays,
  }) async {
    final userId = ref.read(authControllerProvider).user?.id;
    if (userId == null) return false;

    state = const AsyncValue.loading();
    try {
      await ref.read(subscriptionRepositoryProvider).recordPayment(
        schoolSubscriptionId: schoolSubscriptionId,
        schoolId: schoolId,
        amount: amount,
        paymentMethod: paymentMethod,
        referenceNumber: referenceNumber,
        recordedBy: userId,
        extendDays: extendDays,
      );
      ref.invalidate(allSchoolSubscriptionsProvider);
      ref.invalidate(subscriptionOverviewProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> toggleBlock(String schoolId, bool block) async {
    if (block) {
      await ref.read(subscriptionRepositoryProvider).blockSchool(schoolId);
    } else {
      await ref.read(subscriptionRepositoryProvider).unblockSchool(schoolId);
    }
    ref.invalidate(allSchoolSubscriptionsProvider);
  }

  Future<void> cancelSubscription(String subscriptionId, String reason) async {
    await ref.read(subscriptionRepositoryProvider).cancelSubscription(subscriptionId, reason);
    ref.invalidate(allSchoolSubscriptionsProvider);
    ref.invalidate(subscriptionOverviewProvider);
  }
}

final subscriptionManagementControllerProvider =
StateNotifierProvider<SubscriptionManagementController, AsyncValue<void>>(
        (ref) => SubscriptionManagementController(ref));

// ---- Support Tickets ----
final myTicketsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final userId = ref.watch(authControllerProvider).user?.id;
  if (userId == null) return [];
  return ref.watch(supportTicketRemoteDatasourceProvider).getMyTickets(userId);
});

final ticketFilterProvider = StateProvider<String?>((ref) => null);

final allTicketsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final filter = ref.watch(ticketFilterProvider);
  return ref.watch(supportTicketRemoteDatasourceProvider).getAllTickets(statusFilter: filter);
});

final ticketDetailProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, ticketId) async {
  return ref.watch(supportTicketRemoteDatasourceProvider).getTicketById(ticketId);
});

final ticketResponsesProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>((ref, ticketId) async {
  final role = ref.watch(authControllerProvider).user?.role.toDbString();
  return ref.watch(supportTicketRemoteDatasourceProvider).getResponses(ticketId, includeInternal: role == 'super_admin');
});

class SupportTicketController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  SupportTicketController(this.ref) : super(const AsyncValue.data(null));

  Future<bool> createTicket({
    required String subject,
    required String description,
    required String category,
    required String priority,
  }) async {
    final authState = ref.read(authControllerProvider);
    final schoolId = authState.user?.schoolId;
    final userId = authState.user?.id;
    if (schoolId == null || userId == null) return false;

    state = const AsyncValue.loading();
    try {
      await ref.read(supportTicketRemoteDatasourceProvider).createTicket(
        schoolId: schoolId,
        raisedBy: userId,
        subject: subject,
        description: description,
        category: category,
        priority: priority,
      );
      ref.invalidate(myTicketsProvider);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> updateStatus(String ticketId, String status) async {
    await ref.read(supportTicketRemoteDatasourceProvider).updateStatus(ticketId, status);
    ref.invalidate(ticketDetailProvider(ticketId));
    ref.invalidate(allTicketsProvider);
  }

  Future<bool> addResponse({required String ticketId, required String message, bool isInternal = false}) async {
    final userId = ref.read(authControllerProvider).user?.id;
    if (userId == null) return false;
    try {
      await ref.read(supportTicketRemoteDatasourceProvider).addResponse(
        ticketId: ticketId,
        respondedBy: userId,
        message: message,
        isInternalNote: isInternal,
      );
      ref.invalidate(ticketResponsesProvider(ticketId));
      return true;
    } catch (_) {
      return false;
    }
  }
}

final supportTicketControllerProvider =
StateNotifierProvider<SupportTicketController, AsyncValue<void>>((ref) => SupportTicketController(ref));