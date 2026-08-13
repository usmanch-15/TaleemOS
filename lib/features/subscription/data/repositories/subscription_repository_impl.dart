import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_datasource.dart';
import '../models/subscription_models.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDatasource remote;
  SubscriptionRepositoryImpl(this.remote);

  @override
  Future<List<SubscriptionPlanEntity>> getPlans() => remote.getPlans();

  @override
  Future<SubscriptionPlanEntity> createPlan(SubscriptionPlanEntity plan) {
    final model = SubscriptionPlanModel(
      id: plan.id,
      name: plan.name,
      price: plan.price,
      durationDays: plan.durationDays,
      features: plan.features,
      maxStudents: plan.maxStudents,
      maxTeachers: plan.maxTeachers,
      isTrial: plan.isTrial,
      isActive: plan.isActive,
    );
    return remote.createPlan(model);
  }

  @override
  Future<void> togglePlanActive(String id, bool isActive) => remote.togglePlanActive(id, isActive);

  @override
  Future<List<SchoolSubscriptionEntity>> getAllSchoolSubscriptions() => remote.getAllSchoolSubscriptions();

  @override
  Future<SchoolSubscriptionEntity?> getSchoolSubscription(String schoolId) => remote.getSchoolSubscription(schoolId);

  @override
  Future<void> assignPlanToSchool({required String schoolId, required String planId, required int durationDays}) {
    return remote.assignPlanToSchool(schoolId: schoolId, planId: planId, durationDays: durationDays);
  }

  @override
  Future<void> recordPayment({
    required String schoolSubscriptionId,
    required String schoolId,
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
    required String recordedBy,
    required int extendDays,
  }) {
    return remote.recordPayment(
      schoolSubscriptionId: schoolSubscriptionId,
      schoolId: schoolId,
      amount: amount,
      paymentMethod: paymentMethod,
      referenceNumber: referenceNumber,
      recordedBy: recordedBy,
      extendDays: extendDays,
    );
  }

  @override
  Future<void> blockSchool(String schoolId) => remote.blockSchool(schoolId);

  @override
  Future<void> unblockSchool(String schoolId) => remote.unblockSchool(schoolId);

  @override
  Future<void> cancelSubscription(String subscriptionId, String reason) =>
      remote.cancelSubscription(subscriptionId, reason);

  @override
  Future<SubscriptionOverview> getOverview() => remote.getOverview();
}