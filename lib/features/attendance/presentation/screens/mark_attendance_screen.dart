import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../classes/presentation/providers/class_provider.dart';
import '../../../students/presentation/providers/student_provider.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/attendance_entity.dart';
import '../providers/attendance_provider.dart';
import '../widgets/attendance_status_selector.dart';

class MarkAttendanceScreen extends ConsumerStatefulWidget {
  final String classId;
  final String className;
  const MarkAttendanceScreen({super.key, required this.classId, required this.className});

  @override
  ConsumerState<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends ConsumerState<MarkAttendanceScreen> {
  String? _selectedSectionId;
  String? _selectedSubjectId;
  bool _initializedFromExisting = false;

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedAttendanceDateProvider);
    final draft = ref.watch(attendanceDraftProvider);
    final submitState = ref.watch(attendanceSubmitControllerProvider);

    ref.read(studentFilterProvider.notifier).state =
        StudentFilterState(classId: widget.classId, sectionId: _selectedSectionId);
    final studentsAsync = ref.watch(studentsListProvider);

    final sectionsAsync = ref.watch(sectionsForClassProvider(widget.classId));
    final subjectsAsync = ref.watch(subjectsForClassProvider(widget.classId));

    return Scaffold(
      appBar: AppBar(title: Text('Mark Attendance — ${widget.className}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        ref.read(selectedAttendanceDateProvider.notifier).state = picked;
                        setState(() => _initializedFromExisting = false);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                sectionsAsync.when(
                  data: (sections) {
                    if (sections.isEmpty) return const SizedBox.shrink();
                    return DropdownButton<String>(
                      hint: const Text('Section'),
                      value: _selectedSectionId,
                      items: sections.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                      onChanged: (value) => setState(() {
                        _selectedSectionId = value;
                        _initializedFromExisting = false;
                      }),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          subjectsAsync.when(
            data: (subjects) {
              if (subjects.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Subject (optional)'),
                    value: _selectedSubjectId,
                    items: subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (value) => setState(() {
                      _selectedSubjectId = value;
                      _initializedFromExisting = false;
                    }),
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const Divider(height: 24),
          Expanded(
            child: studentsAsync.when(
              data: (result) {
                if (result.items.isEmpty) {
                  return const Center(child: Text('Is class mein koi student nahi hai'));
                }

                final existingAsync = ref.watch(existingAttendanceProvider((
                classId: widget.classId,
                sectionId: _selectedSectionId,
                subjectId: _selectedSubjectId,
                date: selectedDate,
                )));

                existingAsync.whenData((records) {
                  if (records.isNotEmpty && !_initializedFromExisting) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref.read(attendanceDraftProvider.notifier).loadExisting(records);
                      setState(() => _initializedFromExisting = true);
                    });
                  }
                });

                final isLocked = existingAsync.value?.any((r) => !r.isEditable) ?? false;

                return Column(
                  children: [
                    if (isLocked)
                      Container(
                        width: double.infinity,
                        color: Colors.amber.shade100,
                        padding: const EdgeInsets.all(10),
                        child: const Text(
                          'Ye attendance ka edit-window (24 ghante) khatam ho chuka hai.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.done_all, size: 18),
                          label: const Text('Mark All Present'),
                          onPressed: isLocked
                              ? null
                              : () => ref
                              .read(attendanceDraftProvider.notifier)
                              .markAllPresent(result.items.map((s) => s.id).toList()),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: result.items.length,
                        itemBuilder: (context, index) {
                          final student = result.items[index];
                          final status = draft.statusMap[student.id];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundImage:
                                    student.profileImageUrl != null ? NetworkImage(student.profileImageUrl!) : null,
                                    child: student.profileImageUrl == null
                                        ? Text(student.fullName.isNotEmpty ? student.fullName[0] : '?')
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text('${student.fullName}\n${student.rollNumber ?? "-"}', style: const TextStyle(fontSize: 13)),
                                  ),
                                  AttendanceStatusSelector(
                                    selected: status,
                                    onChanged: isLocked
                                        ? (_) {}
                                        : (newStatus) =>
                                        ref.read(attendanceDraftProvider.notifier).setStatus(student.id, newStatus),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: AppButton(
                        label: 'Submit Attendance',
                        isLoading: submitState.isLoading,
                        onPressed: isLocked
                            ? null
                            : () async {
                          final success = await ref.read(attendanceSubmitControllerProvider.notifier).submit(
                            classId: widget.classId,
                            sectionId: _selectedSectionId,
                            subjectId: _selectedSubjectId,
                            date: selectedDate,
                          );
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(content: Text('Attendance submit ho gayi')));
                          } else if (context.mounted) {
                            final error = ref.read(attendanceSubmitControllerProvider).error;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error?.toString() ?? 'Kuch ghalat ho gaya'), backgroundColor: Colors.red),
                            );
                          }
                        },
                      ),
                    ),
                  ],
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