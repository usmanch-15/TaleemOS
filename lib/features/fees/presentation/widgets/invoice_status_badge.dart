
import 'package:flutter/material.dart';
import '../../domain/entities/fee_entity.dart';

class InvoiceStatusBadge extends StatelessWidget {
  final InvoiceStatus status;
  const InvoiceStatusBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case InvoiceStatus.pending:
        return Colors.orange;
      case InvoiceStatus.partiallyPaid:
        return Colors.blue;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.cancelled:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: _color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(status.label, style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}