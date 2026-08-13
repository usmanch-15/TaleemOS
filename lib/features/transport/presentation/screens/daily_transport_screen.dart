import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/transport_provider.dart';
import '../widgets/pickup_drop_toggle.dart';

class DailyTransportScreen extends ConsumerWidget {
  final String routeId;
  final String routeName;
  const DailyTransportScreen({super.key, required this.routeId, required this.routeName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedTransportDateProvider);
    final logsAsync = ref.watch(routeLogsForDateProvider((routeId: routeId, date: selectedDate)));
    final genState = ref.watch(transportLogControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(routeName)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now(),
                );
                if (picked != null) ref.read(selectedTransportDateProvider.notifier).state = picked;
              },
            ),
          ),
          Expanded(
            child: logsAsync.when(
              data: (logs) {
                if (logs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Aaj ki log list generate nahi hui'),
                          const SizedBox(height: 12),
                          AppButton(
                            label: 'Generate Today\'s List',
                            isLoading: genState.isLoading,
                            onPressed: () => ref.read(transportLogControllerProvider.notifier).generateTodayLogs(routeId, selectedDate),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(log.studentName, style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                PickupDropToggle(
                                  label: 'Pickup',
                                  status: log.pickupStatus,
                                  onChanged: (status) => ref
                                      .read(transportLogControllerProvider.notifier)
                                      .markPickup(log.id, status, routeId, selectedDate),
                                ),
                                PickupDropToggle(
                                  label: 'Drop',
                                  status: log.dropStatus,
                                  onChanged: (status) => ref
                                      .read(transportLogControllerProvider.notifier)
                                      .markDrop(log.id, status, routeId, selectedDate),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}