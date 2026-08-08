import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../classes/presentation/providers/class_provider.dart';
import '../../../school/presentation/providers/school_provider.dart';
import '../../domain/entities/student_entity.dart';
import '../providers/student_provider.dart';

class AddStudentScreen extends ConsumerStatefulWidget {
  const AddStudentScreen({super.key});

  @override
  ConsumerState<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends ConsumerState<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  DateTime? _dob;
  String? _selectedGender;
  String? _selectedClassId;
  String? _selectedSectionId;
  File? _photo;

  Future<void> _pickPhoto() async {
    final picker = ref.read(imagePickerServiceProvider);
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _photo = file);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Class select karein')));
      return;
    }

    final schoolId = ref.read(authControllerProvider).user?.schoolId;
    if (schoolId == null) return;

    final code = await ref.read(studentRepositoryProvider).generateStudentCode(schoolId);

    final student = StudentEntity(
      id: '',
      schoolId: schoolId,
      fullName: _nameController.text.trim(),
      fatherName: _fatherNameController.text.trim(),
      dob: _dob,
      gender: _selectedGender,
      studentCode: code,
      rollNumber: _rollNumberController.text.trim(),
      classId: _selectedClassId,
      sectionId: _selectedSectionId,
      admissionDate: DateTime.now(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      bloodGroup: _bloodGroupController.text.trim(),
      emergencyContact: _emergencyContactController.text.trim(),
      status: StudentStatus.active,
    );

    final success = await ref.read(studentFormControllerProvider.notifier).saveStudent(student, photo: _photo);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Student add ho gaya')));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(classesListProvider);
    final formState = ref.watch(studentFormControllerProvider);
    final isLoading = formState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Student')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage: _photo != null ? FileImage(_photo!) : null,
                  child: _photo == null ? const Icon(Icons.add_a_photo, size: 30) : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            AppTextField(controller: _nameController, label: 'Full Name', validator: Validators.name),
            const SizedBox(height: 12),
            AppTextField(controller: _fatherNameController, label: 'Father Name'),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_dob == null ? 'Select Date of Birth' : 'DOB: ${_dob!.toLocal()}'.split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2015),
                  firstDate: DateTime(1990),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _dob = picked);
              },
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Gender'),
              items: const [
                DropdownMenuItem(value: 'male', child: Text('Male')),
                DropdownMenuItem(value: 'female', child: Text('Female')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (value) => setState(() => _selectedGender = value),
            ),
            const SizedBox(height: 12),
            classesAsync.when(
              data: (classes) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Class'),
                items: classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (value) => setState(() {
                  _selectedClassId = value;
                  _selectedSectionId = null;
                }),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Classes load nahi hui'),
            ),
            if (_selectedClassId != null) ...[
              const SizedBox(height: 12),
              Consumer(
                builder: (context, ref, _) {
                  final sectionsAsync = ref.watch(sectionsForClassProvider(_selectedClassId!));
                  return sectionsAsync.when(
                    data: (sections) => DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Section'),
                      items: sections.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                      onChanged: (value) => setState(() => _selectedSectionId = value),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Sections load nahi hui'),
                  );
                },
              ),
            ],
            const SizedBox(height: 12),
            AppTextField(controller: _rollNumberController, label: 'Roll Number'),
            const SizedBox(height: 12),
            AppTextField(controller: _phoneController, label: 'Phone', keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            AppTextField(controller: _addressController, label: 'Address'),
            const SizedBox(height: 12),
            AppTextField(controller: _bloodGroupController, label: 'Blood Group'),
            const SizedBox(height: 12),
            AppTextField(controller: _emergencyContactController, label: 'Emergency Contact'),
            const SizedBox(height: 24),
            AppButton(label: 'Save Student', onPressed: _submit, isLoading: isLoading),
          ],
        ),
      ),
    );
  }
}