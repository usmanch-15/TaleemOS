import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/image_picker_service.dart';
import '../models/announcement_model.dart';

class AnnouncementRemoteDatasource {
  final SupabaseClient client;
  final ImagePickerService imagePickerService;

  AnnouncementRemoteDatasource(this.client, this.imagePickerService);

  Future<AnnouncementModel> createAnnouncement(AnnouncementModel announcement) async {
    final data = await client
        .from('announcements')
        .insert(announcement.toInsertMap())
        .select('*, users(name), classes(name)')
        .single();
    return AnnouncementModel.fromMap(data);
  }

  Future<String> uploadAttachment({required String announcementId, required File file}) async {
    final fileName = file.path.split('/').last;
    final path = '$announcementId/$fileName';
    return imagePickerService.uploadImage(file: file, bucket: 'announcement-attachments', path: path);
  }

  Future<List<AnnouncementModel>> getAnnouncementsForUser({
    required String schoolId,
    required String userId,
  }) async {
    final data = await client
        .from('announcements')
        .select('*, users(name), classes(name)')
        .eq('school_id', schoolId)
        .order('is_pinned', ascending: false)
        .order('created_at', ascending: false);

    final readData = await client.from('announcement_reads').select('announcement_id').eq('user_id', userId);
    final readIds = (readData as List).map((r) => r['announcement_id'] as String).toSet();

    return (data as List).map((e) => AnnouncementModel.fromMap(e, isRead: readIds.contains(e['id']))).toList();
  }

  Future<void> markAsRead(String announcementId, String userId) async {
    await client.from('announcement_reads').upsert({
      'announcement_id': announcementId,
      'user_id': userId,
    }, onConflict: 'announcement_id,user_id');
  }

  Future<int> getUnreadCount(String schoolId, String userId) async {
    final result = await client.rpc('get_unread_announcement_count', params: {
      'p_user_id': userId,
      'p_school_id': schoolId,
    });
    return (result as num).toInt();
  }

  Future<void> deleteAnnouncement(String announcementId) async {
    await client.from('announcements').delete().eq('id', announcementId);
  }

  Future<void> togglePin(String announcementId, bool isPinned) async {
    await client.from('announcements').update({'is_pinned': isPinned}).eq('id', announcementId);
  }
}