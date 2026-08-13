import '../../domain/entities/report_entity.dart';

class SchoolDashboardStatsModel extends SchoolDashboardStats {
  const SchoolDashboardStatsModel({
    required super.totalStudents,
    required super.totalTeachers,
    required super.totalClasses,
    required super.todayAttendancePercentage,
    required super.pendingFeeAmount,
    required super.openComplaints,
  });

  factory SchoolDashboardStatsModel.fromMap(Map<String, dynamic> map) {
    return SchoolDashboardStatsModel(
      totalStudents: (map['total_students'] as num?)?.toInt() ?? 0,
      totalTeachers: (map['total_teachers'] as num?)?.toInt() ?? 0,
      totalClasses: (map['total_classes'] as num?)?.toInt() ?? 0,
      todayAttendancePercentage: (map['today_attendance_percentage'] as num?)?.toDouble() ?? 0,
      pendingFeeAmount: (map['pending_fee_amount'] as num?)?.toDouble() ?? 0,
      openComplaints: (map['open_complaints'] as num?)?.toInt() ?? 0,
    );
  }
}

class ClassStudentCountModel extends ClassStudentCount {
  const ClassStudentCountModel({required super.classId, required super.className, required super.studentCount});

  factory ClassStudentCountModel.fromMap(Map<String, dynamic> map) {
    return ClassStudentCountModel(
      classId: map['class_id'] as String,
      className: map['class_name'] as String,
      studentCount: (map['student_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class AdmissionMonthDataModel extends AdmissionMonthData {
  const AdmissionMonthDataModel({required super.month, required super.count});

  factory AdmissionMonthDataModel.fromMap(Map<String, dynamic> map) {
    return AdmissionMonthDataModel(
      month: (map['month'] as num).toInt(),
      count: (map['admission_count'] as num).toInt(),
    );
  }
}

class SubjectPerformanceModel extends SubjectPerformance {
  const SubjectPerformanceModel({
    required super.subjectName,
    required super.averageMarks,
    required super.totalMarks,
    required super.averagePercentage,
  });

  factory SubjectPerformanceModel.fromMap(Map<String, dynamic> map) {
    return SubjectPerformanceModel(
      subjectName: map['subject_name'] as String,
      averageMarks: (map['average_marks'] as num?)?.toDouble() ?? 0,
      totalMarks: (map['total_marks'] as num?)?.toDouble() ?? 0,
      averagePercentage: (map['average_percentage'] as num?)?.toDouble() ?? 0,
    );
  }
}

class TeacherMarkingStatusModel extends TeacherMarkingStatus {
  const TeacherMarkingStatusModel({
    required super.teacherId,
    required super.teacherName,
    required super.className,
    required super.hasMarked,
  });

  factory TeacherMarkingStatusModel.fromMap(Map<String, dynamic> map) {
    return TeacherMarkingStatusModel(
      teacherId: map['teacher_id'] as String,
      teacherName: map['teacher_name'] as String,
      className: map['class_name'] as String,
      hasMarked: map['has_marked'] as bool? ?? false,
    );
  }
}

class GlobalPlatformStatsModel extends GlobalPlatformStats {
  const GlobalPlatformStatsModel({
    required super.totalSchools,
    required super.activeSchools,
    required super.totalStudents,
    required super.totalTeachers,
    required super.totalRevenue,
  });

  factory GlobalPlatformStatsModel.fromMap(Map<String, dynamic> map) {
    return GlobalPlatformStatsModel(
      totalSchools: (map['total_schools'] as num?)?.toInt() ?? 0,
      activeSchools: (map['active_schools'] as num?)?.toInt() ?? 0,
      totalStudents: (map['total_students'] as num?)?.toInt() ?? 0,
      totalTeachers: (map['total_teachers'] as num?)?.toInt() ?? 0,
      totalRevenue: (map['total_revenue'] as num?)?.toDouble() ?? 0,
    );
  }
}

class SchoolSummaryModel extends SchoolSummary {
  const SchoolSummaryModel({
    required super.schoolId,
    required super.schoolName,
    required super.status,
    required super.studentCount,
    required super.teacherCount,
    super.subscriptionStatus,
    super.subscriptionExpiry,
  });

  factory SchoolSummaryModel.fromMap(Map<String, dynamic> map) {
    return SchoolSummaryModel(
      schoolId: map['school_id'] as String,
      schoolName: map['school_name'] as String,
      status: map['status'] as String,
      studentCount: (map['student_count'] as num?)?.toInt() ?? 0,
      teacherCount: (map['teacher_count'] as num?)?.toInt() ?? 0,
      subscriptionStatus: map['subscription_status'] as String?,
      subscriptionExpiry: map['subscription_expiry'] != null ? DateTime.parse(map['subscription_expiry'] as String) : null,
    );
  }
}