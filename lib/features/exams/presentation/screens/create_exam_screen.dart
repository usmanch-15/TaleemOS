import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../classes/presentation/providers/class_provider.dart';
import '../../domain/entities/exam_entity.dart';
import '../providers/exam_provider.dart';

class CreateExamScreen extends ConsumerStatefulWidget {
  const CreateExamScreen({super.key});

  @override
  ConsumerState<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends ConsumerState<CreateExamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedClassId;
  ExamType _selectedType = ExamType.midterm;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Class select karein')));
      return;
    }

    final schoolId = ref.read(authControllerProvider).user?.schoolId;
    if (schoolId == null) return;

    final classes = await ref.read(classRepositoryProvider).getClasses(schoolId);
    final selectedClass = classes.firstWhere((c) => c.id == _selectedClassId);

    final exam = ExamEntity(
      id: '',
      schoolId: schoolId,
      classId: _selectedClassId!,
      className: selectedClass.name,
      name: _nameController.text.trim(),
      examType: _selectedType,
      startDate: _startDate,
      endDate: _endDate,
      status: ExamStatus.draft,
    );

    final examId = await ref.read(examManagementControllerProvider.notifier).createExam(exam);
    if (examId != null && mounted) {
      context.pushReplacement('/admin/exams/$examId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(classesListProvider);
    final state = ref.watch(examManagementControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Exam')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppTextField(controller: _nameController, label: 'Exam Name (e.g. Midterm 2026)', validator: Validators.name),
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
            const SizedBox(height: 12),
            DropdownButtonFormField<ExamType>(
              decoration: const InputDecoration(labelText: 'Exam Type'),
              value: _selectedType,
              items: ExamType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Start Date: ${_startDate.toLocal()}'.split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _startDate = picked);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('End Date: ${_endDate.toLocal()}'.split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: _startDate,
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _endDate = picked);
              },
            ),
            const SizedBox(height: 24),
            AppButton(label: 'Create Exam & Add Subjects', onPressed: _submit, isLoading: state.isLoading),
          ],
        ),
      ),
    );
  }
}