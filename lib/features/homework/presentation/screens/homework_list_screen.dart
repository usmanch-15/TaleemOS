import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../teachers/presentation/providers/teacher_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/homework_provider.dart';
import '../widgets/homework_card.dart';

class HomeworkListScreen extends ConsumerWidget {
  const HomeworkListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final schoolId = authState.user?.schoolId;
    final userId = authState.user?.id;

    if (schoolId == null || userId == null) {
      return const Scaffold(body: Center(child: Text('Login required')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Homework')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/teacher/homework/create'),
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
      body: FutureBuilder(
        future: ref.watch(teacherRepositoryProvider).getTeachers(schoolId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final teacher = snapshot.data!.firstWhere((t) => t.userId == userId, orElse: () => snapshot.data!.first);

          return Consumer(
            builder: (context, ref, _) {
              final homeworkAsync = ref.watch(teacherHomeworkListProvider(teacher.id));
              return homeworkAsync.when(
                data: (homeworkList) {
                  if (homeworkList.isEmpty) {
                    return const Center(child: Text('Abhi tak koi homework nahi banaya, + button se banayein'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: homeworkList.length,
                    itemBuilder: (context, index) {
                      final hw = homeworkList[index];
                      return HomeworkCard(
                        homework: hw,
                        onTap: () => context.push('/teacher/homework/${hw.id}'),
                        trailing: hw.status.name == 'draft'
                            ? TextButton(
                          onPressed: () =>
                              ref.read(homeworkFormControllerProvider.notifier).publish(hw.id, teacher.id),
                          child: const Text('Publish', style: TextStyle(fontSize: 12)),
                        )
                            : null,
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