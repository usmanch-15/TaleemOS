import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/providers/auth_state.dart';

import '../features/auth/domain/entities/user_entity.dart';

import '../features/school/presentation/screens/school_setup_wizard_screen.dart';
import '../features/school/presentation/screens/school_profile_screen.dart';

import '../features/students/presentation/screens/students_list_screen.dart';
import '../features/students/presentation/screens/add_student_screen.dart';
import '../features/students/presentation/screens/student_detail_screen.dart';
import '../features/teachers/presentation/screens/teachers_list_screen.dart';
import '../features/teachers/presentation/screens/add_teacher_screen.dart';
import '../features/teachers/presentation/screens/teacher_detail_screen.dart';


import '../features/homework/presentation/screens/homework_list_screen.dart';
import '../features/homework/presentation/screens/create_homework_screen.dart';
import '../features/homework/presentation/screens/homework_detail_teacher_screen.dart';
import '../features/homework/presentation/screens/student_homework_list_screen.dart';
import '../features/homework/presentation/screens/submit_homework_screen.dart';
import '../features/homework/presentation/screens/parent_homework_screen.dart';

import '../features/exams/presentation/screens/exams_list_screen.dart';
import '../features/exams/presentation/screens/create_exam_screen.dart';
import '../features/exams/presentation/screens/exam_detail_screen.dart';
import '../features/exams/presentation/screens/marks_entry_screen.dart';
import '../features/exams/presentation/screens/class_results_screen.dart';
import '../features/exams/presentation/screens/student_results_screen.dart';
import '../features/exams/presentation/screens/report_card_screen.dart';

import '../features/fees/presentation/screens/fee_dashboard_screen.dart';
import '../features/fees/presentation/screens/fee_structures_screen.dart';
import '../features/fees/presentation/screens/generate_invoices_screen.dart';
import '../features/fees/presentation/screens/invoices_list_screen.dart';
import '../features/fees/presentation/screens/invoice_detail_screen.dart';
import '../features/fees/presentation/screens/parent_fee_screen.dart';
// Imports:
import '../features/announcements/presentation/screens/announcements_list_screen.dart';
import '../features/announcements/presentation/screens/create_announcement_screen.dart';
import '../features/announcements/presentation/screens/announcement_detail_screen.dart';
import '../features/announcements/domain/entities/announcement_entity.dart';
import '../features/complaints/presentation/screens/complaints_list_screen.dart';
import '../features/complaints/presentation/screens/create_complaint_screen.dart';
import '../features/complaints/presentation/screens/complaint_detail_screen.dart';
import '../features/notifications/presentation/screens/notification_preferences_screen.dart';

