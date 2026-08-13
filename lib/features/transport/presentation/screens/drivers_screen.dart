import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/transport_entity.dart';
import '../providers/transport_provider.dart';

class DriversScreen extends ConsumerWidget {
  const DriversScreen({super.key});

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final licenseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Driver'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name')),
            const SizedBox(height: 12),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            TextField(controller: licenseController, decoration: const InputDecoration(labelText: 'License Number (optional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final schoolId = ref.read(authControllerProvider).user?.schoolId;
              if (schoolId == null || nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty) return;

              final driver = DriverEntity(
                id: '',
                schoolId: schoolId,
                fullName: nameController.text.trim(),
                phone: phoneController.text.trim(),
                licenseNumber: licenseController.text.trim().isEmpty ? null : licenseController.text.trim(),
                status: 'active',
              );
              await ref.read(driverControllerProvider.notifier).create(driver);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driversAsync = ref.watch(driversListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Drivers')),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddDialog(context, ref), child: const Icon(Icons.add)),
      body: driversAsync.when(
        data: (drivers) {
          if (drivers.isEmpty) return const Center(child: Text('Koi driver add nahi hua'));
          return ListView.builder(
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              final d = drivers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(child: Text(d.fullName.isNotEmpty ? d.fullName[0] : '?')),
                  title: Text(d.fullName),
                  subtitle: Text(d.phone),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => ref.read(driverControllerProvider.notifier).delete(d.id),
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