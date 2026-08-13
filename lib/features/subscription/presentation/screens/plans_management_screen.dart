import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/subscription_entity.dart';
import '../providers/subscription_provider.dart';

class PlansManagementScreen extends ConsumerWidget {
  const PlansManagementScreen({super.key});

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController(text: '30');
    final maxStudentsController = TextEditingController(text: '500');
    final maxTeachersController = TextEditingController(text: '50');
    final featuresController = TextEditingController();
    bool isTrial = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Subscription Plan'),
          content: SizedBox(
            width: 320,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Plan Name')),
                  const SizedBox(height: 10),
                  TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (per cycle)')),
                  const SizedBox(height: 10),
                  TextField(controller: durationController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Duration (days)')),
                  const SizedBox(height: 10),
                  TextField(controller: maxStudentsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Max Students')),
                  const SizedBox(height: 10),
                  TextField(controller: maxTeachersController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Max Teachers')),
                  const SizedBox(height: 10),
                  TextField(controller: featuresController, decoration: const InputDecoration(labelText: 'Features (comma separated)')),
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Trial Plan'),
                    value: isTrial,
                    onChanged: (value) => setDialogState(() => isTrial = value ?? false),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                final plan = SubscriptionPlanEntity(
                  id: '',
                  name: nameController.text.trim(),
                  price: double.tryParse(priceController.text.trim()) ?? 0,
                  durationDays: int.tryParse(durationController.text.trim()) ?? 30,
                  features: featuresController.text.trim().split(',').map((f) => f.trim()).where((f) => f.isNotEmpty).toList(),
                  maxStudents: int.tryParse(maxStudentsController.text.trim()) ?? 500,
                  maxTeachers: int.tryParse(maxTeachersController.text.trim()) ?? 50,
                  isTrial: isTrial,
                  isActive: true,
                );
                await ref.read(subscriptionManagementControllerProvider.notifier).createPlan(plan);
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
    final plansAsync = ref.watch(subscriptionPlansProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Subscription Plans')),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddDialog(context, ref), child: const Icon(Icons.add)),
      body: plansAsync.when(
        data: (plans) {
          if (plans.isEmpty) return const Center(child: Text('Koi plan nahi bana'));
          return ListView.builder(
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final p = plans[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(p.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          if (p.isTrial) ...[
                            const SizedBox(width: 8),
                            Chip(label: const Text('Trial', style: TextStyle(fontSize: 10)), backgroundColor: Colors.blue.shade50),
                          ],
                          const Spacer(),
                          Switch(value: p.isActive, onChanged: (v) => ref.read(subscriptionManagementControllerProvider.notifier).togglePlan(p.id, v)),
                        ],
                      ),
                      Text('Rs. ${p.price.toStringAsFixed(0)} / ${p.durationDays} days', style: TextStyle(color: Colors.grey.shade700)),
                      const SizedBox(height: 4),
                      Text('Up to ${p.maxStudents} students, ${p.maxTeachers} teachers', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      if (p.features.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: p.features.map((f) => Chip(label: Text(f, style: const TextStyle(fontSize: 11)), visualDensity: VisualDensity.compact)).toList(),
                        ),
                      ],
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
    );
  }
}