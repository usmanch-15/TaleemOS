import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/report_provider.dart';
import '../widgets/stat_card.dart';

class SuperAdminDashboardScreen extends ConsumerWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(globalPlatformStatsProvider);
    final schoolsAsync = ref.watch(schoolsSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Platform Overview')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(globalPlatformStatsProvider);
          ref.invalidate(schoolsSummaryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            statsAsync.when(
              data: (stats) => GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  StatCard(label: 'Total Schools', value: '${stats.totalSchools}', icon: Icons.apartment_outlined, color: Colors.indigo),
                  StatCard(label: 'Active Schools', value: '${stats.activeSchools}', icon: Icons.check_circle_outline, color: Colors.green),
                  StatCard(label: 'Total Students', value: '${stats.totalStudents}', icon: Icons.groups_outlined, color: Colors.teal),
                  StatCard(label: 'Total Teachers', value: '${stats.totalTeachers}', icon: Icons.person_outline, color: Colors.purple),
                  StatCard(
                    label: 'Monthly Revenue',
                    value: 'Rs. ${stats.totalRevenue.toStringAsFixed(0)}',
                    icon: Icons.attach_money,
                    color: Colors.orange,
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 24),
            const Text('Schools', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            schoolsAsync.when(
              data: (schools) {
                if (schools.isEmpty) return const Text('Koi school nahi hai');
                return Column(
                  children: schools.map((s) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(s.schoolName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('${s.studentCount} students • ${s.teacherCount} teachers'),
                        trailing: Chip(
                          label: Text(s.status, style: const TextStyle(fontSize: 11)),
                          backgroundColor: s.status == 'active' ? Colors.green.shade50 : Colors.orange.shade50,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}