import 'dart:io';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../datasources/announcement_remote_datasource.dart';
import '../models/announcement_model.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  final AnnouncementRemoteDatasource remote;
  AnnouncementRepositoryImpl(this.remote);

  @override
  Future<AnnouncementEntity> createAnnouncement(AnnouncementEntity announcement) {
    final model = AnnouncementModel(
      id: announcement.id,
      schoolId: announcement.schoolId,
      createdBy: announcement.createdBy,
      createdByName: announcement.createdByName,
      title: announcement.title,
      message: announcement.message,
      targetAudience: announcement.targetAudience,
      classId: announcement.classId,
      sectionId: announcement.sectionId,
      attachmentUrl: announcement.attachmentUrl,
      attachmentName: announcement.attachmentName,
      isPinned: announcement.isPinned,
      createdAt: announcement.createdAt,
    );
    return remote.createAnnouncement(model);
  }

  @override
  Future<String> uploadAttachment({required String announcementId, required File file}) {
    return remote.uploadAttachment(announcementId: announcementId, file: file);
  }

  @override
  Future<List<AnnouncementEntity>> getAnnouncementsForUser({required String schoolId, required String userId}) {
    return remote.getAnnouncementsForUser(schoolId: schoolId, userId: userId);
  }

  @override
  Future<void> markAsRead(String announcementId, String userId) => remote.markAsRead(announcementId, userId);

  @override
  Future<int> getUnreadCount(String schoolId, String userId) => remote.getUnreadCount(schoolId, userId);

  @override
  Future<void> deleteAnnouncement(String announcementId) => remote.deleteAnnouncement(announcementId);

  @override
  Future<void> togglePin(String announcementId, bool isPinned) => remote.togglePin(announcementId, isPinned);
}