import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;

  Future<void> _sendOtp() async {
    final error = Validators.phone(_phoneController.text);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final success = await ref.read(authControllerProvider.notifier).sendOtp(_phoneController.text);
    if (success) setState(() => _otpSent = true);
  }

  Future<void> _verifyOtp() async {
    final error = Validators.otp(_otpController.text);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final success = await ref.read(authControllerProvider.notifier).verifyOtp(
      phone: _phoneController.text,
      otp: _otpController.text,
    );
    if (success && mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.status == AuthStatus.loading;

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Phone Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(controller: _phoneController, label: 'Phone Number', keyboardType: TextInputType.phone, validator: Validators.phone),
            const SizedBox(height: 16),
            if (_otpSent) ...[
              AppTextField(controller: _otpController, label: '6-digit OTP', keyboardType: TextInputType.number, validator: Validators.otp),
              const SizedBox(height: 16),
              AppButton(label: 'Verify OTP', onPressed: _verifyOtp, isLoading: isLoading),
              TextButton(onPressed: _sendOtp, child: const Text('OTP dobara bhejein')),
            ] else
              AppButton(label: 'Send OTP', onPressed: _sendOtp, isLoading: isLoading),
          ],
        ),
      ),
    );
  }
}