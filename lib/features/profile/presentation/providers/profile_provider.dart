import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../school/presentation/providers/school_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class ProfileController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  ProfileController(this.ref) : super(const AsyncValue.data(null));

  Future<bool> updateProfile({required String name, String? phone}) async {
    final userId = ref.read(authControllerProvider).user?.id;
    if (userId == null) return false;

    state = const AsyncValue.loading();
    try {
      await ref.read(supabaseClientProvider).from('users').update({
        'name': name,
        'phone': phone,
      }).eq('id', userId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<String?> updatePhoto(File file) async {
    final userId = ref.read(authControllerProvider).user?.id;
    if (userId == null) return null;

    try {
      final imagePicker = ref.read(imagePickerServiceProvider);
      final ext = file.path.split('.').last;
      final path = '$userId/profile.$ext';
      final url = await imagePicker.uploadImage(file: file, bucket: 'user-photos', path: path);

      await ref.read(supabaseClientProvider).from('users').update({'photo_url': url}).eq('id', userId);
      return url;
    } catch (_) {
      return null;
    }
  }

  Future<bool> changePassword(String newPassword) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(supabaseClientProvider).auth.updateUser(
        UserAttributes(password: newPassword),
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final profileControllerProvider = StateNotifierProvider<ProfileController, AsyncValue<void>>((ref) => ProfileController(ref));