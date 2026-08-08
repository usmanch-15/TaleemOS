import 'package:equatable/equatable.dart';

enum StudentStatus { active, inactive, graduated }

class StudentEntity extends Equatable {
  final String id;
  final String schoolId;
  final String? userId;
  final String fullName;
  final String? fatherName;
  final DateTime? dob;
  final String? gender;
  final String? profileImageUrl;
  final String studentCode;
  final String? rollNumber;
  final String? classId;
  final String? sectionId;
  final DateTime admissionDate;
  final String? phone;
  final String? address;
  final String? bloodGroup;
  final String? emergencyContact;
  final String? previousSchool;
  final StudentStatus status;

  const StudentEntity({
    required this.id,
    required this.schoolId,
    this.userId,
    required this.fullName,
    this.fatherName,
    this.dob,
    this.gender,
    this.profileImageUrl,
    required this.studentCode,
    this.rollNumber,
    this.classId,
    this.sectionId,
    required this.admissionDate,
    this.phone,
    this.address,
    this.bloodGroup,
    this.emergencyContact,
    this.previousSchool,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id, schoolId, userId, fullName, fatherName, dob, gender, profileImageUrl,
    studentCode, rollNumber, classId, sectionId, admissionDate, phone, address,
    bloodGroup, emergencyContact, previousSchool, status,
  ];
}