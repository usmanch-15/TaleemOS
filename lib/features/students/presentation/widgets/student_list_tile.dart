import 'package:flutter/material.dart';
import '../../domain/entities/student_entity.dart';

class StudentListTile extends StatelessWidget {
  final StudentEntity student;
  final VoidCallback onTap;

  const StudentListTile({super.key, required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: student.profileImageUrl != null ? NetworkImage(student.profileImageUrl!) : null,
          child: student.profileImageUrl == null ? Text(student.fullName.substring(0, 1)) : null,
        ),
        title: Text(student.fullName),
        subtitle: Text('${student.studentCode} • Roll: ${student.rollNumber ?? "-"}'),
        trailing: Chip(
          label: Text(student.status.name, style: const TextStyle(fontSize: 11)),
          backgroundColor: student.status == StudentStatus.active
              ? Colors.green.shade100
              : Colors.grey.shade200,
        ),
        onTap: onTap,
      ),
    );
  }
}