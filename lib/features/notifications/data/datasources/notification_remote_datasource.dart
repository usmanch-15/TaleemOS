import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationRemoteDatasource {
  final SupabaseClient client;
  NotificationRemoteDatasource(this.client);

  Future<List<AppNotificationEntity>> getNotifications(String userId) async {
    final data = await client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(100);

    return (data as List)
        .map((e) => AppNotificationEntity(
      id: e['id'] as String,
      userId: e['user_id'] as String,
      type: e['type'] as String,
      title: e['title'] as String,
      body: e['body'] as String?,
      isRead: e['is_read'] as bool? ?? false,
      metadata: e['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(e['created_at'] as String),
    ))
        .toList();
  }

  Future<void> markAsRead(String notificationId) async {
    await client.from('notifications').update({'is_read': true}).eq('id', notificationId);
  }

  Future<void> markAllAsRead(String userId) async {
    await client.from('notifications').update({'is_read': true}).eq('user_id', userId).eq('is_read', false);
  }

  Future<int> getUnreadCount(String userId) async {
    final result = await client.from('notifications').select('id').eq('user_id', userId).eq('is_read', false).count(CountOption.exact);
    return result.count;
  }
}