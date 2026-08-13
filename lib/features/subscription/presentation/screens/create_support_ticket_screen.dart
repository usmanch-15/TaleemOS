import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/support_ticket_entity.dart';
import '../providers/subscription_provider.dart';

class CreateSupportTicketScreen extends ConsumerStatefulWidget {
  const CreateSupportTicketScreen({super.key});

  @override
  ConsumerState<CreateSupportTicketScreen> createState() => _CreateSupportTicketScreenState();
}

class _CreateSupportTicketScreenState extends ConsumerState<CreateSupportTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  TicketCategory _category = TicketCategory.general;
  String _priority = 'normal';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(supportTicketControllerProvider.notifier).createTicket(
      subject: _subjectController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category.toDbString(),
      priority: _priority,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ticket submit ho gaya')));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supportTicketControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New Support Ticket')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DropdownButtonFormField<TicketCategory>(
              decoration: const InputDecoration(labelText: 'Category'),
              value: _category,
              items: TicketCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.label))).toList(),
              onChanged: (value) => setState(() => _category = value!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Priority'),
              value: _priority,
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'normal', child: Text('Normal')),
                DropdownMenuItem(value: 'high', child: Text('High')),
                DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
              ],
              onChanged: (value) => setState(() => _priority = value!),
            ),
            const SizedBox(height: 12),
            AppTextField(controller: _subjectController, label: 'Subject', validator: Validators.name),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: 'Describe the issue in detail',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) => value == null || value.trim().isEmpty ? 'Description required hai' : null,
            ),
            const SizedBox(height: 20),
            AppButton(label: 'Submit Ticket', onPressed: _submit, isLoading: state.isLoading),
          ],
        ),
      ),
    );
  }
}