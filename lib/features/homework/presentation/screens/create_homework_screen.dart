
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
import '../../../teachers/presentation/providers/teacher_provider.dart';
import '../../domain/entities/homework_entity.dart';
import '../providers/homework_provider.dart';

class CreateHomeworkScreen extends ConsumerStatefulWidget {
  const CreateHomeworkScreen({super.key});

  @override
  ConsumerState<CreateHomeworkScreen> createState() => _CreateHomeworkScreenState();
}

class _CreateHomeworkScreenState extends ConsumerState<CreateHomeworkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _totalMarksController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 3));
  String? _selectedClassId;
  String? _selectedSectionId;
  String? _selectedSubjectId;
  File? _attachment;
  String? _attachmentFileName;

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _attachment = File(result.files.single.path!);
        _attachmentFileName = result.files.single.name;
      });
    }
  }

  Future<void> _submit(bool publishNow) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClassId == null || _selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Class aur Subject select karein')));
      return;
    }

    final authState = ref.read(authControllerProvider);
    final schoolId = authState.user?.schoolId;
    final userId = authState.user?.id;
    if (schoolId == null || userId == null) return;

    final teachers = await ref.read(teacherRepositoryProvider).getTeachers(schoolId);
    final teacher = teachers.firstWhere((t) => t.userId == userId, orElse: () => teachers.first);

    final homework = HomeworkEntity(
      id: '',
      schoolId: schoolId,
      classId: _selectedClassId!,
      className: '',
      sectionId: _selectedSectionId,
      subjectId: _selectedSubjectId!,
      subjectName: '',
      teacherId: teacher.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: _dueDate,
      totalMarks: double.tryParse(_totalMarksController.text.trim()),
      instructions: _instructionsController.text.trim(),
      status: HomeworkStatus.draft,
      createdAt: DateTime.now(),
    );

    final success = await ref.read(homeworkFormControllerProvider.notifier).createAndPublish(
      homework,
      attachment: _attachment,
      publishNow: publishNow,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(publishNow ? 'Homework publish ho gaya' : 'Draft save ho gaya')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(classesListProvider);
    final formState = ref.watch(homeworkFormControllerProvider);
    final isLoading = formState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Homework')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppTextField(controller: _titleController, label: 'Title', validator: Validators.name),
            const SizedBox(height: 12),
            AppTextField(controller: _descriptionController, label: 'Description'),
            const SizedBox(height: 12),
            classesAsync.when(
              data: (classes) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Class'),
                items: classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (value) => setState(() {
                  _selectedClassId = value;
                  _selectedSectionId = null;
                  _selectedSubjectId = null;
                }),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error loading classes'),
            ),
            if (_selectedClassId != null) ...[
              const SizedBox(height: 12),
              Consumer(
                builder: (context, ref, _) {
                  final sectionsAsync = ref.watch(sectionsForClassProvider(_selectedClassId!));
                  return sectionsAsync.when(
                    data: (sections) => DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Section (optional — sab sections ke liye khali chhoden)'),
                      items: sections.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                      onChanged: (value) => setState(() => _selectedSectionId = value),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Error'),
                  );
                },
              ),
              const SizedBox(height: 12),
              Consumer(
                builder: (context, ref, _) {
                  final subjectsAsync = ref.watch(subjectsForClassProvider(_selectedClassId!));
                  return subjectsAsync.when(
                    data: (subjects) => DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Subject'),
                      items: subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                      onChanged: (value) => setState(() => _selectedSubjectId = value),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Error'),
                  );
                },
              ),
            ],
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Due Date: ${_dueDate.toLocal()}'.split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 180)),
                );
                if (picked != null) setState(() => _dueDate = picked);
              },
            ),
            AppTextField(
              controller: _totalMarksController,
              label: 'Total Marks (optional)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            AppTextField(controller: _instructionsController, label: 'Instructions (optional)'),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: Text(_attachmentFileName ?? 'Attach File / PDF / Image (optional)'),
              onPressed: _pickAttachment,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : () => _submit(false),
                    child: const Text('Save as Draft'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(label: 'Publish Now', onPressed: () => _submit(true), isLoading: isLoading),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}