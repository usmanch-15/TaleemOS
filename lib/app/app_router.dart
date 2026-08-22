import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Auth
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/providers/auth_state.dart';
import '../features/auth/domain/entities/user_entity.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/otp_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';

// School
import '../features/school/presentation/screens/school_setup_wizard_screen.dart';
import '../features/school/presentation/screens/school_profile_screen.dart';

// Classes
import '../features/classes/presentation/screens/classes_screen.dart';
import '../features/classes/presentation/screens/class_detail_screen.dart';

// Students
import '../features/students/presentation/screens/students_list_screen.dart';
import '../features/students/presentation/screens/add_student_screen.dart';
import '../features/students/presentation/screens/student_detail_screen.dart';

// Teachers
import '../features/teachers/presentation/screens/teachers_list_screen.dart';
import '../features/teachers/presentation/screens/add_teacher_screen.dart';
import '../features/teachers/presentation/screens/teacher_detail_screen.dart';

// Attendance
import '../features/attendance/presentation/screens/attendance_screen.dart';
import '../features/attendance/presentation/screens/mark_attendance_screen.dart';
import '../features/attendance/presentation/screens/attendance_history_screen.dart';
import '../features/attendance/presentation/screens/attendance_report_screen.dart';

// Homework
import '../features/homework/presentation/screens/homework_list_screen.dart';
import '../features/homework/presentation/screens/create_homework_screen.dart';
import '../features/homework/presentation/screens/homework_detail_teacher_screen.dart';
import '../features/homework/presentation/screens/student_homework_list_screen.dart';
import '../features/homework/presentation/screens/submit_homework_screen.dart';
import '../features/homework/presentation/screens/parent_homework_screen.dart';

// Exams
import '../features/exams/presentation/screens/exams_list_screen.dart';
import '../features/exams/presentation/screens/create_exam_screen.dart';
import '../features/exams/presentation/screens/exam_detail_screen.dart';
import '../features/exams/presentation/screens/marks_entry_screen.dart';
import '../features/exams/presentation/screens/class_results_screen.dart';
import '../features/exams/presentation/screens/student_results_screen.dart';
import '../features/exams/presentation/screens/report_card_screen.dart';

// Fees
import '../features/fees/presentation/screens/fee_dashboard_screen.dart';
import '../features/fees/presentation/screens/fee_structures_screen.dart';
import '../features/fees/presentation/screens/generate_invoices_screen.dart';
import '../features/fees/presentation/screens/invoices_list_screen.dart';
import '../features/fees/presentation/screens/invoice_detail_screen.dart';
import '../features/fees/presentation/screens/parent_fee_screen.dart';

// Announcements
import '../features/announcements/presentation/screens/announcements_list_screen.dart';
import '../features/announcements/presentation/screens/create_announcement_screen.dart';
import '../features/announcements/presentation/screens/announcement_detail_screen.dart';
import '../features/announcements/domain/entities/announcement_entity.dart';

// Complaints
import '../features/complaints/presentation/screens/complaints_list_screen.dart';
import '../features/complaints/presentation/screens/create_complaint_screen.dart';
import '../features/complaints/presentation/screens/complaint_detail_screen.dart';

// Notifications
import '../features/notifications/presentation/screens/notification_preferences_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';

// Transport
import '../features/transport/presentation/screens/vehicles_screen.dart';
import '../features/transport/presentation/screens/drivers_screen.dart';
import '../features/transport/presentation/screens/routes_screen.dart';
import '../features/transport/presentation/screens/create_route_screen.dart';
import '../features/transport/presentation/screens/route_detail_screen.dart';
import '../features/transport/presentation/screens/daily_transport_screen.dart';
import '../features/transport/presentation/screens/parent_transport_screen.dart';

// Reports
import '../features/reports/presentation/screens/admin_dashboard_screen.dart';
import '../features/reports/presentation/screens/class_distribution_screen.dart';
import '../features/reports/presentation/screens/admissions_report_screen.dart';
import '../features/reports/presentation/screens/teacher_compliance_screen.dart';
import '../features/reports/presentation/screens/exports_screen.dart';
import '../features/reports/presentation/screens/super_admin_dashboard_screen.dart';

