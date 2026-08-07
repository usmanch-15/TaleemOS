import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> loginWithEmail({required String email, required String password});

  Future<void> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
    required String schoolCode,
  });

  Future<void> sendPhoneOtp(String phone);

  Future<UserEntity> verifyPhoneOtp({required String phone, required String otp});

  Future<void> sendPasswordResetEmail(String email);

  Future<void> updatePassword(String newPassword);

  Future<void> logout();

  Future<void> logoutFromAllDevices();

  Future<UserEntity?> getCurrentUser();

  Stream<UserEntity?> get authStateChanges;
}