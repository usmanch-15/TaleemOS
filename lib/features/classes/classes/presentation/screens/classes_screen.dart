import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/class_provider.dart';

class ClassesScreen extends ConsumerWidget {
  const ClassesScreen({super.key});

  void _showAddClassDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Class'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'e.g. Class 7')),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              final classesCount = ref.read(classesListProvider).value?.length ?? 0;
              await ref.read(classManagementControllerProvider.notifier).addClass(controller.text.trim(), classesCount);
              if (context.mounted) context.pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(classesListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Classes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddClassDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: classesAsync.when(
        data: (classes) {
          if (classes.isEmpty) {
            return const Center(child: Text('Abhi tak koi class nahi bani, + button se add karein'));
          }
          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final cls = classes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  title: Text(cls.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => ref.read(classManagementControllerProvider.notifier).deleteClass(cls.id),
                  ),
                  onTap: () => context.push('/admin/classes/${cls.id}/detail', extra: cls.name),
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