import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../classes/presentation/providers/class_provider.dart';
import '../providers/teacher_provider.dart';

class TeacherDetailScreen extends ConsumerStatefulWidget {
  final String teacherId;
  const TeacherDetailScreen({super.key, required this.teacherId});

  @override
  ConsumerState<TeacherDetailScreen> createState() => _TeacherDetailScreenState();
}

class _TeacherDetailScreenState extends ConsumerState<TeacherDetailScreen> {
  String? _selectedClassId;
  String? _selectedSectionId;
  String? _selectedSubjectId;

  void _showAssignDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final classesAsync = ref.watch(classesListProvider);
          return AlertDialog(
            title: const Text('Assign Class'),
            content: SizedBox(
              width: 300,
              child: classesAsync.when(
                data: (classes) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Class'),
                      items: classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                      onChanged: (value) => setDialogState(() {
                        _selectedClassId = value;
                        _selectedSectionId = null;
                        _selectedSubjectId = null;
                      }),
                    ),
                    if (_selectedClassId != null)
                      Consumer(
                        builder: (context, ref, _) {
                          final subjectsAsync = ref.watch(subjectsForClassProvider(_selectedClassId!));
                          return subjectsAsync.when(
                            data: (subjects) => DropdownButtonFormField<String>(
                              decoration: const InputDecoration(labelText: 'Subject'),
                              items: subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                              onChanged: (value) => setDialogState(() => _selectedSubjectId = value),
                            ),
                            loading: () => const LinearProgressIndicator(),
                            error: (_, __) => const Text('Error'),
                          );
                        },
                      ),
                  ],
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error loading classes'),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () async {
                  if (_selectedClassId == null || _selectedSubjectId == null) return;
                  await ref.read(teacherManagementControllerProvider.notifier).assignClass(
                    teacherId: widget.teacherId,
                    classId: _selectedClassId!,
                    sectionId: _selectedSectionId,
                    subjectId: _selectedSubjectId!,
                  );
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Assign'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teacherAsync = ref.watch(teacherDetailProvider(widget.teacherId));
    final assignmentsAsync = ref.watch(teacherAssignmentsProvider(widget.teacherId));

    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Detail')),
      floatingActionButton: FloatingActionButton(onPressed: _showAssignDialog, child: const Icon(Icons.add)),
      body: teacherAsync.when(
        data: (teacher) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: CircleAvatar(
                radius: 45,
                backgroundImage: teacher.photoUrl != null ? NetworkImage(teacher.photoUrl!) : null,
                child: teacher.photoUrl == null ? Text(teacher.name[0], style: const TextStyle(fontSize: 30)) : null,
              ),
            ),
            const SizedBox(height: 12),
            Center(child: Text(teacher.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
            Center(child: Text(teacher.email, style: const TextStyle(color: Colors.grey))),
            const Divider(height: 32),
            const Text('Assigned Classes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            assignmentsAsync.when(
              data: (assignments) {
                if (assignments.isEmpty) return const Text('Koi class assign nahi hui');
                return Column(
                  children: assignments.map((a) {
                    final className = (a['classes'] as Map?)?['name'] ?? '';
                    final subjectName = (a['subjects'] as Map?)?['name'] ?? '';
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('$className - $subjectName'),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => ref
                            .read(teacherManagementControllerProvider.notifier)
                            .removeAssignment(a['id'] as String, widget.teacherId),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Error loading assignments'),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}