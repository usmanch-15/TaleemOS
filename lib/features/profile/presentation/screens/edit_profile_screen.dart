import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../school/presentation/providers/school_provider.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  File? _newPhoto;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  Future<void> _pickPhoto() async {
    final picker = ref.read(imagePickerServiceProvider);
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _newPhoto = file);
  }

  Future<void> _save() async {
    if (_newPhoto != null) {
      await ref.read(profileControllerProvider.notifier).updatePhoto(_newPhoto!);
    }
    final success = await ref.read(profileControllerProvider.notifier).updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile update ho gaya')));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final state = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickPhoto,
              child: CircleAvatar(
                radius: 45,
                backgroundImage: _newPhoto != null
                    ? FileImage(_newPhoto!)
                    : (user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null) as ImageProvider?,
                child: _newPhoto == null && user?.photoUrl == null ? const Icon(Icons.add_a_photo, size: 30) : null,
              ),
            ),
          ),
          const SizedBox(height: 24),
          AppTextField(controller: _nameController, label: 'Full Name', validator: Validators.name),
          const SizedBox(height: 12),
          AppTextField(controller: _phoneController, label: 'Phone', keyboardType: TextInputType.phone),
          const SizedBox(height: 24),
          AppButton(label: 'Save Changes', onPressed: _save, isLoading: state.isLoading),
        ],
      ),
    );
  }
}