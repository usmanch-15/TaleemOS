import 'package:flutter/material.dart';
import '../../domain/entities/transport_entity.dart';

class PickupDropToggle extends StatelessWidget {
  final String label;
  final PickupDropStatus status;
  final ValueChanged<String> onChanged;

  const PickupDropToggle({super.key, required this.label, required this.status, required this.onChanged});

  Color _colorFor(PickupDropStatus s) {
    switch (s) {
      case PickupDropStatus.done:
        return Colors.green;
      case PickupDropStatus.absent:
        return Colors.red;
      case PickupDropStatus.pending:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Row(
          children: [
            _btn('Done', status == PickupDropStatus.done, Colors.green, () => onChanged(label == 'Pickup' ? 'picked_up' : 'dropped')),
            const SizedBox(width: 6),
            _btn('Absent', status == PickupDropStatus.absent, Colors.red, () => onChanged('absent')),
          ],
        ),
      ],
    );
  }

  Widget _btn(String text, bool selected, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? color : Colors.grey.shade300),
        ),
        child: Text(text, style: TextStyle(fontSize: 11, color: selected ? color : Colors.grey.shade600, fontWeight: FontWeight.w600)),
      ),
    );
  }
}