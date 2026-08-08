import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/teacher_provider.dart';

class TeachersListScreen extends ConsumerWidget {
  const TeachersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teachersAsync = ref.watch(teachersListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Teachers')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/teachers/add'),
        child: const Icon(Icons.add),
      ),
      body: teachersAsync.when(
        data: (teachers) {
          if (teachers.isEmpty) return const Center(child: Text('Abhi koi teacher add nahi hua'));
          return ListView.builder(
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final t = teachers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: t.photoUrl != null ? NetworkImage(t.photoUrl!) : null,
                    child: t.photoUrl == null ? Text(t.name.isNotEmpty ? t.name[0] : '?') : null,
                  ),
                  title: Text(t.name),
                  subtitle: Text(t.email),
                  trailing: Switch(
                    value: t.status == 'active',
                    onChanged: (value) =>
                        ref.read(teacherManagementControllerProvider.notifier).toggleStatus(t.id, value),
                  ),
                  onTap: () => context.push('/admin/teachers/${t.id}'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}