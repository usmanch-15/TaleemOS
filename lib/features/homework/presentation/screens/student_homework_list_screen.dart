
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/homework_provider.dart';
import '../widgets/homework_card.dart';

class StudentHomeworkListScreen extends ConsumerWidget {
  const StudentHomeworkListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeworkAsync = ref.watch(studentHomeworkListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Homework')),
      body: homeworkAsync.when(
        data: (list) {
          if (list.isEmpty) return const Center(child: Text('Koi homework abhi tak assign nahi hua'));
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final hw = list[index];
              return HomeworkCard(homework: hw, onTap: () => context.push('/student/homework/${hw.id}'));
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}