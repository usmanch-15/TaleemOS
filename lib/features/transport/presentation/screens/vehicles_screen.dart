import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/transport_entity.dart';
import '../providers/transport_provider.dart';

class VehiclesScreen extends ConsumerWidget {
  const VehiclesScreen({super.key});

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final numberController = TextEditingController();
    final capacityController = TextEditingController(text: '30');
    String selectedType = 'bus';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Vehicle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: numberController, decoration: const InputDecoration(labelText: 'Vehicle Number')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Type'),
                value: selectedType,
                items: const [
                  DropdownMenuItem(value: 'bus', child: Text('Bus')),
                  DropdownMenuItem(value: 'van', child: Text('Van')),
                  DropdownMenuItem(value: 'coaster', child: Text('Coaster')),
                ],
                onChanged: (value) => setDialogState(() => selectedType = value!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Capacity'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                final schoolId = ref.read(authControllerProvider).user?.schoolId;
                if (schoolId == null || numberController.text.trim().isEmpty) return;

                final vehicle = VehicleEntity(
                  id: '',
                  schoolId: schoolId,
                  vehicleNumber: numberController.text.trim(),
                  vehicleType: selectedType,
                  capacity: int.tryParse(capacityController.text.trim()) ?? 30,
                  status: VehicleStatus.active,
                );
                await ref.read(vehicleControllerProvider.notifier).create(vehicle);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Vehicles')),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddDialog(context, ref), child: const Icon(Icons.add)),
      body: vehiclesAsync.when(
        data: (vehicles) {
          if (vehicles.isEmpty) return const Center(child: Text('Koi vehicle add nahi hui'));
          return ListView.builder(
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final v = vehicles[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade50,
                    child: Icon(v.vehicleType == 'bus' ? Icons.directions_bus : Icons.airport_shuttle, color: Colors.indigo),
                  ),
                  title: Text(v.vehicleNumber, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${v.vehicleType.toUpperCase()} • Capacity: ${v.capacity}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => ref.read(vehicleControllerProvider.notifier).delete(v.id),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}