import 'package:equatable/equatable.dart';

class SchoolDashboardStats extends Equatable {
  final int totalStudents;
  final int totalTeachers;
  final int totalClasses;
  final double todayAttendancePercentage;
  final double pendingFeeAmount;
  final int openComplaints;

  const SchoolDashboardStats({
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalClasses,
    required this.todayAttendancePercentage,
    required this.pendingFeeAmount,
    required this.openComplaints,
  });

  @override
  List<Object?> get props => [totalStudents, totalTeachers, totalClasses, todayAttendancePercentage, pendingFeeAmount, openComplaints];
}

class ClassStudentCount extends Equatable {
  final String classId;
  final String className;
  final int studentCount;

  const ClassStudentCount({required this.classId, required this.className, required this.studentCount});

  @override
  List<Object?> get props => [classId, className, studentCount];
}

class AdmissionMonthData extends Equatable {
  final int month;
  final int count;

  const AdmissionMonthData({required this.month, required this.count});

  @override
  List<Object?> get props => [month, count];
}

class SubjectPerformance extends Equatable {
  final String subjectName;
  final double averageMarks;
  final double totalMarks;
  final double averagePercentage;

  const SubjectPerformance({
    required this.subjectName,
    required this.averageMarks,
    required this.totalMarks,
    required this.averagePercentage,
  });

  @override
  List<Object?> get props => [subjectName, averageMarks, totalMarks, averagePercentage];
}

class TeacherMarkingStatus extends Equatable {
  final String teacherId;
  final String teacherName;
  final String className;
  final bool hasMarked;

  const TeacherMarkingStatus({
    required this.teacherId,
    required this.teacherName,
    required this.className,
    required this.hasMarked,
  });

  @override
  List<Object?> get props => [teacherId, teacherName, className, hasMarked];
}

class GlobalPlatformStats extends Equatable {
  final int totalSchools;
  final int activeSchools;
  final int totalStudents;
  final int totalTeachers;
  final double totalRevenue;

  const GlobalPlatformStats({
    required this.totalSchools,
    required this.activeSchools,
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalRevenue,
  });

  @override
  List<Object?> get props => [totalSchools, activeSchools, totalStudents, totalTeachers, totalRevenue];
}

class SchoolSummary extends Equatable {
  final String schoolId;
  final String schoolName;
  final String status;
  final int studentCount;
  final int teacherCount;
  final String? subscriptionStatus;
  final DateTime? subscriptionExpiry;

  const SchoolSummary({
    required this.schoolId,
    required this.schoolName,
    required this.status,
    required this.studentCount,
    required this.teacherCount,
    this.subscriptionStatus,
    this.subscriptionExpiry,
  });

  @override
  List<Object?> get props => [schoolId, schoolName, status, studentCount, teacherCount, subscriptionStatus];
}