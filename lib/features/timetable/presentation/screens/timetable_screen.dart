import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/timetable_entity.dart';
import '../providers/timetable_provider.dart';
import '../widgets/timetable_day_view.dart';

class TimetableScreen extends ConsumerStatefulWidget {
  final String? classId;
  final String? sectionId;
  final String? teacherId;

  const TimetableScreen({super.key, this.classId, this.sectionId, this.teacherId});

  @override
  ConsumerState<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends ConsumerState<TimetableScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final todayIndex = DateTime.now().weekday - 1; // 0-indexed, Monday=0
    _tabController = TabController(length: 7, vsync: this, initialIndex: todayIndex.clamp(0, 6));
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = widget.teacherId != null
        ? ref.watch(teacherTimetableProvider(widget.teacherId!))
        : ref.watch(classTimetableProvider((classId: widget.classId!, sectionId: widget.sectionId)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: TimetableEntryEntity.dayNames.entries
              .where((e) => e.key <= 6) // Mon-Sat, exclude Sunday tab typically
              .map((e) => Tab(text: e.value.substring(0, 3)))
              .toList(),
        ),
      ),
      body: entriesAsync.when(
        data: (entries) {
          return TabBarView(
            controller: _tabController,
            children: List.generate(6, (index) {
              final dayNum = index + 1;
              final dayEntries = entries.where((e) => e.dayOfWeek == dayNum).toList();
              return TimetableDayView(entries: dayEntries);
            }),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}