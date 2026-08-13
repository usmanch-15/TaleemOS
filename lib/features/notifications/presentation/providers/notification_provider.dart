import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../domain/entities/notification_entity.dart';

final notificationRemoteDatasourceProvider = Provider<NotificationRemoteDatasource>((ref) {
  return NotificationRemoteDatasource(ref.watch(supabaseClientProvider));
});

final notificationsListProvider = FutureProvider.autoDispose<List<AppNotificationEntity>>((ref) async {
  final userId = ref.watch(authControllerProvider).user?.id;
  if (userId == null) return [];
  return ref.watch(notificationRemoteDatasourceProvider).getNotifications(userId);
});

final unreadNotificationCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final userId = ref.watch(authControllerProvider).user?.id;
  if (userId == null) return 0;
  return ref.watch(notificationRemoteDatasourceProvider).getUnreadCount(userId);
});

class NotificationController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  NotificationController(this.ref) : super(const AsyncValue.data(null));

  Future<void> markAsRead(String notificationId) async {
    await ref.read(notificationRemoteDatasourceProvider).markAsRead(notificationId);
    ref.invalidate(notificationsListProvider);
    ref.invalidate(unreadNotificationCountProvider);
  }

  Future<void> markAllAsRead() async {
    final userId = ref.read(authControllerProvider).user?.id;
    if (userId == null) return;
    await ref.read(notificationRemoteDatasourceProvider).markAllAsRead(userId);
    ref.invalidate(notificationsListProvider);
    ref.invalidate(unreadNotificationCountProvider);
  }
}

final notificationControllerProvider =
StateNotifierProvider<NotificationController, AsyncValue<void>>((ref) => NotificationController(ref));