// Subscription
import '../features/subscription/presentation/screens/plans_management_screen.dart';
import '../features/subscription/presentation/screens/schools_subscription_screen.dart';
import '../features/subscription/presentation/screens/school_subscription_detail_screen.dart';
import '../features/subscription/presentation/screens/my_subscription_screen.dart';
import '../features/subscription/presentation/screens/support_tickets_list_screen.dart';
import '../features/subscription/presentation/screens/create_support_ticket_screen.dart';
import '../features/subscription/presentation/screens/support_ticket_detail_screen.dart';
import '../features/subscription/domain/entities/subscription_entity.dart';

// Timetable & Common
import '../features/timetable/presentation/screens/timetable_screen.dart';
import '../features/timetable/presentation/screens/manage_timetable_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/change_password_screen.dart';
import '../features/common/presentation/screens/help_support_screen.dart';
import '../features/common/presentation/screens/privacy_policy_screen.dart';
import '../features/common/presentation/screens/terms_conditions_screen.dart';
import '../features/common/presentation/screens/onboarding_screen.dart';

/// GoRouter ka redirect() sirf dobara CHECK hone ke liye is Listenable ko use karta hai.
/// Auth state change hone par yahan sirf notifyListeners() hota hai — poora naya
/// GoRouter instance nahi banta, isliye navigation stack reset nahi hota
/// aur login ke baad screen theek se dashboard par navigate karti hai.
class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshNotifier(ref),
    redirect: (context, state) {
      // ref.read() use kiya hai (watch nahi) — taake redirect callback
      // hamesha latest auth state dekhe, aur Provider dobara build na ho.
      final authState = ref.read(authControllerProvider);
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
      // ---- Auth ----
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/otp-login', builder: (context, state) => const OtpScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/reset-password', builder: (context, state) => const ResetPasswordScreen()),

      // ---- Dashboards ----
      GoRoute(path: '/dashboard/admin', builder: (context, state) => const AdminDashboardScreen()),
      GoRoute(path: '/dashboard/teacher', builder: (context, state) => const _PlaceholderDashboard('Teacher')),
      GoRoute(path: '/dashboard/parent', builder: (context, state) => const _PlaceholderDashboard('Parent')),
      GoRoute(path: '/dashboard/student', builder: (context, state) => const _PlaceholderDashboard('Student')),
      GoRoute(path: '/dashboard/super-admin', builder: (context, state) => const SuperAdminDashboardScreen()),
      GoRoute(path: '/dashboard/accountant', builder: (context, state) => const _PlaceholderDashboard('Accountant')),
      GoRoute(path: '/dashboard/transport', builder: (context, state) => const _PlaceholderDashboard('Transport')),

      // ---- School ----
      GoRoute(path: '/admin/school-setup', builder: (context, state) => const SchoolSetupWizardScreen()),
      GoRoute(path: '/admin/school-profile', builder: (context, state) => const SchoolProfileScreen()),

      // ---- Classes ----
      GoRoute(path: '/admin/classes', builder: (context, state) => const ClassesScreen()),
      GoRoute(
        path: '/admin/classes/:classId/detail',
        builder: (context, state) => ClassDetailScreen(
          classId: state.pathParameters['classId']!,
          className: state.extra as String? ?? '',
        ),
      ),

      // ---- Students ----
      GoRoute(path: '/admin/students', builder: (context, state) => const StudentsListScreen()),
      GoRoute(path: '/admin/students/add', builder: (context, state) => const AddStudentScreen()),
      GoRoute(
        path: '/admin/students/:studentId',
        builder: (context, state) => StudentDetailScreen(studentId: state.pathParameters['studentId']!),
      ),

      // ---- Teachers ----
      GoRoute(path: '/admin/teachers', builder: (context, state) => const TeachersListScreen()),
      GoRoute(path: '/admin/teachers/add', builder: (context, state) => const AddTeacherScreen()),
      GoRoute(
        path: '/admin/teachers/:teacherId',
        builder: (context, state) => TeacherDetailScreen(teacherId: state.pathParameters['teacherId']!),
      ),

      // ---- Attendance ----
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

      // ---- Homework ----
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

      // ---- Exams ----
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

      // ---- Fees ----
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

      // ---- Announcements ----
      GoRoute(path: '/announcements', builder: (context, state) => const AnnouncementsListScreen()),
      GoRoute(path: '/announcements/create', builder: (context, state) => const CreateAnnouncementScreen()),
      GoRoute(
        path: '/announcements/:id',
        builder: (context, state) => AnnouncementDetailScreen(announcement: state.extra as AnnouncementEntity),
      ),

      // ---- Complaints ----
      GoRoute(path: '/complaints', builder: (context, state) => const ComplaintsListScreen()),
      GoRoute(path: '/complaints/create', builder: (context, state) => const CreateComplaintScreen()),
      GoRoute(
        path: '/complaints/:complaintId',
        builder: (context, state) => ComplaintDetailScreen(complaintId: state.pathParameters['complaintId']!),
      ),

      // ---- Notifications ----
      GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
      GoRoute(path: '/notifications/preferences', builder: (context, state) => const NotificationPreferencesScreen()),

      // ---- Transport ----
      GoRoute(path: '/transport/vehicles', builder: (context, state) => const VehiclesScreen()),
      GoRoute(path: '/transport/drivers', builder: (context, state) => const DriversScreen()),
      GoRoute(path: '/transport/routes', builder: (context, state) => const RoutesScreen()),
      GoRoute(path: '/transport/routes/create', builder: (context, state) => const CreateRouteScreen()),
      GoRoute(
        path: '/transport/routes/:routeId',
        builder: (context, state) => RouteDetailScreen(routeId: state.pathParameters['routeId']!),
      ),
      GoRoute(
        path: '/transport/routes/:routeId/daily',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return DailyTransportScreen(routeId: state.pathParameters['routeId']!, routeName: extra['routeName'] as String);
        },
      ),
      GoRoute(
        path: '/parent/transport/:studentId',
        builder: (context, state) => ParentTransportScreen(
          studentId: state.pathParameters['studentId']!,
          studentName: state.extra as String? ?? 'Child',
        ),
      ),

      // ---- Reports ----
      GoRoute(path: '/reports/class-distribution', builder: (context, state) => const ClassDistributionScreen()),
      GoRoute(path: '/reports/admissions', builder: (context, state) => const AdmissionsReportScreen()),
      GoRoute(path: '/reports/teacher-compliance', builder: (context, state) => const TeacherComplianceScreen()),
      GoRoute(path: '/reports/exports', builder: (context, state) => const ExportsScreen()),

      // ---- Subscription ----
      GoRoute(path: '/subscription/plans', builder: (context, state) => const PlansManagementScreen()),
      GoRoute(path: '/subscription/schools', builder: (context, state) => const SchoolsSubscriptionScreen()),
      GoRoute(
        path: '/subscription/schools/:schoolId',
        builder: (context, state) =>
            SchoolSubscriptionDetailScreen(subscription: state.extra as SchoolSubscriptionEntity),
      ),
      GoRoute(path: '/subscription/my', builder: (context, state) => const MySubscriptionScreen()),
      GoRoute(path: '/support', builder: (context, state) => const SupportTicketsListScreen()),
      GoRoute(path: '/support/create', builder: (context, state) => const CreateSupportTicketScreen()),
      GoRoute(
        path: '/support/:ticketId',
        builder: (context, state) => SupportTicketDetailScreen(ticketId: state.pathParameters['ticketId']!),
      ),

      // ---- Timetable ----
      GoRoute(
        path: '/timetable',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return TimetableScreen(
            classId: extra?['classId'] as String?,
            sectionId: extra?['sectionId'] as String?,
            teacherId: extra?['teacherId'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/admin/timetable/:classId',
        builder: (context, state) => ManageTimetableScreen(
          classId: state.pathParameters['classId']!,
          className: state.extra as String? ?? '',
        ),
      ),

      // ---- Profile ----
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/profile/edit', builder: (context, state) => const EditProfileScreen()),
      GoRoute(path: '/profile/change-password', builder: (context, state) => const ChangePasswordScreen()),

      // ---- Common ----
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/help', builder: (context, state) => const HelpSupportScreen()),
      GoRoute(path: '/privacy-policy', builder: (context, state) => const PrivacyPolicyScreen()),
      GoRoute(path: '/terms', builder: (context, state) => const TermsConditionsScreen()),
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