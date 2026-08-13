import 'package:equatable/equatable.dart';

class SubscriptionPlanEntity extends Equatable {
  final String id;
  final String name;
  final double price;
  final int durationDays;
  final List<String> features;
  final int maxStudents;
  final int maxTeachers;
  final bool isTrial;
  final bool isActive;

  const SubscriptionPlanEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.features,
    required this.maxStudents,
    required this.maxTeachers,
    required this.isTrial,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, price, durationDays, maxStudents, maxTeachers, isTrial, isActive];
}

enum SubscriptionStatus { active, expired, cancelled }

extension SubscriptionStatusX on SubscriptionStatus {
  String toDbString() => name;
  static SubscriptionStatus fromString(String value) =>
      SubscriptionStatus.values.firstWhere((e) => e.name == value, orElse: () => SubscriptionStatus.expired);
  String get label {
    switch (this) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.expired:
        return 'Expired';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class SchoolSubscriptionEntity extends Equatable {
  final String id;
  final String schoolId;
  final String schoolName;
  final String? planId;
  final String? planName;
  final double? planPrice;
  final DateTime startDate;
  final DateTime expiryDate;
  final SubscriptionStatus status;
  final bool autoRenew;

  const SchoolSubscriptionEntity({
    required this.id,
    required this.schoolId,
    required this.schoolName,
    this.planId,
    this.planName,
    this.planPrice,
    required this.startDate,
    required this.expiryDate,
    required this.status,
    required this.autoRenew,
  });

  int get daysRemaining => expiryDate.difference(DateTime.now()).inDays;
  bool get isExpiringSoon => daysRemaining <= 7 && daysRemaining >= 0 && status == SubscriptionStatus.active;

  @override
  List<Object?> get props => [id, schoolId, planId, expiryDate, status];
}

class SubscriptionOverview extends Equatable {
  final int activeCount;
  final int expiringSoonCount;
  final int expiredCount;
  final int trialCount;
  final double mrr;

  const SubscriptionOverview({
    required this.activeCount,
    required this.expiringSoonCount,
    required this.expiredCount,
    required this.trialCount,
    required this.mrr,
  });

  @override
  List<Object?> get props => [activeCount, expiringSoonCount, expiredCount, trialCount, mrr];
}