import 'package:equatable/equatable.dart';

enum UserRole {
  superAdmin,
  admin,
  teacher,
  parent,
  student,
  accountant,
  transportManager;

  static UserRole fromString(String value) {
    switch (value) {
      case 'super_admin':
        return UserRole.superAdmin;
      case 'admin':
        return UserRole.admin;
      case 'teacher':
        return UserRole.teacher;
      case 'parent':
        return UserRole.parent;
      case 'student':
        return UserRole.student;
      case 'accountant':
        return UserRole.accountant;
      case 'transport_manager':
        return UserRole.transportManager;
      default:
        throw ArgumentError('Unknown role: $value');
    }
  }

  String toDbString() {
    switch (this) {
      case UserRole.superAdmin:
        return 'super_admin';
      case UserRole.admin:
        return 'admin';
      case UserRole.teacher:
        return 'teacher';
      case UserRole.parent:
        return 'parent';
      case UserRole.student:
        return 'student';
      case UserRole.accountant:
        return 'accountant';
      case UserRole.transportManager:
        return 'transport_manager';
    }
  }
}

enum UserStatus { active, inactive, pendingApproval }

class UserEntity extends Equatable {
  final String id;
  final String? schoolId;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final UserStatus status;
  final String? photoUrl;

  const UserEntity({
    required this.id,
    this.schoolId,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.status,
    this.photoUrl,
  });

  bool get isApproved => status == UserStatus.active;

  @override
  List<Object?> get props => [id, schoolId, name, email, phone, role, status, photoUrl];
}