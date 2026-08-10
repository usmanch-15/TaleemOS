import 'package:equatable/equatable.dart';

enum FeeType { admission, tuition, exam, transport, fine, other }

extension FeeTypeX on FeeType {
  String toDbString() => name;

  static FeeType fromString(String value) {
    return FeeType.values.firstWhere((e) => e.name == value, orElse: () => FeeType.other);
  }

  String get label {
    switch (this) {
      case FeeType.admission:
        return 'Admission Fee';
      case FeeType.tuition:
        return 'Tuition Fee';
      case FeeType.exam:
        return 'Exam Fee';
      case FeeType.transport:
        return 'Transport Fee';
      case FeeType.fine:
        return 'Fine';
      case FeeType.other:
        return 'Other';
    }
  }
}

enum FeeFrequency { oneTime, monthly, quarterly, yearly }

extension FeeFrequencyX on FeeFrequency {
  String toDbString() {
    switch (this) {
      case FeeFrequency.oneTime:
        return 'one_time';
      case FeeFrequency.monthly:
        return 'monthly';
      case FeeFrequency.quarterly:
        return 'quarterly';
      case FeeFrequency.yearly:
        return 'yearly';
    }
  }

  static FeeFrequency fromString(String value) {
    switch (value) {
      case 'monthly':
        return FeeFrequency.monthly;
      case 'quarterly':
        return FeeFrequency.quarterly;
      case 'yearly':
        return FeeFrequency.yearly;
      default:
        return FeeFrequency.oneTime;
    }
  }

  String get label {
    switch (this) {
      case FeeFrequency.oneTime:
        return 'One Time';
      case FeeFrequency.monthly:
        return 'Monthly';
      case FeeFrequency.quarterly:
        return 'Quarterly';
      case FeeFrequency.yearly:
        return 'Yearly';
    }
  }
}

class FeeStructureEntity extends Equatable {
  final String id;
  final String schoolId;
  final String? classId;
  final String? className;
  final FeeType feeType;
  final String title;
  final double amount;
  final FeeFrequency frequency;
  final bool isActive;

  const FeeStructureEntity({
    required this.id,
    required this.schoolId,
    this.classId,
    this.className,
    required this.feeType,
    required this.title,
    required this.amount,
    required this.frequency,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, schoolId, classId, feeType, title, amount, frequency, isActive];
}

enum InvoiceStatus { pending, partiallyPaid, paid, overdue, cancelled }

extension InvoiceStatusX on InvoiceStatus {
  String toDbString() {
    switch (this) {
      case InvoiceStatus.pending:
        return 'pending';
      case InvoiceStatus.partiallyPaid:
        return 'partially_paid';
      case InvoiceStatus.paid:
        return 'paid';
      case InvoiceStatus.overdue:
        return 'overdue';
      case InvoiceStatus.cancelled:
        return 'cancelled';
    }
  }

  static InvoiceStatus fromString(String value) {
    switch (value) {
      case 'partially_paid':
        return InvoiceStatus.partiallyPaid;
      case 'paid':
        return InvoiceStatus.paid;
      case 'overdue':
        return InvoiceStatus.overdue;
      case 'cancelled':
        return InvoiceStatus.cancelled;
      default:
        return InvoiceStatus.pending;
    }
  }

  String get label {
    switch (this) {
      case InvoiceStatus.pending:
        return 'Pending';
      case InvoiceStatus.partiallyPaid:
        return 'Partially Paid';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class FeeInvoiceEntity extends Equatable {
  final String id;
  final String schoolId;
  final String studentId;
  final String studentName;
  final String title;
  final double amount;
  final double discount;
  final double fine;
  final double totalPayable;
  final double amountPaid;
  final DateTime dueDate;
  final int? billingMonth;
  final int? billingYear;
  final InvoiceStatus status;

  const FeeInvoiceEntity({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.studentName,
    required this.title,
    required this.amount,
    required this.discount,
    required this.fine,
    required this.totalPayable,
    required this.amountPaid,
    required this.dueDate,
    this.billingMonth,
    this.billingYear,
    required this.status,
  });

  double get balance => totalPayable - amountPaid;

  @override
  List<Object?> get props => [id, schoolId, studentId, title, totalPayable, amountPaid, status];
}

class PaymentEntity extends Equatable {
  final String id;
  final String invoiceId;
  final String studentId;
  final double amount;
  final String paymentMethod;
  final String? referenceNumber;
  final String receiptNumber;
  final DateTime paymentDate;
  final String? notes;

  const PaymentEntity({
    required this.id,
    required this.invoiceId,
    required this.studentId,
    required this.amount,
    required this.paymentMethod,
    this.referenceNumber,
    required this.receiptNumber,
    required this.paymentDate,
    this.notes,
  });

  @override
  List<Object?> get props => [id, invoiceId, studentId, amount, receiptNumber, paymentDate];
}

class FeeCollectionSummary extends Equatable {
  final double totalBilled;
  final double totalCollected;
  final double totalPending;
  final double totalOverdue;

  const FeeCollectionSummary({
    required this.totalBilled,
    required this.totalCollected,
    required this.totalPending,
    required this.totalOverdue,
  });

  double get collectionPercentage => totalBilled == 0 ? 0 : (totalCollected / totalBilled) * 100;

  @override
  List<Object?> get props => [totalBilled, totalCollected, totalPending, totalOverdue];
}
