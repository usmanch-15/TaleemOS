import '../../domain/entities/subscription_entity.dart';

class SubscriptionPlanModel extends SubscriptionPlanEntity {
  const SubscriptionPlanModel({
    required super.id,
    required super.name,
    required super.price,
    required super.durationDays,
    required super.features,
    required super.maxStudents,
    required super.maxTeachers,
    required super.isTrial,
    required super.isActive,
  });

  factory SubscriptionPlanModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionPlanModel(
      id: map['id'] as String,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      durationDays: map['duration_days'] as int,
      features: (map['features'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      maxStudents: map['max_students'] as int? ?? 500,
      maxTeachers: map['max_teachers'] as int? ?? 50,
      isTrial: map['is_trial'] as bool? ?? false,
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'name': name,
      'price': price,
      'duration_days': durationDays,
      'features': features,
      'max_students': maxStudents,
      'max_teachers': maxTeachers,
      'is_trial': isTrial,
      'is_active': isActive,
    };
  }
}

class SchoolSubscriptionModel extends SchoolSubscriptionEntity {
  const SchoolSubscriptionModel({
    required super.id,
    required super.schoolId,
    required super.schoolName,
    super.planId,
    super.planName,
    super.planPrice,
    required super.startDate,
    required super.expiryDate,
    required super.status,
    required super.autoRenew,
  });

  factory SchoolSubscriptionModel.fromMap(Map<String, dynamic> map) {
    final school = map['schools'] as Map<String, dynamic>?;
    final plan = map['subscription_plans'] as Map<String, dynamic>?;

    return SchoolSubscriptionModel(
      id: map['id'] as String,
      schoolId: map['school_id'] as String,
      schoolName: school?['name'] as String? ?? '',
      planId: map['plan_id'] as String?,
      planName: plan?['name'] as String?,
      planPrice: (plan?['price'] as num?)?.toDouble(),
      startDate: DateTime.parse(map['start_date'] as String),
      expiryDate: DateTime.parse(map['expiry_date'] as String),
      status: SubscriptionStatusX.fromString(map['status'] as String),
      autoRenew: map['auto_renew'] as bool? ?? false,
    );
  }
}

class SubscriptionOverviewModel extends SubscriptionOverview {
  const SubscriptionOverviewModel({
    required super.activeCount,
    required super.expiringSoonCount,
    required super.expiredCount,
    required super.trialCount,
    required super.mrr,
  });

  factory SubscriptionOverviewModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionOverviewModel(
      activeCount: (map['active_count'] as num?)?.toInt() ?? 0,
      expiringSoonCount: (map['expiring_soon_count'] as num?)?.toInt() ?? 0,
      expiredCount: (map['expired_count'] as num?)?.toInt() ?? 0,
      trialCount: (map['trial_count'] as num?)?.toInt() ?? 0,
      mrr: (map['mrr'] as num?)?.toDouble() ?? 0,
    );
  }
}