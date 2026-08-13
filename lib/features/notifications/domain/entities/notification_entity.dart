import 'package:equatable/equatable.dart';

class AppNotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String? body;
  final bool isRead;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const AppNotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.body,
    required this.isRead,
    this.metadata,
    required this.createdAt,
  });

  IconIdentifier get iconType {
    switch (type) {
      case 'attendance_absent':
        return IconIdentifier.attendance;
      case 'fee_due_reminder':
        return IconIdentifier.fee;
      case 'transport_status':
        return IconIdentifier.transport;
      default:
        return IconIdentifier.general;
    }
  }

  @override
  List<Object?> get props => [id, userId, type, title, isRead, createdAt];
}

enum IconIdentifier { attendance, fee, transport, general }