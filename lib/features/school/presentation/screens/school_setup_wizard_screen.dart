import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/school_entity.dart';
import '../providers/school_provider.dart';

class SchoolSetupWizardScreen extends ConsumerStatefulWidget {
  const SchoolSetupWizardScreen({super.key});

  @override
  ConsumerState<SchoolSetupWizardScreen> createState() => _SchoolSetupWizardScreenState();
}

class _SchoolSetupWizardScreenState extends ConsumerState<SchoolSetupWizardScreen> {
  int _currentStep = 0;
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _sessionNameController = TextEditingController();
  DateTime? _sessionStart;
  DateTime? _sessionEnd;
  List<String> _selectedDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  final List<String> _allDays = const [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  Future<void> _finish() async {
    final authState = ref.read(authControllerProvider);
    final schoolId = authState.user?.schoolId;
    if (schoolId == null) return;

    final currentSchool = await ref.read(getSchoolUsecaseProvider).call(schoolId);

    final updated = SchoolEntity(
      id: schoolId,
      name: _nameController.text.trim(),
      schoolCode: currentSchool.schoolCode,
      logoUrl: currentSchool.logoUrl,
      address: _addressController.text.trim(),
      contactNumber: _contactController.text.trim(),
      status: 'active',
      workingDays: _selectedDays,
      startTime: currentSchool.startTime,
      endTime: currentSchool.endTime,
      gradingSystem: currentSchool.gradingSystem,
      setupCompleted: true,
    );

    final profileSaved = await ref.read(schoolSetupControllerProvider.notifier).saveProfile(updated);

    if (_sessionStart != null && _sessionEnd != null && _sessionNameController.text.isNotEmpty) {
      await ref.read(createAcademicSessionUsecaseProvider).call(
        schoolId: schoolId,
        name: _sessionNameController.text.trim(),
        startDate: _sessionStart!,
        endDate: _sessionEnd!,
        isCurrent: true,
      );
    }

    if (profileSaved && mounted) {
      context.go('/dashboard/admin');
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => isStart ? _sessionStart = picked : _sessionEnd = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(schoolSetupControllerProvider);
    final isLoading = setupState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('School Setup Wizard')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep++);
          } else {
            _finish();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: _currentStep == 2 ? 'Finish Setup' : 'Next',
                  onPressed: details.onStepContinue,
                  isLoading: isLoading,
                ),
              ),
              if (_currentStep > 0) ...[
                const SizedBox(width: 12),
                TextButton(onPressed: details.onStepCancel, child: const Text('Back')),
              ],
            ],
          ),
        ),
        steps: [
          Step(
            title: const Text('School Profile'),
            isActive: _currentStep >= 0,
            content: Column(
              children: [
                AppTextField(controller: _nameController, label: 'School Name', validator: Validators.name),
                const SizedBox(height: 12),
                AppTextField(controller: _addressController, label: 'Address'),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _contactController,
                  label: 'Contact Number',
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Academic Session'),
            isActive: _currentStep >= 1,
            content: Column(
              children: [
                AppTextField(controller: _sessionNameController, label: 'Session Name (e.g. 2026-2027)'),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(_sessionStart == null ? 'Select Start Date' : 'Start: ${_sessionStart!.toLocal()}'.split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _pickDate(isStart: true),
                ),
                ListTile(
                  title: Text(_sessionEnd == null ? 'Select End Date' : 'End: ${_sessionEnd!.toLocal()}'.split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _pickDate(isStart: false),
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Working Days'),
            isActive: _currentStep >= 2,
            content: Wrap(
              spacing: 8,
              children: _allDays.map((day) {
                final selected = _selectedDays.contains(day);
                return FilterChip(
                  label: Text(day),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      val ? _selectedDays.add(day) : _selectedDays.remove(day);
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
