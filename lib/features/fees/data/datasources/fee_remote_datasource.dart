import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fee_models.dart';

class FeeRemoteDatasource {
  final SupabaseClient client;
  FeeRemoteDatasource(this.client);

  // ---- Fee Structures ----
  Future<List<FeeStructureModel>> getFeeStructures(String schoolId) async {
    final data = await client
        .from('fee_structures')
        .select('*, classes(name)')
        .eq('school_id', schoolId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => FeeStructureModel.fromMap(e)).toList();
  }

  Future<FeeStructureModel> createFeeStructure(FeeStructureModel structure) async {
    final data = await client
        .from('fee_structures')
        .insert(structure.toInsertMap())
        .select('*, classes(name)')
        .single();
    return FeeStructureModel.fromMap(data);
  }

  Future<void> toggleFeeStructureActive(String id, bool isActive) async {
    await client.from('fee_structures').update({'is_active': isActive}).eq('id', id);
  }

  Future<void> deleteFeeStructure(String id) async {
    await client.from('fee_structures').delete().eq('id', id);
  }

  // ---- Invoice Generation ----
  Future<int> generateMonthlyInvoices({
    required String schoolId,
    required int month,
    required int year,
    required DateTime dueDate,
  }) async {
    final result = await client.rpc('generate_monthly_invoices', params: {
      'p_school_id': schoolId,
      'p_billing_month': month,
      'p_billing_year': year,
      'p_due_date': dueDate.toIso8601String().split('T')[0],
    });
    return result as int;
  }

  Future<FeeInvoiceModel> createOneTimeInvoice({
    required String schoolId,
    required String studentId,
    required String title,
    required double amount,
    required DateTime dueDate,
    double discount = 0,
    double fine = 0,
  }) async {
    final data = await client
        .from('fee_invoices')
        .insert({
      'school_id': schoolId,
      'student_id': studentId,
      'title': title,
      'amount': amount,
      'discount': discount,
      'fine': fine,
      'due_date': dueDate.toIso8601String().split('T')[0],
    })
        .select('*, students(full_name)')
        .single();
    return FeeInvoiceModel.fromMap(data);
  }

  // ---- Invoices Query ----
  Future<List<FeeInvoiceModel>> getStudentInvoices(String studentId) async {
    final data = await client
        .from('fee_invoices')
        .select('*, students(full_name)')
        .eq('student_id', studentId)
        .order('due_date', ascending: false);
    return (data as List).map((e) => FeeInvoiceModel.fromMap(e)).toList();
  }

  Future<List<FeeInvoiceModel>> getSchoolInvoices({
    required String schoolId,
    String? statusFilter,
    String? searchQuery,
  }) async {
    var query = client.from('fee_invoices').select('*, students(full_name)').eq('school_id', schoolId);
    if (statusFilter != null) query = query.eq('status', statusFilter);

    final data = await query.order('due_date', ascending: false).limit(200);
    var results = (data as List).map((e) => FeeInvoiceModel.fromMap(e)).toList();

    if (searchQuery != null && searchQuery.isNotEmpty) {
      results = results.where((inv) => inv.studentName.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }
    return results;
  }

  Future<FeeInvoiceModel> getInvoiceById(String invoiceId) async {
    final data = await client.from('fee_invoices').select('*, students(full_name)').eq('id', invoiceId).single();
    return FeeInvoiceModel.fromMap(data);
  }

  // ---- Payments ----
  Future<String> generateReceiptNumber(String schoolId) async {
    final result = await client.rpc('generate_receipt_number', params: {'p_school_id': schoolId});
    return result as String;
  }

  Future<PaymentModel> recordPayment({
    required String schoolId,
    required String invoiceId,
    required String studentId,
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
    required String receiptNumber,
    required String collectedBy,
    String? notes,
  }) async {
    final data = await client
        .from('payments')
        .insert({
      'school_id': schoolId,
      'invoice_id': invoiceId,
      'student_id': studentId,
      'amount': amount,
      'payment_method': paymentMethod,
      'reference_number': referenceNumber,
      'receipt_number': receiptNumber,
      'collected_by': collectedBy,
      'notes': notes,
    })
        .select()
        .single();
    return PaymentModel.fromMap(data);
  }

  Future<List<PaymentModel>> getStudentPaymentHistory(String studentId) async {
    final data = await client.from('payments').select().eq('student_id', studentId).order('payment_date', ascending: false);
    return (data as List).map((e) => PaymentModel.fromMap(e)).toList();
  }

  Future<List<PaymentModel>> getInvoicePayments(String invoiceId) async {
    final data = await client.from('payments').select().eq('invoice_id', invoiceId).order('payment_date');
    return (data as List).map((e) => PaymentModel.fromMap(e)).toList();
  }

  // ---- Reports ----
  Future<FeeCollectionSummaryModel> getCollectionSummary({
    required String schoolId,
    required int month,
    required int year,
  }) async {
    final result = await client.rpc('get_fee_collection_summary', params: {
      'p_school_id': schoolId,
      'p_month': month,
      'p_year': year,
    });
    final row = (result as List).first as Map<String, dynamic>;
    return FeeCollectionSummaryModel.fromMap(row);
  }

  Future<List<FeeInvoiceModel>> getPendingFeesReport(String schoolId) async {
    final data = await client
        .from('fee_invoices')
        .select('*, students(full_name)')
        .eq('school_id', schoolId)
        .inFilter('status', ['pending', 'partially_paid', 'overdue'])
        .order('due_date');
    return (data as List).map((e) => FeeInvoiceModel.fromMap(e)).toList();
  }
}