import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImagePickerService {
  final SupabaseClient client;
  ImagePickerService(this.client);

  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 70, maxWidth: 800);
    if (picked == null) return null;
    return File(picked.path);
  }

  Future<String> uploadImage({
    required File file,
    required String bucket,
    required String path,
  }) async {
    await client.storage.from(bucket).upload(
      path,
      file,
      fileOptions: const FileOptions(upsert: true),
    );
    return client.storage.from(bucket).getPublicUrl(path);
  }
}