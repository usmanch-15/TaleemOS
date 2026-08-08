// Existing imports ke sath ye add karein:
import '../features/school/presentation/screens/school_setup_wizard_screen.dart';
import '../features/school/presentation/screens/school_profile_screen.dart';
import '../features/classes/presentation/screens/classes_screen.dart';
import '../features/classes/presentation/screens/class_detail_screen.dart';
import '../features/students/presentation/screens/students_list_screen.dart';
import '../features/students/presentation/screens/add_student_screen.dart';
import '../features/students/presentation/screens/student_detail_screen.dart';
import '../features/teachers/presentation/screens/teachers_list_screen.dart';
import '../features/teachers/presentation/screens/add_teacher_screen.dart';
import '../features/teachers/presentation/screens/teacher_detail_screen.dart';
// Imports:
// Imports:
import '../features/attendance/presentation/screens/attendance_screen.dart';
import '../features/attendance/presentation/screens/mark_attendance_screen.dart';
import '../features/attendance/presentation/screens/attendance_history_screen.dart';
import '../features/attendance/presentation/screens/attendance_report_screen.dart';

// Routes:
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

// GoRoute list mein add karein:
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