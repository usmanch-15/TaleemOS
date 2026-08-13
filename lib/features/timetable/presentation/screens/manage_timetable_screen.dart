import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../classes/presentation/providers/class_provider.dart';
import '../../../teachers/presentation/providers/teacher_provider.dart';
import '../../domain/entities/timetable_entity.dart';
import '../providers/timetable_provider.dart';
import '../widgets/timetable_day_view.dart';

class ManageTimetableScreen extends ConsumerStatefulWidget {
  final String classId;
  final String className;

  const ManageTimetableScreen({super.key, required this.classId, required this.className});

  @override
  ConsumerState<ManageTimetableScreen> createState() => _ManageTimetableScreenState();
}

class _ManageTimetableScreenState extends ConsumerState<ManageTimetableScreen> {
  String? _selectedSectionId;
  int _selectedDay = 1;

  void _showAddPeriodDialog() {
    String? selectedSubjectId;
    String? selectedTeacherId;
    final roomController = TextEditingController();
    TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 8, minute: 45);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final subjectsAsync = ref.watch(subjectsForClassProvider(widget.classId));
          final teachersAsync = ref.watch(teachersListProvider);

          return AlertDialog(
            title: const Text('Add Period'),
            content: SizedBox(
              width: 320,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    subjectsAsync.when(
                      data: (subjects) => DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Subject'),
                        items: subjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                        onChanged: (value) => setDialogState(() => selectedSubjectId = value),
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const Text('Error'),
                    ),
                    const SizedBox(height: 10),
                    teachersAsync.when(
                      data: (teachers) => DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Teacher (optional)'),
                        items: teachers.map((t) => DropdownMenuItem(value: t.id, child: Text(t.name))).toList(),
                        onChanged: (value) => setDialogState(() => selectedTeacherId = value),
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const Text('Error'),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Start: ${startTime.format(context)}'),
                      onTap: () async {
                        final picked = await showTimePicker(context: context, initialTime: startTime);
                        if (picked != null) setDialogState(() => startTime = picked);
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('End: ${endTime.format(context)}'),
                      onTap: () async {
                        final picked = await showTimePicker(context: context, initialTime: endTime);
                        if (picked != null) setDialogState(() => endTime = picked);
                      },
                    ),
                    TextField(controller: roomController, decoration: const InputDecoration(labelText: 'Room Number (optional)')),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () async {
                  if (selectedSubjectId == null) return;
                  final schoolId = ref.read(authControllerProvider).user?.schoolId;
                  if (schoolId == null) return;

                  String fmt(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

                  final entry = TimetableEntryEntity(
                    id: '',
                    schoolId: schoolId,
                    classId: widget.classId,
                    sectionId: _selectedSectionId,
                    subjectId: selectedSubjectId!,
                    subjectName: '',
                    teacherId: selectedTeacherId,
                    dayOfWeek: _selectedDay,
                    startTime: fmt(startTime),
                    endTime: fmt(endTime),
                    roomNumber: roomController.text.trim().isEmpty ? null : roomController.text.trim(),
                  );

                  final success = await ref.read(timetableControllerProvider.notifier).addEntry(entry);
                  if (context.mounted) {
                    Navigator.pop(context);
                    if (!success) {
                      final error = ref.read(timetableControllerProvider).error;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error?.toString() ?? 'Kuch ghalat ho gaya'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(classTimetableProvider((classId: widget.classId, sectionId: _selectedSectionId)));
    final sectionsAsync = ref.watch(sectionsForClassProvider(widget.classId));

    return Scaffold(
      appBar: AppBar(title: Text('${widget.className} — Timetable')),
      floatingActionButton: FloatingActionButton(onPressed: _showAddPeriodDialog, child: const Icon(Icons.add)),
      body: Column(
        children: [
          sectionsAsync.when(
            data: (sections) => sections.isEmpty
                ? const SizedBox.shrink()
                : Padding(
              padding: const EdgeInsets.all(8),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Section'),
                value: _selectedSectionId,
                items: sections.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (value) => setState(() => _selectedSectionId = value),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: List.generate(6, (i) {
                final day = i + 1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(TimetableEntryEntity.dayNames[day]!.substring(0, 3)),
                    selected: _selectedDay == day,
                    onSelected: (_) => setState(() => _selectedDay = day),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: entriesAsync.when(
              data: (entries) {
                final dayEntries = entries.where((e) => e.dayOfWeek == _selectedDay).toList();
                return TimetableDayView(
                  entries: dayEntries,
                  onDelete: (entry) => ref.read(timetableControllerProvider.notifier).deleteEntry(entry.id),
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