// Routes:
GoRoute(path: '/announcements', builder: (context, state) => const AnnouncementsListScreen()),
GoRoute(path: '/announcements/create', builder: (context, state) => const CreateAnnouncementScreen()),
GoRoute(
path: '/announcements/:id',
builder: (context, state) => AnnouncementDetailScreen(announcement: state.extra as AnnouncementEntity),
),
GoRoute(path: '/complaints', builder: (context, state) => const ComplaintsListScreen()),
GoRoute(path: '/complaints/create', builder: (context, state) => const CreateComplaintScreen()),
GoRoute(
path: '/complaints/:complaintId',
builder: (context, state) => ComplaintDetailScreen(complaintId: state.pathParameters['complaintId']!),
),
GoRoute(path: '/notifications/preferences', builder: (context, state) => const NotificationPreferencesScreen()),
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoading = authState.status == AuthStatus.loading || authState.status == AuthStatus.initial;
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isAuthRoute = ['/login', '/register', '/otp-login', '/forgot-password'].contains(state.matchedLocation);
      final isSplash = state.matchedLocation == '/splash';

      if (isLoading) return isSplash ? null : '/splash';
      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && (isAuthRoute || isSplash)) {
        return _dashboardPathForRole(authState.user!.role);
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/otp-login', builder: (context, state) => const OtpScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/reset-password', builder: (context, state) => const ResetPasswordScreen()),

      GoRoute(path: '/dashboard/admin', builder: (context, state) => const _PlaceholderDashboard('Admin')),
      GoRoute(path: '/dashboard/teacher', builder: (context, state) => const _PlaceholderDashboard('Teacher')),
      GoRoute(path: '/dashboard/parent', builder: (context, state) => const _PlaceholderDashboard('Parent')),
      GoRoute(path: '/dashboard/student', builder: (context, state) => const _PlaceholderDashboard('Student')),
      GoRoute(path: '/dashboard/super-admin', builder: (context, state) => const _PlaceholderDashboard('Super Admin')),
      GoRoute(path: '/dashboard/accountant', builder: (context, state) => const _PlaceholderDashboard('Accountant')),
      GoRoute(path: '/dashboard/transport', builder: (context, state) => const _PlaceholderDashboard('Transport')),

      GoRoute(path: '/admin/school-setup', builder: (context, state) => const SchoolSetupWizardScreen()),
      GoRoute(path: '/admin/school-profile', builder: (context, state) => const SchoolProfileScreen()),
      GoRoute(path: '/admin/classes', builder: (context, state) => const ClassesScreen()),
      GoRoute(
        path: '/admin/classes/:classId/detail',
        builder: (context, state) => ClassDetailScreen(
          classId: state.pathParameters['classId']!,
          className: state.extra as String? ?? '',
        ),
      ),
      GoRoute(path: '/admin/students', builder: (context, state) => const StudentsListScreen()),
      GoRoute(path: '/admin/students/add', builder: (context, state) => const AddStudentScreen()),
      GoRoute(
        path: '/admin/students/:studentId',
        builder: (context, state) => StudentDetailScreen(studentId: state.pathParameters['studentId']!),
      ),
      GoRoute(path: '/admin/teachers', builder: (context, state) => const TeachersListScreen()),
      GoRoute(path: '/admin/teachers/add', builder: (context, state) => const AddTeacherScreen()),
      GoRoute(
        path: '/admin/teachers/:teacherId',
        builder: (context, state) => TeacherDetailScreen(teacherId: state.pathParameters['teacherId']!),
      ),

      GoRoute(path: '/teacher/attendance', builder: (context, state) => const AttendanceScreen()),
      GoRoute(
        path: '/teacher/attendance/mark',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return MarkAttendanceScreen(classId: extra['classId'] as String, className: extra['className'] as String);
        },
      ),
      GoRoute(
        path: '/attendance/history/:studentId',
        builder: (context, state) => AttendanceHistoryScreen(
          studentId: state.pathParameters['studentId']!,
          studentName: state.extra as String? ?? 'Student',
        ),
      ),
      GoRoute(path: '/admin/attendance/reports', builder: (context, state) => const AttendanceReportScreen()),

      GoRoute(path: '/teacher/homework', builder: (context, state) => const HomeworkListScreen()),
      GoRoute(path: '/teacher/homework/create', builder: (context, state) => const CreateHomeworkScreen()),
      GoRoute(
        path: '/teacher/homework/:homeworkId',
        builder: (context, state) => HomeworkDetailTeacherScreen(homeworkId: state.pathParameters['homeworkId']!),
      ),
      GoRoute(path: '/student/homework', builder: (context, state) => const StudentHomeworkListScreen()),
      GoRoute(
        path: '/student/homework/:homeworkId',
        builder: (context, state) => SubmitHomeworkScreen(homeworkId: state.pathParameters['homeworkId']!),
      ),
      GoRoute(
        path: '/parent/homework/:studentId',
        builder: (context, state) => ParentHomeworkScreen(
          studentId: state.pathParameters['studentId']!,
          studentName: state.extra as String? ?? 'Child',
        ),
      ),

      GoRoute(path: '/admin/exams', builder: (context, state) => const ExamsListScreen()),
      GoRoute(path: '/admin/exams/create', builder: (context, state) => const CreateExamScreen()),
      GoRoute(
        path: '/admin/exams/:examId',
        builder: (context, state) => ExamDetailScreen(examId: state.pathParameters['examId']!),
      ),
      GoRoute(
        path: '/admin/exams/:examId/marks-entry',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return MarksEntryScreen(
            examId: state.pathParameters['examId']!,
            examSubjectId: extra['examSubjectId'] as String,
            subjectName: extra['subjectName'] as String,
            classId: extra['classId'] as String,
            totalMarks: extra['totalMarks'] as double,
          );
        },
      ),
      GoRoute(
        path: '/admin/exams/:examId/results',
        builder: (context, state) => ClassResultsScreen(examId: state.pathParameters['examId']!),
      ),
      GoRoute(
        path: '/results/:studentId',
        builder: (context, state) => StudentResultsScreen(
          studentId: state.pathParameters['studentId']!,
          studentName: state.extra as String? ?? 'Student',
        ),
      ),
      GoRoute(
        path: '/results/report-card/:examId',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ReportCardScreen(
            examId: state.pathParameters['examId']!,
            studentId: extra['studentId'] as String,
            studentName: extra['studentName'] as String,
          );
        },
      ),

      GoRoute(path: '/fees/dashboard', builder: (context, state) => const FeeDashboardScreen()),
      GoRoute(path: '/fees/structures', builder: (context, state) => const FeeStructuresScreen()),
      GoRoute(path: '/fees/generate-invoices', builder: (context, state) => const GenerateInvoicesScreen()),
      GoRoute(path: '/fees/invoices', builder: (context, state) => const InvoicesListScreen()),
      GoRoute(
        path: '/fees/invoice/:invoiceId',
        builder: (context, state) => InvoiceDetailScreen(invoiceId: state.pathParameters['invoiceId']!),
      ),
      GoRoute(
        path: '/parent/fees/:studentId',
        builder: (context, state) => ParentFeeScreen(
          studentId: state.pathParameters['studentId']!,
          studentName: state.extra as String? ?? 'Child',
        ),
      ),
    ],
  );
});

String _dashboardPathForRole(UserRole role) {
  switch (role) {
    case UserRole.superAdmin:
      return '/dashboard/super-admin';
    case UserRole.admin:
      return '/dashboard/admin';
    case UserRole.teacher:
      return '/dashboard/teacher';
    case UserRole.parent:
      return '/dashboard/parent';
    case UserRole.student:
      return '/dashboard/student';
    case UserRole.accountant:
      return '/dashboard/accountant';
    case UserRole.transportManager:
      return '/dashboard/transport';
  }
}

class _PlaceholderDashboard extends StatelessWidget {
  final String role;
  const _PlaceholderDashboard(this.role);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$role Dashboard')),
      body: Center(child: Text('$role Dashboard')),
    );
  }
}