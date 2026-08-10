import '../entities/fee_entity.dart';
import '../repositories/fee_repository.dart';

class CreateFeeStructureUsecase {
  final FeeRepository repository;
  CreateFeeStructureUsecase(this.repository);
  Future<FeeStructureEntity> call(FeeStructureEntity structure) => repository.createFeeStructure(structure);
}

class GenerateMonthlyInvoicesUsecase {
  final FeeRepository repository;
  GenerateMonthlyInvoicesUsecase(this.repository);
  Future<int> call({required String schoolId, required int month, required int year, required DateTime dueDate}) {
    return repository.generateMonthlyInvoices(schoolId: schoolId, month: month, year: year, dueDate: dueDate);
  }
}

class RecordPaymentUsecase {
  final FeeRepository repository;
  RecordPaymentUsecase(this.repository);

  Future<PaymentEntity> call({
    required String schoolId,
    required String invoiceId,
    required String studentId,
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
    required String collectedBy,
    String? notes,
  }) async {
    final receiptNumber = await repository.generateReceiptNumber(schoolId);
    return repository.recordPayment(
      schoolId: schoolId,
      invoiceId: invoiceId,
      studentId: studentId,
      amount: amount,
      paymentMethod: paymentMethod,
      referenceNumber: referenceNumber,
      receiptNumber: receiptNumber,
      collectedBy: collectedBy,
      notes: notes,
    );
  }
}

class GetPendingFeesReportUsecase {
  final FeeRepository repository;
  GetPendingFeesReportUsecase(this.repository);
  Future<List<FeeInvoiceEntity>> call(String schoolId) => repository.getPendingFeesReport(schoolId);
}