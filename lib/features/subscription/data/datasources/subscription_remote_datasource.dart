import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subscription_models.dart';

class SubscriptionRemoteDatasource {
  final SupabaseClient client;
  SubscriptionRemoteDatasource(this.client);

  Future<List<SubscriptionPlanModel>> getPlans() async {
    final data = await client.from('subscription_plans').select().order('price');
    return (data as List).map((e) => SubscriptionPlanModel.fromMap(e)).toList();
  }

  Future<SubscriptionPlanModel> createPlan(SubscriptionPlanModel plan) async {
    final data = await client.from('subscription_plans').insert(plan.toInsertMap()).select().single();
    return SubscriptionPlanModel.fromMap(data);
  }

  Future<void> togglePlanActive(String id, bool isActive) async {
    await client.from('subscription_plans').update({'is_active': isActive}).eq('id', id);
  }

  Future<List<SchoolSubscriptionModel>> getAllSchoolSubscriptions() async {
    final data = await client
        .from('school_subscriptions')
        .select('*, schools(name), subscription_plans(name, price)')
        .order('created_at', ascending: false);

    // Keep only the latest subscription per school
    final Map<String, Map<String, dynamic>> latestBySchool = {};
    for (final row in data as List) {
      final schoolId = row['school_id'] as String;
      if (!latestBySchool.containsKey(schoolId)) {
        latestBySchool[schoolId] = row as Map<String, dynamic>;
      }
    }
    return latestBySchool.values.map((e) => SchoolSubscriptionModel.fromMap(e)).toList();
  }

  Future<SchoolSubscriptionModel?> getSchoolSubscription(String schoolId) async {
    final data = await client
        .from('school_subscriptions')
        .select('*, schools(name), subscription_plans(name, price)')
        .eq('school_id', schoolId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (data == null) return null;
    return SchoolSubscriptionModel.fromMap(data);
  }

  Future<void> assignPlanToSchool({
    required String schoolId,
    required String planId,
    required int durationDays,
  }) async {
    final expiryDate = DateTime.now().add(Duration(days: durationDays));
    await client.from('school_subscriptions').insert({
      'school_id': schoolId,
      'plan_id': planId,
      'start_date': DateTime.now().toIso8601String().split('T')[0],
      'expiry_date': expiryDate.toIso8601String().split('T')[0],
      'status': 'active',
    });
    await client.from('schools').update({'status': 'active'}).eq('id', schoolId);
  }

  Future<void> recordPayment({
    required String schoolSubscriptionId,
    required String schoolId,
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
    required String recordedBy,
    required int extendDays,
  }) async {
    await client.rpc('record_subscription_payment', params: {
      'p_school_subscription_id': schoolSubscriptionId,
      'p_school_id': schoolId,
      'p_amount': amount,
      'p_payment_method': paymentMethod,
      'p_reference_number': referenceNumber,
      'p_recorded_by': recordedBy,
      'p_extend_days': extendDays,
    });
  }

  Future<void> blockSchool(String schoolId) async {
    await client.from('schools').update({'status': 'blocked'}).eq('id', schoolId);
  }

  Future<void> unblockSchool(String schoolId) async {
    await client.from('schools').update({'status': 'active'}).eq('id', schoolId);
  }

  Future<void> cancelSubscription(String subscriptionId, String reason) async {
    await client.from('school_subscriptions').update({
      'status': 'cancelled',
      'cancelled_at': DateTime.now().toIso8601String(),
      'cancellation_reason': reason,
    }).eq('id', subscriptionId);
  }

  Future<SubscriptionOverviewModel> getOverview() async {
    final result = await client.rpc('get_subscription_overview');
    final row = (result as List).first as Map<String, dynamic>;
    return SubscriptionOverviewModel.fromMap(row);
  }
}