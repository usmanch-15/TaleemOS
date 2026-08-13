import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init({required SupabaseClient client}) async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    final token = await _messaging.getToken();
    if (token != null) {
      await _registerToken(client, token);
    }

    _messaging.onTokenRefresh.listen((newToken) => _registerToken(client, newToken));

    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
    });
  }

  Future<void> _registerToken(SupabaseClient client, String token) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    await client.from('device_tokens').upsert({
      'user_id': userId,
      'fcm_token': token,
      'platform': 'android',
    }, onConflict: 'user_id,fcm_token');
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'taleemos_channel',
      'TaleemOS Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'TaleemOS',
      message.notification?.body ?? '',
      details,
    );
  }

  Future<void> unregisterToken(SupabaseClient client) async {
    final userId = client.auth.currentUser?.id;
    final token = await _messaging.getToken();
    if (userId == null || token == null) return;
    await client.from('device_tokens').delete().eq('user_id', userId).eq('fcm_token', token);
  }
}