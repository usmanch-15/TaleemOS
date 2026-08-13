import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transport_provider.dart';

class ParentTransportScreen extends ConsumerWidget {
  final String studentId;
  final String studentName;
  const ParentTransportScreen({super.key, required this.studentId, required this.studentName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infoAsync = ref.watch(studentTransportInfoProvider(studentId));

    return Scaffold(
      appBar: AppBar(title: Text('$studentName — Transport')),
      body: infoAsync.when(
        data: (info) {
          if (info == null) return const Center(child: Text('Transport assign nahi hua abhi tak'));

          final route = info['transport_routes'] as Map<String, dynamic>?;
          final stop = info['route_stops'] as Map<String, dynamic>?;
          final vehicle = route?['vehicles'] as Map<String, dynamic>?;
          final driver = route?['drivers'] as Map<String, dynamic>?;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.route, color: Colors.indigo),
                          const SizedBox(width: 8),
                          Text(route?['route_name'] as String? ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const Divider(height: 24),
                      _infoRow('Vehicle', vehicle?['vehicle_number'] as String? ?? '-'),
                      _infoRow('Driver', driver?['full_name'] as String? ?? '-'),
                      _infoRow('Driver Phone', driver?['phone'] as String? ?? '-'),
                      _infoRow('Stop', stop?['stop_name'] as String? ?? '-'),
                      _infoRow('Pickup Time', stop?['pickup_time'] as String? ?? '-'),
                      _infoRow('Drop Time', stop?['drop_time'] as String? ?? '-'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}