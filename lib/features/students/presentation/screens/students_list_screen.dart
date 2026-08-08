import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../classes/presentation/providers/class_provider.dart';
import '../providers/student_provider.dart';
import '../widgets/student_list_tile.dart';

class StudentsListScreen extends ConsumerStatefulWidget {
  const StudentsListScreen({super.key});

  @override
  ConsumerState<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends ConsumerState<StudentsListScreen> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsListProvider);
    final classesAsync = ref.watch(classesListProvider);
    final filter = ref.watch(studentFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/students/add'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Naam ya student code se search karein',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (value) {
                ref.read(studentFilterProvider.notifier).state = filter.copyWith(searchQuery: value);
              },
            ),
          ),
          classesAsync.when(
            data: (classes) => SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('All'),
                      selected: filter.classId == null,
                      onSelected: (_) => ref.read(studentFilterProvider.notifier).state =
                          filter.copyWith(classId: null),
                    ),
                  ),
                  ...classes.map((c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c.name),
                      selected: filter.classId == c.id,
                      onSelected: (_) => ref.read(studentFilterProvider.notifier).state =
                          filter.copyWith(classId: c.id),
                    ),
                  )),
                ],
              ),
            ),
            loading: () => const SizedBox(height: 44),
            error: (_, __) => const SizedBox(height: 44),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: studentsAsync.when(
              data: (result) {
                if (result.items.isEmpty) {
                  return const Center(child: Text('Koi student nahi mila'));
                }
                return ListView.builder(
                  itemCount: result.items.length,
                  itemBuilder: (context, index) {
                    final student = result.items[index];
                    return StudentListTile(
                      student: student,
                      onTap: () => context.push('/admin/students/${student.id}'),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}