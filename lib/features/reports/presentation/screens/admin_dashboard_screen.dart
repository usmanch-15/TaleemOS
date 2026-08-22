import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/report_provider.dart';
import '../widgets/admin_nav.dart';
import '../widgets/admin_topbar.dart';
import '../widgets/stat_card.dart';

/// Wide-screen breakpoint — isse zyada width par permanent sidebar dikhega,
/// isse kam par Drawer (hamburger menu) use hoga.
const double _wideBreakpoint = 900;

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width >= _wideBreakpoint;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            const AdminSidebar(currentRoute: '/dashboard/admin'),
            const VerticalDivider(width: 1),
            Expanded(
              child: Scaffold(
                appBar: const AdminTopBar(title: 'Dashboard'),
                body: const _DashboardBody(),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AdminTopBar(title: 'Dashboard', onMenuTap: () => Scaffold.of(context).openDrawer()),
      drawer: const AdminDrawer(currentRoute: '/dashboard/admin'),
      body: const _DashboardBody(),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(schoolDashboardStatsProvider);
    final user = ref.watch(authControllerProvider).user;

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(schoolDashboardStatsProvider),
      child: statsAsync.when(
        data: (stats) {
          if (stats == null) return const Center(child: Text('Data load nahi ho saka'));
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Assalam-o-Alaikum, ${user?.name ?? ''} 👋',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Aaj ka overview',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),

              // ---- Stat cards ----
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth >= 900 ? 4 : (constraints.maxWidth >= 600 ? 3 : 2);
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      StatCard(label: 'Total Students', value: '${stats.totalStudents}', icon: Icons.groups_outlined, color: Colors.indigo),
                      StatCard(label: 'Total Teachers', value: '${stats.totalTeachers}', icon: Icons.person_outline, color: Colors.teal),
                      StatCard(
                        label: "Today's Attendance",
                        value: '${stats.todayAttendancePercentage.toStringAsFixed(1)}%',
                        icon: Icons.calendar_today_outlined,
                        color: Colors.green,
                      ),
                      StatCard(
                        label: 'Pending Fees',
                        value: 'Rs. ${stats.pendingFeeAmount.toStringAsFixed(0)}',
                        icon: Icons.receipt_long_outlined,
                        color: Colors.orange,
                      ),
                      StatCard(label: 'Total Classes', value: '${stats.totalClasses}', icon: Icons.class_outlined, color: Colors.purple),
                      StatCard(label: 'Open Complaints', value: '${stats.openComplaints}', icon: Icons.report_problem_outlined, color: Colors.red),
                    ],
                  );
                },
              ),

              const SizedBox(height: 28),

              // ---- Quick actions ----
              const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth >= 900 ? 6 : (constraints.maxWidth >= 600 ? 4 : 3);
                  final actions = [
                    _QuickAction(icon: Icons.person_add_alt_outlined, label: 'Add Student', color: Colors.indigo, route: '/admin/students/add'),
                    _QuickAction(icon: Icons.badge_outlined, label: 'Add Teacher', color: Colors.teal, route: '/admin/teachers/add'),
                    _QuickAction(icon: Icons.post_add_outlined, label: 'Create Exam', color: Colors.purple, route: '/admin/exams/create'),
                    _QuickAction(icon: Icons.campaign_outlined, label: 'Announcement', color: Colors.blue, route: '/announcements/create'),
                    _QuickAction(icon: Icons.request_quote_outlined, label: 'Generate Invoices', color: Colors.orange, route: '/fees/generate-invoices'),
                    _QuickAction(icon: Icons.bar_chart_outlined, label: 'Class Report', color: Colors.green, route: '/reports/class-distribution'),
                  ];
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                    children: actions,
                  );
                },
              ),

              const SizedBox(height: 28),

              // ---- Reports ----
              const Text('Reports', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _ReportTile(
                icon: Icons.bar_chart,
                title: 'Class-wise Student Distribution',
                onTap: () => context.push('/reports/class-distribution'),
              ),
              _ReportTile(
                icon: Icons.trending_up,
                title: 'Admissions Trend',
                onTap: () => context.push('/reports/admissions'),
              ),
              _ReportTile(
                icon: Icons.fact_check_outlined,
                title: 'Teacher Attendance Compliance',
                onTap: () => context.push('/reports/teacher-compliance'),
              ),
              _ReportTile(
                icon: Icons.download_outlined,
                title: 'Export Data (CSV)',
                onTap: () => context.push('/reports/exports'),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  const _QuickAction({required this.icon, required this.label, required this.color, required this.route});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push(route),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _ReportTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.indigo.shade50, child: Icon(icon, color: Colors.indigo, size: 20)),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}