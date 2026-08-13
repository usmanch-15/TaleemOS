import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../students/presentation/providers/student_provider.dart';
import '../providers/transport_provider.dart';

class RouteDetailScreen extends ConsumerStatefulWidget {
  final String routeId;
  const RouteDetailScreen({super.key, required this.routeId});

  @override
  ConsumerState<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends ConsumerState<RouteDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _showAddStopDialog() {
    final nameController = TextEditingController();
    final pickupController = TextEditingController();
    final dropController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Stop'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Stop Name')),
            const SizedBox(height: 12),
            TextField(controller: pickupController, decoration: const InputDecoration(labelText: 'Pickup Time (e.g. 07:15)')),
            const SizedBox(height: 12),
            TextField(controller: dropController, decoration: const InputDecoration(labelText: 'Drop Time (e.g. 14:30)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              final routeAsync = ref.read(routeDetailProvider(widget.routeId));
              final currentStopCount = routeAsync.value?.stops.length ?? 0;

              await ref.read(routeControllerProvider.notifier).addStop(
                routeId: widget.routeId,
                stopName: nameController.text.trim(),
                stopOrder: currentStopCount,
                pickupTime: pickupController.text.trim().isEmpty ? null : pickupController.text.trim(),
                dropTime: dropController.text.trim().isEmpty ? null : dropController.text.trim(),
              );
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAssignStudentDialog() {
    String? selectedStudentId;
    String? selectedStopId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final studentsAsync = ref.watch(studentsListProvider);
          final routeAsync = ref.watch(routeDetailProvider(widget.routeId));

          return AlertDialog(
            title: const Text('Assign Student to Route'),
            content: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  studentsAsync.when(
                    data: (result) => DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Student'),
                      items: result.items.map((s) => DropdownMenuItem(value: s.id, child: Text(s.fullName))).toList(),
                      onChanged: (value) => setDialogState(() => selectedStudentId = value),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Error'),
                  ),
                  const SizedBox(height: 12),
                  routeAsync.when(
                    data: (route) => DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Stop (optional)'),
                      items: route.stops.map((s) => DropdownMenuItem(value: s.id, child: Text(s.stopName))).toList(),
                      onChanged: (value) => setDialogState(() => selectedStopId = value),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Error'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () async {
                  if (selectedStudentId == null) return;
                  await ref.read(routeControllerProvider.notifier).assignStudent(
                    studentId: selectedStudentId!,
                    routeId: widget.routeId,
                    stopId: selectedStopId,
                  );
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Assign'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeAsync = ref.watch(routeDetailProvider(widget.routeId));
    final occupancyAsync = ref.watch(routeOccupancyProvider(widget.routeId));
    final studentsAsync = ref.watch(routeStudentsProvider(widget.routeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Detail'),
        bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'Stops'), Tab(text: 'Students')]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _tabController.index == 0 ? _showAddStopDialog() : _showAssignStudentDialog(),
        child: const Icon(Icons.add),
      ),
      body: routeAsync.when(
        data: (route) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(route.routeName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${route.vehicleNumber ?? "No vehicle"} • ${route.driverName ?? "No driver"}',
                      style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  occupancyAsync.when(
                    data: (occ) => Column(
                      children: [
                        LinearProgressIndicator(
                          value: occ.capacity == 0 ? 0 : occ.assignedCount / occ.capacity,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(4),
                          color: occ.isFull ? Colors.red : Colors.green,
                        ),
                        const SizedBox(height: 4),
                        Text('${occ.assignedCount} / ${occ.capacity} seats occupied', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  ListView.builder(
                    itemCount: route.stops.length,
                    itemBuilder: (context, index) {
                      final stop = route.stops[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(stop.stopName),
                        subtitle: Text('Pickup: ${stop.pickupTime ?? "-"} • Drop: ${stop.dropTime ?? "-"}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => ref.read(routeControllerProvider.notifier).removeStop(stop.id, widget.routeId),
                        ),
                      );
                    },
                  ),
                  studentsAsync.when(
                    data: (students) {
                      if (students.isEmpty) return const Center(child: Text('Koi student assign nahi hua'));
                      return ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final s = students[index];
                          final student = s['students'] as Map<String, dynamic>;
                          final stop = s['route_stops'] as Map<String, dynamic>?;
                          return ListTile(
                            title: Text(student['full_name'] as String),
                            subtitle: Text(stop != null ? 'Stop: ${stop['stop_name']}' : 'No stop assigned'),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => ref
                                  .read(routeControllerProvider.notifier)
                                  .unassignStudent(s['student_id'] as String, widget.routeId),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                  ),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}