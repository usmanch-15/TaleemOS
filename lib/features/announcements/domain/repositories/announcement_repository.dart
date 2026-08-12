import 'dart:io';
import '../entities/announcement_entity.dart';

abstract class AnnouncementRepository {
  Future<AnnouncementEntity> createAnnouncement(AnnouncementEntity announcement);
  Future<String> uploadAttachment({required String announcementId, required File file});
  Future<List<AnnouncementEntity>> getAnnouncementsForUser({required String schoolId, required String userId});
  Future<void> markAsRead(String announcementId, String userId);
  Future<int> getUnreadCount(String schoolId, String userId);
  Future<void> deleteAnnouncement(String announcementId);
  Future<void> togglePin(String announcementId, bool isPinned);
}