import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/error/app_exception.dart';
import '../models/user_model.dart';

class AuthRemoteDatasource {
  final SupabaseClient client;

  AuthRemoteDatasource(this.client);

  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    final authUser = response.user;
    if (authUser == null) {
      throw const AuthException('Login fail ho gaya, dobara try karein');
    }

    return _fetchUserProfile(authUser.id);
  }

  Future<void> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
    required String schoolCode,
  }) async {
    // Step 1: school code se school_id resolve karein
    final schoolResult = await client
        .from('schools')
        .select('id, status')
        .eq('school_code', schoolCode.trim())
        .maybeSingle();

    if (schoolResult == null) {
      throw const ValidationException('School code invalid hai');
    }
    if (schoolResult['status'] == 'blocked') {
      throw const ValidationException('Ye school block hai, admin se rabta karein');
    }

    // Step 2: auth user create karein
    final authResponse = await client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'pending_role': role, 'pending_school_id': schoolResult['id']},
    );

    final authUser = authResponse.user;
    if (authUser == null) {
      throw const AuthException('Registration fail ho gaya');
    }

    // Step 3: users table mein profile insert karein
    await client.from('users').insert({
      'id': authUser.id,
      'school_id': schoolResult['id'],
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'role': role,
      'status': role == 'admin' ? 'pending_approval' : 'active',
    });
  }

  Future<void> sendPhoneOtp(String phone) async {
    await client.auth.signInWithOtp(phone: phone.trim());
  }

  Future<UserModel> verifyPhoneOtp({
    required String phone,
    required String otp,
  }) async {
    final response = await client.auth.verifyOTP(
      phone: phone.trim(),
      token: otp.trim(),
      type: OtpType.sms,
    );

    final authUser = response.user;
    if (authUser == null) {
      throw const AuthException('OTP verify nahi ho saka');
    }

    return _fetchUserProfile(authUser.id);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await client.auth.resetPasswordForEmail(email.trim());
  }

  Future<void> updatePassword(String newPassword) async {
    await client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> logout() async {
    await client.auth.signOut(scope: SignOutScope.local);
  }

  Future<void> logoutFromAllDevices() async {
    await client.auth.signOut(scope: SignOutScope.global);
  }

  Future<UserModel?> getCurrentUser() async {
    final authUser = client.auth.currentUser;
    if (authUser == null) return null;
    return _fetchUserProfile(authUser.id);
  }

  Future<UserModel> _fetchUserProfile(String userId) async {
    final data = await client.from('users').select().eq('id', userId).maybeSingle();

    if (data == null) {
      throw const AuthException('User profile nahi mila, admin se rabta karein');
    }
    return UserModel.fromMap(data);
  }
}