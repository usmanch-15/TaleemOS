import '../../domain/entities/fee_entity.dart';
import '../../domain/repositories/fee_repository.dart';
import '../datasources/fee_remote_datasource.dart';
import '../models/fee_models.dart';

class FeeRepositoryImpl implements FeeRepository {
  final FeeRemoteDatasource remote;
  FeeRepositoryImpl(this.remote);

  @override
  Future<List<FeeStructureEntity>> getFeeStructures(String schoolId) => remote.getFeeStructures(schoolId);

  @override
  Future<FeeStructureEntity> createFeeStructure(FeeStructureEntity structure) {
    final model = FeeStructureModel(
      id: structure.id,
      schoolId: structure.schoolId,
      classId: structure.classId,
      className: structure.className,
      feeType: structure.feeType,
      title: structure.title,
      amount: structure.amount,
      frequency: structure.frequency,
      isActive: structure.isActive,
    );
    return remote.createFeeStructure(model);
  }

  @override
  Future<void> toggleFeeStructureActive(String id, bool isActive) => remote.toggleFeeStructureActive(id, isActive);

  @override
  Future<void> deleteFeeStructure(String id) => remote.deleteFeeStructure(id);

  @override
  Future<int> generateMonthlyInvoices({
    required String schoolId,
    required int month,
    required int year,
    required DateTime dueDate,
  }) {
    return remote.generateMonthlyInvoices(schoolId: schoolId, month: month, year: year, dueDate: dueDate);
  }

  @override
  Future<FeeInvoiceEntity> createOneTimeInvoice({
    required String schoolId,
    required String studentId,
    required String title,
    required double amount,
    required DateTime dueDate,
    double discount = 0,
    double fine = 0,
  }) {
    return remote.createOneTimeInvoice(
      schoolId: schoolId,
      studentId: studentId,
      title: title,
      amount: amount,
      dueDate: dueDate,
      discount: discount,
      fine: fine,
    );
  }

  @override
  Future<List<FeeInvoiceEntity>> getStudentInvoices(String studentId) => remote.getStudentInvoices(studentId);

  @override
  Future<List<FeeInvoiceEntity>> getSchoolInvoices({required String schoolId, String? statusFilter, String? searchQuery}) {
    return remote.getSchoolInvoices(schoolId: schoolId, statusFilter: statusFilter, searchQuery: searchQuery);
  }

  @override
  Future<FeeInvoiceEntity> getInvoiceById(String invoiceId) => remote.getInvoiceById(invoiceId);

  @override
  Future<String> generateReceiptNumber(String schoolId) => remote.generateReceiptNumber(schoolId);

  @override
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
  }) {
    return remote.recordPayment(
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

  @override
  Future<List<PaymentEntity>> getStudentPaymentHistory(String studentId) => remote.getStudentPaymentHistory(studentId);

  @override
  Future<List<PaymentEntity>> getInvoicePayments(String invoiceId) => remote.getInvoicePayments(invoiceId);

  @override
  Future<FeeCollectionSummary> getCollectionSummary({required String schoolId, required int month, required int year}) {
    return remote.getCollectionSummary(schoolId: schoolId, month: month, year: year);
  }

  @override
  Future<List<FeeInvoiceEntity>> getPendingFeesReport(String schoolId) => remote.getPendingFeesReport(schoolId);
}