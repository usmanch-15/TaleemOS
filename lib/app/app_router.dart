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
import '../features/homework/presentation/screens/homework_list_screen.dart';
import '../features/homework/presentation/screens/create_homework_screen.dart';
import '../features/homework/presentation/screens/homework_detail_teacher_screen.dart';
import '../features/homework/presentation/screens/student_homework_list_screen.dart';
import '../features/homework/presentation/screens/submit_homework_screen.dart';
import '../features/homework/presentation/screens/parent_homework_screen.dart';
// Imports:
import '../features/exams/presentation/screens/exams_list_screen.dart';
import '../features/exams/presentation/screens/create_exam_screen.dart';
import '../features/exams/presentation/screens/exam_detail_screen.dart';
import '../features/exams/presentation/screens/marks_entry_screen.dart';
import '../features/exams/presentation/screens/class_results_screen.dart';
import '../features/exams/presentation/screens/student_results_screen.dart';
import '../features/exams/presentation/screens/report_card_screen.dart';
// Imports:
import '../features/fees/presentation/screens/fee_dashboard_screen.dart';
import '../features/fees/presentation/screens/fee_structures_screen.dart';
import '../features/fees/presentation/screens/generate_invoices_screen.dart';
import '../features/fees/presentation/screens/invoices_list_screen.dart';
import '../features/fees/presentation/screens/invoice_detail_screen.dart';
import '../features/fees/presentation/screens/parent_fee_screen.dart';

// Routes:
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
// Routes:
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
// Imports:


// Routes:
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
// Imports:

// Routes:
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