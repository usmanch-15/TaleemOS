import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../teachers/presentation/providers/teacher_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authControllerProvider).user?.id;
    final schoolId = ref.watch(authControllerProvider).user?.schoolId;

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: (userId == null || schoolId == null)
          ? const Center(child: Text('Login required'))
          : FutureBuilder(
        future: ref.watch(teacherRepositoryProvider).getTeachers(schoolId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final teachers = snapshot.data!;
          if (teachers.isEmpty) return const Center(child: Text('Koi teacher record nahi mila'));
          final teacher = teachers.firstWhere((t) => t.userId == userId, orElse: () => teachers.first);

          return Consumer(
            builder: (context, ref, _) {
              final assignmentsAsync = ref.watch(teacherAssignmentsProvider(teacher.id));
              return assignmentsAsync.when(
                data: (assignments) {
                  final seen = <String>{};
                  final uniqueClasses = assignments.where((a) => seen.add(a['class_id'] as String)).toList();

                  if (uniqueClasses.isEmpty) {
                    return const Center(child: Text('Aapko abhi koi class assign nahi hui'));
                  }

                  return ListView.builder(
                    itemCount: uniqueClasses.length,
                    itemBuilder: (context, index) {
                      final a = uniqueClasses[index];
                      final className = (a['classes'] as Map?)?['name'] ?? '';
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.class_outlined),
                          title: Text(className),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(
                            '/teacher/attendance/mark',
                            extra: {'classId': a['class_id'], 'className': className},
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              );
            },
          );
        },
      ),
    );
  }
}