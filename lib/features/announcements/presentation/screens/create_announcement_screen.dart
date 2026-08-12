import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../classes/presentation/providers/class_provider.dart';
import '../../domain/entities/announcement_entity.dart';
import '../providers/announcement_provider.dart';

class CreateAnnouncementScreen extends ConsumerStatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  ConsumerState<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends ConsumerState<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  TargetAudience _selectedAudience = TargetAudience.all;
  String? _selectedClassId;
  bool _isPinned = false;
  File? _attachment;
  String? _attachmentName;

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _attachment = File(result.files.single.path!);
        _attachmentName = result.files.single.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAudience == TargetAudience.classSpecific && _selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Class select karein')));
      return;
    }

    final authState = ref.read(authControllerProvider);
    final schoolId = authState.user?.schoolId;
    final userId = authState.user?.id;
    if (schoolId == null || userId == null) return;

    final announcement = AnnouncementEntity(
      id: '',
      schoolId: schoolId,
      createdBy: userId,
      createdByName: authState.user!.name,
      title: _titleController.text.trim(),
      message: _messageController.text.trim(),
      targetAudience: _selectedAudience,
      classId: _selectedAudience == TargetAudience.classSpecific ? _selectedClassId : null,
      isPinned: _isPinned,
      createdAt: DateTime.now(),
    );

    final success = await ref.read(announcementControllerProvider.notifier).create(announcement, attachment: _attachment);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Announcement bhej diya gaya')));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher = ref.watch(authControllerProvider).user?.role.toDbString() == 'teacher';
    final classesAsync = ref.watch(classesListProvider);
    final state = ref.watch(announcementControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Announcement')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppTextField(controller: _titleController, label: 'Title', validator: Validators.name),
            const SizedBox(height: 12),
            TextFormField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) => value == null || value.trim().isEmpty ? 'Message required hai' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TargetAudience>(
              decoration: const InputDecoration(labelText: 'Send To'),
              value: _selectedAudience,
              items: (isTeacher
                  ? [TargetAudience.classSpecific]
                  : TargetAudience.values)
                  .map((a) => DropdownMenuItem(value: a, child: Text(a.label)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedAudience = value!),
            ),
            if (_selectedAudience == TargetAudience.classSpecific) ...[
              const SizedBox(height: 12),
              classesAsync.when(
                data: (classes) => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Class'),
                  items: classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (value) => setState(() => _selectedClassId = value),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Error loading classes'),
              ),
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: Text(_attachmentName ?? 'Attach File (optional)'),
              onPressed: _pickAttachment,
            ),
            if (!isTeacher) ...[
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Pin this announcement'),
                value: _isPinned,
                onChanged: (value) => setState(() => _isPinned = value),
              ),
            ],
            const SizedBox(height: 20),
            AppButton(label: 'Send Announcement', onPressed: _submit, isLoading: state.isLoading),
          ],
        ),
      ),
    );
  }
}