import '../../domain/entities/fee_entity.dart';

class FeeStructureModel extends FeeStructureEntity {
  const FeeStructureModel({
    required super.id,
    required super.schoolId,
    super.classId,
    super.className,
    required super.feeType,
    required super.title,
    required super.amount,
    required super.frequency,
    required super.isActive,
  });

  factory FeeStructureModel.fromMap(Map<String, dynamic> map) {
    final classData = map['classes'] as Map<String, dynamic>?;
    return FeeStructureModel(
      id: map['id'] as String,
      schoolId: map['school_id'] as String,
      classId: map['class_id'] as String?,
      className: classData?['name'] as String?,
      feeType: FeeTypeX.fromString(map['fee_type'] as String),
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      frequency: FeeFrequencyX.fromString(map['frequency'] as String),
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'school_id': schoolId,
      'class_id': classId,
      'fee_type': feeType.toDbString(),
      'title': title,
      'amount': amount,
      'frequency': frequency.toDbString(),
      'is_active': isActive,
    };
  }
}

class FeeInvoiceModel extends FeeInvoiceEntity {
  const FeeInvoiceModel({
    required super.id,
    required super.schoolId,
    required super.studentId,
    required super.studentName,
    required super.title,
    required super.amount,
    required super.discount,
    required super.fine,
    required super.totalPayable,
    required super.amountPaid,
    required super.dueDate,
    super.billingMonth,
    super.billingYear,
    required super.status,
  });

  factory FeeInvoiceModel.fromMap(Map<String, dynamic> map) {
    final student = map['students'] as Map<String, dynamic>?;
    return FeeInvoiceModel(
      id: map['id'] as String,
      schoolId: map['school_id'] as String,
      studentId: map['student_id'] as String,
      studentName: student?['full_name'] as String? ?? '',
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      discount: (map['discount'] as num).toDouble(),
      fine: (map['fine'] as num).toDouble(),
      totalPayable: (map['total_payable'] as num).toDouble(),
      amountPaid: (map['amount_paid'] as num).toDouble(),
      dueDate: DateTime.parse(map['due_date'] as String),
      billingMonth: map['billing_month'] as int?,
      billingYear: map['billing_year'] as int?,
      status: InvoiceStatusX.fromString(map['status'] as String),
    );
  }
}

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.invoiceId,
    required super.studentId,
    required super.amount,
    required super.paymentMethod,
    super.referenceNumber,
    required super.receiptNumber,
    required super.paymentDate,
    super.notes,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] as String,
      invoiceId: map['invoice_id'] as String,
      studentId: map['student_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      paymentMethod: map['payment_method'] as String,
      referenceNumber: map['reference_number'] as String?,
      receiptNumber: map['receipt_number'] as String,
      paymentDate: DateTime.parse(map['payment_date'] as String),
      notes: map['notes'] as String?,
    );
  }
}

class FeeCollectionSummaryModel extends FeeCollectionSummary {
  const FeeCollectionSummaryModel({
    required super.totalBilled,
    required super.totalCollected,
    required super.totalPending,
    required super.totalOverdue,
  });

  factory FeeCollectionSummaryModel.fromMap(Map<String, dynamic> map) {
    return FeeCollectionSummaryModel(
      totalBilled: (map['total_billed'] as num?)?.toDouble() ?? 0,
      totalCollected: (map['total_collected'] as num?)?.toDouble() ?? 0,
      totalPending: (map['total_pending'] as num?)?.toDouble() ?? 0,
      totalOverdue: (map['total_overdue'] as num?)?.toDouble() ?? 0,
    );
  }
}