
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../classes/presentation/providers/class_provider.dart';
import '../../domain/entities/fee_entity.dart';
import '../providers/fee_provider.dart';

class FeeStructuresScreen extends ConsumerWidget {
  const FeeStructuresScreen({super.key});

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    FeeType selectedType = FeeType.tuition;
    FeeFrequency selectedFrequency = FeeFrequency.monthly;
    String? selectedClassId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final classesAsync = ref.watch(classesListProvider);
          return AlertDialog(
            title: const Text('Add Fee Structure'),
            content: SizedBox(
              width: 320,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTextField(controller: titleController, label: 'Title (e.g. Monthly Tuition)'),
                    const SizedBox(height: 12),
                    AppTextField(controller: amountController, label: 'Amount', keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<FeeType>(
                      decoration: const InputDecoration(labelText: 'Fee Type'),
                      value: selectedType,
                      items: FeeType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
                      onChanged: (value) => setDialogState(() => selectedType = value!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<FeeFrequency>(
                      decoration: const InputDecoration(labelText: 'Frequency'),
                      value: selectedFrequency,
                      items: FeeFrequency.values.map((f) => DropdownMenuItem(value: f, child: Text(f.label))).toList(),
                      onChanged: (value) => setDialogState(() => selectedFrequency = value!),
                    ),
                    const SizedBox(height: 12),
                    classesAsync.when(
                      data: (classes) => DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Class (optional — sab classes ke liye khali)'),
                        value: selectedClassId,
                        items: classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                        onChanged: (value) => setDialogState(() => selectedClassId = value),
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text.trim());
                  if (titleController.text.trim().isEmpty || amount == null) return;

                  final schoolId = ref.read(authControllerProvider).user?.schoolId;
                  if (schoolId == null) return;

                  final structure = FeeStructureEntity(
                    id: '',
                    schoolId: schoolId,
                    classId: selectedClassId,
                    feeType: selectedType,
                    title: titleController.text.trim(),
                    amount: amount,
                    frequency: selectedFrequency,
                    isActive: true,
                  );

                  await ref.read(feeStructureControllerProvider.notifier).create(structure);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final structuresAsync = ref.watch(feeStructuresProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Fee Structures')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: structuresAsync.when(
        data: (structures) {
          if (structures.isEmpty) return const Center(child: Text('Abhi koi fee structure nahi bani'));
          return ListView.builder(
            itemCount: structures.length,
            itemBuilder: (context, index) {
              final s = structures[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  title: Text(s.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${s.feeType.label} • ${s.frequency.label} • ${s.className ?? "All Classes"}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Rs. ${s.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Switch(
                        value: s.isActive,
                        onChanged: (value) => ref.read(feeStructureControllerProvider.notifier).toggleActive(s.id, value),
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
    );
  }
}