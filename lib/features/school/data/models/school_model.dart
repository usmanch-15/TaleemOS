import '../../domain/entities/school_entity.dart';

class SchoolModel extends SchoolEntity {
  const SchoolModel({
    required super.id,
    required super.name,
    required super.schoolCode,
    super.logoUrl,
    super.address,
    super.contactNumber,
    required super.status,
    required super.workingDays,
    required super.startTime,
    required super.endTime,
    required super.gradingSystem,
    required super.setupCompleted,
  });

  factory SchoolModel.fromMap(Map<String, dynamic> map) {
    final timing = map['academic_timing'] as Map<String, dynamic>? ?? {};
    final grading = (map['grading_system'] as List<dynamic>? ?? [])
        .map((e) => GradeBand.fromMap(e as Map<String, dynamic>))
        .toList();
    final days = (map['working_days'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();

    return SchoolModel(
      id: map['id'] as String,
      name: map['name'] as String,
      schoolCode: map['school_code'] as String,
      logoUrl: map['logo_url'] as String?,
      address: map['address'] as String?,
      contactNumber: map['contact_number'] as String?,
      status: map['status'] as String? ?? 'pending',
      workingDays: days,
      startTime: timing['start_time'] as String? ?? '08:00',
      endTime: timing['end_time'] as String? ?? '14:00',
      gradingSystem: grading,
      setupCompleted: map['setup_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'logo_url': logoUrl,
      'address': address,
      'contact_number': contactNumber,
      'academic_timing': {'start_time': startTime, 'end_time': endTime},
      'working_days': workingDays,
      'grading_system': gradingSystem.map((g) => g.toMap()).toList(),
      'setup_completed': setupCompleted,
    };
  }
}