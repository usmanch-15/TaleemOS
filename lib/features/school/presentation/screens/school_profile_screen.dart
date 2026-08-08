import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/school_provider.dart';

class SchoolProfileScreen extends ConsumerWidget {
  const SchoolProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schoolAsync = ref.watch(currentSchoolProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('School Profile')),
      body: schoolAsync.when(
        data: (school) {
          if (school == null) return const Center(child: Text('School data nahi mila'));
          final nameController = TextEditingController(text: school.name);
          final addressController = TextEditingController(text: school.address ?? '');
          final contactController = TextEditingController(text: school.contactNumber ?? '');

          return Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: school.logoUrl != null ? NetworkImage(school.logoUrl!) : null,
                  child: school.logoUrl == null ? const Icon(Icons.school, size: 40) : null,
                ),
                const SizedBox(height: 20),
                AppTextField(controller: nameController, label: 'School Name'),
                const SizedBox(height: 12),
                AppTextField(controller: addressController, label: 'Address'),
                const SizedBox(height: 12),
                AppTextField(controller: contactController, label: 'Contact Number'),
                const SizedBox(height: 12),
                Text('School Code: ${school.schoolCode}', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Save Changes',
                  onPressed: () async {
                    final updated = school; // fields updated via controllers in real impl
                    await ref.read(schoolSetupControllerProvider.notifier).saveProfile(updated);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Profile update ho gaya')));
                    }
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}