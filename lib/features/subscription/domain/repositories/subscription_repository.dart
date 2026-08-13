import '../entities/subscription_entity.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionPlanEntity>> getPlans();
  Future<SubscriptionPlanEntity> createPlan(SubscriptionPlanEntity plan);
  Future<void> togglePlanActive(String id, bool isActive);

  Future<List<SchoolSubscriptionEntity>> getAllSchoolSubscriptions();
  Future<SchoolSubscriptionEntity?> getSchoolSubscription(String schoolId);
  Future<void> assignPlanToSchool({required String schoolId, required String planId, required int durationDays});
  Future<void> recordPayment({
    required String schoolSubscriptionId,
    required String schoolId,
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
    required String recordedBy,
    required int extendDays,
  });
  Future<void> blockSchool(String schoolId);
  Future<void> unblockSchool(String schoolId);
  Future<void> cancelSubscription(String subscriptionId, String reason);
  Future<SubscriptionOverview> getOverview();
}