import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authControllerProvider.notifier).resetPassword(_passwordController.text);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password successfully change ho gaya')));
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.status.name == 'loading';

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppTextField(controller: _passwordController, label: 'New Password', obscureText: true, validator: Validators.password),
            const SizedBox(height: 16),
            AppTextField(
              controller: _confirmController,
              label: 'Confirm New Password',
              obscureText: true,
              validator: (value) => Validators.confirmPassword(value, _passwordController.text),
            ),
            const SizedBox(height: 16),
            AppButton(label: 'Update Password', onPressed: _submit, isLoading: isLoading),
          ],
        ),
      ),
    );
  }
}