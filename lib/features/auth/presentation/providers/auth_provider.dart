import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../../../core/error/error_handler.dart';
import '../../../../core/services/supabase_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'auth_state.dart';

// ---- DI providers ----
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return SupabaseService.instance.client;
});

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(ref.watch(supabaseClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(authRemoteDatasourceProvider),
    client: ref.watch(supabaseClientProvider),
  );
});

final loginUsecaseProvider = Provider((ref) => LoginUsecase(ref.watch(authRepositoryProvider)));
final registerUsecaseProvider = Provider((ref) => RegisterUsecase(ref.watch(authRepositoryProvider)));
final sendOtpUsecaseProvider = Provider((ref) => SendOtpUsecase(ref.watch(authRepositoryProvider)));
final verifyOtpUsecaseProvider = Provider((ref) => VerifyOtpUsecase(ref.watch(authRepositoryProvider)));
final forgotPasswordUsecaseProvider = Provider((ref) => ForgotPasswordUsecase(ref.watch(authRepositoryProvider)));
final resetPasswordUsecaseProvider = Provider((ref) => ResetPasswordUsecase(ref.watch(authRepositoryProvider)));
final logoutUsecaseProvider = Provider((ref) => LogoutUsecase(ref.watch(authRepositoryProvider)));
final getCurrentUserUsecaseProvider = Provider((ref) => GetCurrentUserUsecase(ref.watch(authRepositoryProvider)));

// ---- Auth controller ----
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AuthState> {
  final Ref ref;

  AuthController(this.ref) : super(const AuthState()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await ref.read(getCurrentUserUsecaseProvider).call();
      state = user != null
          ? state.copyWith(status: AuthStatus.authenticated, user: user)
          : state.copyWith(status: AuthStatus.unauthenticated);
    } catch (_) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final user = await ref.read(loginUsecaseProvider).call(email: email, password: password);
      if (!user.isApproved) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Aapka account abhi admin approval ka intezar kar raha hai',
        );
        return false;
      }
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: ErrorHandler.handle(e).message);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
    required String schoolCode,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      await ref.read(registerUsecaseProvider).call(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
        schoolCode: schoolCode,
      );
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: ErrorHandler.handle(e).message);
      return false;
    }
  }

  Future<bool> sendOtp(String phone) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      await ref.read(sendOtpUsecaseProvider).call(phone);
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: ErrorHandler.handle(e).message);
      return false;
    }
  }

  Future<bool> verifyOtp({required String phone, required String otp}) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      final user = await ref.read(verifyOtpUsecaseProvider).call(phone: phone, otp: otp);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: ErrorHandler.handle(e).message);
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      await ref.read(forgotPasswordUsecaseProvider).call(email);
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: ErrorHandler.handle(e).message);
      return false;
    }
  }

  Future<bool> resetPassword(String newPassword) async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
    try {
      await ref.read(resetPasswordUsecaseProvider).call(newPassword);
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: ErrorHandler.handle(e).message);
      return false;
    }
  }

  Future<void> logout({bool allDevices = false}) async {
    await ref.read(logoutUsecaseProvider).call(allDevices: allDevices);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}