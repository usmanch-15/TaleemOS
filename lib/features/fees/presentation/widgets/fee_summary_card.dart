

import 'package:flutter/material.dart';
import '../../domain/entities/fee_entity.dart';

class FeeSummaryCard extends StatelessWidget {
  final FeeCollectionSummary summary;
  const FeeSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rs. ${summary.totalBilled.toStringAsFixed(0)} Billed', style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${summary.collectionPercentage.toStringAsFixed(1)}% Collected',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: summary.collectionPercentage / 100,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(Colors.green.shade600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatBlock(label: 'Collected', value: summary.totalCollected, color: Colors.green),
                _StatBlock(label: 'Pending', value: summary.totalPending, color: Colors.orange),
                _StatBlock(label: 'Overdue', value: summary.totalOverdue, color: Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _StatBlock({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text('Rs. ${value.toStringAsFixed(0)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}