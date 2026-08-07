import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remote;
  final SupabaseClient client;

  AuthRepositoryImpl({required this.remote, required this.client});

  @override
  Future<UserEntity> loginWithEmail({required String email, required String password}) {
    return remote.loginWithEmail(email: email, password: password);
  }

  @override
  Future<void> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
    required String schoolCode,
  }) {
    return remote.registerWithEmail(
      name: name,
      email: email,
      password: password,
      phone: phone,
      role: role,
      schoolCode: schoolCode,
    );
  }

  @override
  Future<void> sendPhoneOtp(String phone) => remote.sendPhoneOtp(phone);

  @override
  Future<UserEntity> verifyPhoneOtp({required String phone, required String otp}) {
    return remote.verifyPhoneOtp(phone: phone, otp: otp);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) => remote.sendPasswordResetEmail(email);

  @override
  Future<void> updatePassword(String newPassword) => remote.updatePassword(newPassword);

  @override
  Future<void> logout() => remote.logout();

  @override
  Future<void> logoutFromAllDevices() => remote.logoutFromAllDevices();

  @override
  Future<UserEntity?> getCurrentUser() => remote.getCurrentUser();

  @override
  Stream<UserEntity?> get authStateChanges {
    return client.auth.onAuthStateChange.asyncMap((state) async {
      if (state.session == null) return null;
      return remote.getCurrentUser();
    });
  }
}