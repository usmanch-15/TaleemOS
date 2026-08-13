import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authControllerProvider.notifier).forgotPassword(_emailController.text);
    if (success) setState(() => _emailSent = true);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.status.name == 'loading';

    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _emailSent
            ? const Center(
          child: Text(
            'Password reset link aapke email par bhej di gayi hai. Email check karein.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        )
            : Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Apna registered email darj karein, hum aapko reset link bhejenge'),
              const SizedBox(height: 16),
              AppTextField(controller: _emailController, label: 'Email', keyboardType: TextInputType.emailAddress, validator: Validators.email),
              const SizedBox(height: 16),
              AppButton(label: 'Send Reset Link', onPressed: _submit, isLoading: isLoading),
            ],
          ),
        ),
      ),
    );
  }
}