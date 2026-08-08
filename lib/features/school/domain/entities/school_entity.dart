import 'package:equatable/equatable.dart';

class GradeBand extends Equatable {
  final String grade;
  final int min;
  final int max;

  const GradeBand({required this.grade, required this.min, required this.max});

  factory GradeBand.fromMap(Map<String, dynamic> map) => GradeBand(
    grade: map['grade'] as String,
    min: map['min'] as int,
    max: map['max'] as int,
  );

  Map<String, dynamic> toMap() => {'grade': grade, 'min': min, 'max': max};

  @override
  List<Object?> get props => [grade, min, max];
}

class SchoolEntity extends Equatable {
  final String id;
  final String name;
  final String schoolCode;
  final String? logoUrl;
  final String? address;
  final String? contactNumber;
  final String status;
  final List<String> workingDays;
  final String startTime;
  final String endTime;
  final List<GradeBand> gradingSystem;
  final bool setupCompleted;

  const SchoolEntity({
    required this.id,
    required this.name,
    required this.schoolCode,
    this.logoUrl,
    this.address,
    this.contactNumber,
    required this.status,
    required this.workingDays,
    required this.startTime,
    required this.endTime,
    required this.gradingSystem,
    required this.setupCompleted,
  });

  @override
  List<Object?> get props =>
      [id, name, schoolCode, logoUrl, address, contactNumber, status, workingDays, startTime, endTime, setupCompleted];
}