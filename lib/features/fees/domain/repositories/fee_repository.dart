
import '../entities/fee_entity.dart';

abstract class FeeRepository {
  Future<List<FeeStructureEntity>> getFeeStructures(String schoolId);
  Future<FeeStructureEntity> createFeeStructure(FeeStructureEntity structure);
  Future<void> toggleFeeStructureActive(String id, bool isActive);
  Future<void> deleteFeeStructure(String id);

  Future<int> generateMonthlyInvoices({
    required String schoolId,
    required int month,
    required int year,
    required DateTime dueDate,
  });

  Future<FeeInvoiceEntity> createOneTimeInvoice({
    required String schoolId,
    required String studentId,
    required String title,
    required double amount,
    required DateTime dueDate,
    double discount = 0,
    double fine = 0,
  });

  Future<List<FeeInvoiceEntity>> getStudentInvoices(String studentId);
  Future<List<FeeInvoiceEntity>> getSchoolInvoices({required String schoolId, String? statusFilter, String? searchQuery});
  Future<FeeInvoiceEntity> getInvoiceById(String invoiceId);

  Future<String> generateReceiptNumber(String schoolId);
  Future<PaymentEntity> recordPayment({
    required String schoolId,
    required String invoiceId,
    required String studentId,
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
    required String receiptNumber,
    required String collectedBy,
    String? notes,
  });
  Future<List<PaymentEntity>> getStudentPaymentHistory(String studentId);
  Future<List<PaymentEntity>> getInvoicePayments(String invoiceId);

  Future<FeeCollectionSummary> getCollectionSummary({required String schoolId, required int month, required int year});
  Future<List<FeeInvoiceEntity>> getPendingFeesReport(String schoolId);
}