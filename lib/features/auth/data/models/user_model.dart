import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.schoolId,
    required super.name,
    required super.email,
    super.phone,
    required super.role,
    required super.status,
    super.photoUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      schoolId: map['school_id'] as String?,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String?,
      role: UserRole.fromString(map['role'] as String),
      status: _statusFromString(map['status'] as String? ?? 'pending_approval'),
      photoUrl: map['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school_id': schoolId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.toDbString(),
      'status': _statusToString(status),
      'photo_url': photoUrl,
    };
  }

  static UserStatus _statusFromString(String value) {
    switch (value) {
      case 'active':
        return UserStatus.active;
      case 'inactive':
        return UserStatus.inactive;
      default:
        return UserStatus.pendingApproval;
    }
  }

  static String _statusToString(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return 'active';
      case UserStatus.inactive:
        return 'inactive';
      case UserStatus.pendingApproval:
        return 'pending_approval';
    }
  }
}