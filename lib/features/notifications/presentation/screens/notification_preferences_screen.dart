import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/validators.dart';

final notificationPrefsProvider = StateNotifierProvider<NotificationPrefsController, Map<String, bool>>((ref) {
  return NotificationPrefsController();
});

class NotificationPrefsController extends StateNotifier<Map<String, bool>> {
  NotificationPrefsController()
      : super({
    'attendance_alerts': true,
    'homework_alerts': true,
    'fee_reminders': true,
    'announcements': true,
    'exam_results': true,
  });

  void toggle(String key, bool value) {
    state = {...state, key: value};
    // TODO: persist to a user_notification_preferences table if granular server-side control is needed
  }
}

class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  static const _labels = {
    'attendance_alerts': 'Attendance Alerts (absent notifications)',
    'homework_alerts': 'Homework Alerts',
    'fee_reminders': 'Fee Due Reminders',
    'announcements': 'Announcements',
    'exam_results': 'Exam Results Published',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPrefsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Preferences')),
      body: ListView(
        children: _labels.entries.map((entry) {
          return SwitchListTile(
            title: Text(entry.value),
            value: prefs[entry.key] ?? true,
            onChanged: (value) => ref.read(notificationPrefsProvider.notifier).toggle(entry.key, value),
          );
        }).toList(),
      ),
    );
  }
}