import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/complaint_entity.dart';
import '../providers/complaint_provider.dart';

class CreateComplaintScreen extends ConsumerStatefulWidget {
  const CreateComplaintScreen({super.key});

  @override
  ConsumerState<CreateComplaintScreen> createState() => _CreateComplaintScreenState();
}

class _CreateComplaintScreenState extends ConsumerState<CreateComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  ComplaintCategory _selectedCategory = ComplaintCategory.academic;
  ComplaintPriority _selectedPriority = ComplaintPriority.normal;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authControllerProvider);
    final schoolId = authState.user?.schoolId;
    final userId = authState.user?.id;
    if (schoolId == null || userId == null) return;

    final complaint = ComplaintEntity(
      id: '',
      schoolId: schoolId,
      raisedBy: userId,
      raisedByName: authState.user!.name,
      category: _selectedCategory,
      subject: _subjectController.text.trim(),
      description: _descriptionController.text.trim(),
      status: ComplaintStatus.open,
      priority: _selectedPriority,
      createdAt: DateTime.now(),
    );

    final success = await ref.read(complaintControllerProvider.notifier).create(complaint);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complaint submit ho gayi')));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(complaintControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Raise Complaint')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            DropdownButtonFormField<ComplaintCategory>(
              decoration: const InputDecoration(labelText: 'Category'),
              value: _selectedCategory,
              items: ComplaintCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.label))).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ComplaintPriority>(
              decoration: const InputDecoration(labelText: 'Priority'),
              value: _selectedPriority,
              items: ComplaintPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.label))).toList(),
              onChanged: (value) => setState(() => _selectedPriority = value!),
            ),
            const SizedBox(height: 12),
            AppTextField(controller: _subjectController, label: 'Subject', validator: Validators.name),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: 'Describe your complaint in detail',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) => value == null || value.trim().isEmpty ? 'Description required hai' : null,
            ),
            const SizedBox(height: 20),
            AppButton(label: 'Submit Complaint', onPressed: _submit, isLoading: state.isLoading),
          ],
        ),
      ),
    );
  }
}