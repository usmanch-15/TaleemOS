import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/student_provider.dart';

class StudentDetailScreen extends ConsumerWidget {
  final String studentId;
  const StudentDetailScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(studentDetailProvider(studentId));
    final parentsAsync = ref.watch(linkedParentsProvider(studentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Student'),
                  content: const Text('Kya aap confirm hain? Student inactive kar diya jayega.'),
                  actions: [
                    TextButton(onPressed: () => context.pop(false), child: const Text('Cancel')),
                    TextButton(onPressed: () => context.pop(true), child: const Text('Delete')),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref.read(studentFormControllerProvider.notifier).deleteStudent(studentId);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
      body: studentAsync.when(
        data: (student) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage: student.profileImageUrl != null ? NetworkImage(student.profileImageUrl!) : null,
                  child: student.profileImageUrl == null ? Text(student.fullName.substring(0, 1), style: const TextStyle(fontSize: 30)) : null,
                ),
              ),
              const SizedBox(height: 16),
              Center(child: Text(student.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
              Center(child: Text(student.studentCode, style: const TextStyle(color: Colors.grey))),
              const SizedBox(height: 20),
              _InfoRow(label: 'Father Name', value: student.fatherName ?? '-'),
              _InfoRow(label: 'Roll Number', value: student.rollNumber ?? '-'),
              _InfoRow(label: 'Gender', value: student.gender ?? '-'),
              _InfoRow(label: 'Phone', value: student.phone ?? '-'),
              _InfoRow(label: 'Address', value: student.address ?? '-'),
              _InfoRow(label: 'Blood Group', value: student.bloodGroup ?? '-'),
              _InfoRow(label: 'Emergency Contact', value: student.emergencyContact ?? '-'),
              _InfoRow(label: 'Status', value: student.status.name),
              const Divider(height: 32),
              const Text('Linked Parents/Guardians', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              parentsAsync.when(
                data: (parents) {
                  if (parents.isEmpty) return const Text('Koi parent link nahi hai');
                  return Column(
                    children: parents.map((p) {
                      final user = p['users'] as Map<String, dynamic>;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(user['name'] as String? ?? ''),
                        subtitle: Text('${p['relation']} • ${user['phone'] ?? ''}'),
                      );
                    }).toList(),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Error loading parents'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}