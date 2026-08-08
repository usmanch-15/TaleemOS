import '../../domain/entities/teacher_entity.dart';

class TeacherModel extends TeacherEntity {
  const TeacherModel({
    required super.id,
    required super.schoolId,
    required super.userId,
    required super.name,
    required super.email,
    super.phone,
    super.photoUrl,
    super.employeeCode,
    required super.joiningDate,
    required super.status,
    super.assignments,
  });

  factory TeacherModel.fromMap(Map<String, dynamic> map) {
    final user = map['users'] as Map<String, dynamic>? ?? {};
    return TeacherModel(
      id: map['id'] as String,
      schoolId: map['school_id'] as String,
      userId: map['user_id'] as String,
      name: user['name'] as String? ?? '',
      email: user['email'] as String? ?? '',
      phone: user['phone'] as String?,
      photoUrl: user['photo_url'] as String?,
      employeeCode: map['employee_code'] as String?,
      joiningDate: DateTime.parse(map['joining_date'] as String),
      status: map['status'] as String? ?? 'active',
    );
  }
}