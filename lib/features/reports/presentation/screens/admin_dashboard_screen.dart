import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/report_provider.dart';
import '../widgets/stat_card.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(schoolDashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(schoolDashboardStatsProvider),
        child: statsAsync.when(
          data: (stats) {
            if (stats == null) return const Center(child: Text('Data load nahi ho saka'));
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    StatCard(label: 'Total Students', value: '${stats.totalStudents}', icon: Icons.groups_outlined, color: Colors.indigo),
                    StatCard(label: 'Total Teachers', value: '${stats.totalTeachers}', icon: Icons.person_outline, color: Colors.teal),
                    StatCard(
                      label: 'Today\'s Attendance',
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
                ),
                const SizedBox(height: 24),
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
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.indigo.shade50, child: Icon(icon, color: Colors.indigo, size: 20)),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}