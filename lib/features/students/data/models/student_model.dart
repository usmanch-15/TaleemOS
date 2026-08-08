import '../../domain/entities/student_entity.dart';

class StudentModel extends StudentEntity {
  const StudentModel({
    required super.id,
    required super.schoolId,
    super.userId,
    required super.fullName,
    super.fatherName,
    super.dob,
    super.gender,
    super.profileImageUrl,
    required super.studentCode,
    super.rollNumber,
    super.classId,
    super.sectionId,
    required super.admissionDate,
    super.phone,
    super.address,
    super.bloodGroup,
    super.emergencyContact,
    super.previousSchool,
    required super.status,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'] as String,
      schoolId: map['school_id'] as String,
      userId: map['user_id'] as String?,
      fullName: map['full_name'] as String,
      fatherName: map['father_name'] as String?,
      dob: map['dob'] != null ? DateTime.parse(map['dob'] as String) : null,
      gender: map['gender'] as String?,
      profileImageUrl: map['profile_image_url'] as String?,
      studentCode: map['student_code'] as String,
      rollNumber: map['roll_number'] as String?,
      classId: map['class_id'] as String?,
      sectionId: map['section_id'] as String?,
      admissionDate: DateTime.parse(map['admission_date'] as String),
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      bloodGroup: map['blood_group'] as String?,
      emergencyContact: map['emergency_contact'] as String?,
      previousSchool: map['previous_school'] as String?,
      status: _statusFromString(map['status'] as String? ?? 'active'),
    );
  }

  Map<String, dynamic> toInsertMap(String schoolId) {
    return {
      'school_id': schoolId,
      'full_name': fullName,
      'father_name': fatherName,
      'dob': dob?.toIso8601String(),
      'gender': gender,
      'profile_image_url': profileImageUrl,
      'student_code': studentCode,
      'roll_number': rollNumber,
      'class_id': classId,
      'section_id': sectionId,
      'admission_date': admissionDate.toIso8601String(),
      'phone': phone,
      'address': address,
      'blood_group': bloodGroup,
      'emergency_contact': emergencyContact,
      'previous_school': previousSchool,
      'status': _statusToString(status),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    final map = toInsertMap(schoolId);
    map.remove('school_id');
    map.remove('student_code');
    return map;
  }

  static StudentStatus _statusFromString(String value) {
    switch (value) {
      case 'inactive':
        return StudentStatus.inactive;
      case 'graduated':
        return StudentStatus.graduated;
      default:
        return StudentStatus.active;
    }
  }

  static String _statusToString(StudentStatus status) {
    switch (status) {
      case StudentStatus.active:
        return 'active';
      case StudentStatus.inactive:
        return 'inactive';
      case StudentStatus.graduated:
        return 'graduated';
    }
  }
}