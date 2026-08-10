import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReceiptPdfService {
  ReceiptPdfService._();
  static final ReceiptPdfService instance = ReceiptPdfService._();

  Future<File> generateReceipt({
    required String schoolName,
    required String studentName,
    required String studentCode,
    required String receiptNumber,
    required String feeTitle,
    required double amountPaid,
    required double totalPayable,
    required double balance,
    required String paymentMethod,
    required DateTime paymentDate,
    String? collectedByName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(child: pw.Text(schoolName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold))),
              pw.Center(child: pw.Text('Payment Receipt', style: const pw.TextStyle(fontSize: 12))),
              pw.Divider(),
              pw.SizedBox(height: 8),
              _row('Receipt No:', receiptNumber),
              _row('Date:', '${paymentDate.day}/${paymentDate.month}/${paymentDate.year}'),
              _row('Student:', studentName),
              _row('Student Code:', studentCode),
              pw.SizedBox(height: 8),
              pw.Divider(),
              _row('Fee Title:', feeTitle),
              _row('Total Payable:', 'Rs. ${totalPayable.toStringAsFixed(0)}'),
              _row('Amount Paid:', 'Rs. ${amountPaid.toStringAsFixed(0)}'),
              _row('Balance:', 'Rs. ${balance.toStringAsFixed(0)}'),
              _row('Payment Method:', paymentMethod),
              if (collectedByName != null) _row('Collected By:', collectedByName),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.Center(child: pw.Text('Thank you!', style: const pw.TextStyle(fontSize: 10))),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/receipt_$receiptNumber.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 11)),
          pw.Text(value, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}