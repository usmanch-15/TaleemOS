import 'package:flutter/material.dart';

class SimpleBarChart extends StatelessWidget {
  final List<({String label, double value})> data;
  final Color color;
  final String Function(double)? valueFormatter;

  const SimpleBarChart({super.key, required this.data, this.color = Colors.indigo, this.valueFormatter});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final maxValue = data.map((d) => d.value).fold<double>(0, (a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: data.map((d) {
          final ratio = maxValue == 0 ? 0.0 : d.value / maxValue;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(width: 80, child: Text(d.label, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                Expanded(
                  child: Stack(
                    children: [
                      Container(height: 20, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6))),
                      FractionallySizedBox(
                        widthFactor: ratio.clamp(0.0, 1.0),
                        child: Container(height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 50,
                  child: Text(
                    valueFormatter != null ? valueFormatter!(d.value) : d.value.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}