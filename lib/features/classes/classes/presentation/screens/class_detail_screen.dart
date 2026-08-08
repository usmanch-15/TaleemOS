import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/class_provider.dart';

class ClassDetailScreen extends ConsumerStatefulWidget {
  final String classId;
  final String className;
  const ClassDetailScreen({super.key, required this.classId, required this.className});

  @override
  ConsumerState<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends ConsumerState<ClassDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _addSection() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Section'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'e.g. A')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await ref.read(classManagementControllerProvider.notifier).addSection(widget.classId, controller.text.trim());
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addSubject() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subject'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Subject name')),
            TextField(controller: codeController, decoration: const InputDecoration(hintText: 'Subject code (optional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              await ref.read(classManagementControllerProvider.notifier).addSubject(
                widget.classId,
                nameController.text.trim(),
                codeController.text.trim().isEmpty ? null : codeController.text.trim(),
              );
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sectionsAsync = ref.watch(sectionsForClassProvider(widget.classId));
    final subjectsAsync = ref.watch(subjectsForClassProvider(widget.classId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.className),
        bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'Sections'), Tab(text: 'Subjects')]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _tabController.index == 0 ? _addSection() : _addSubject(),
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          sectionsAsync.when(
            data: (sections) => ListView(
              children: sections
                  .map((s) => ListTile(
                title: Text('Section ${s.name}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => ref
                      .read(classManagementControllerProvider.notifier)
                      .deleteSection(s.id, widget.classId),
                ),
              ))
                  .toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
          subjectsAsync.when(
            data: (subjects) => ListView(
              children: subjects
                  .map((s) => ListTile(
                title: Text(s.name),
                subtitle: s.code != null ? Text(s.code!) : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => ref
                      .read(classManagementControllerProvider.notifier)
                      .deleteSubject(s.id, widget.classId),
                ),
              ))
                  .toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ],
      ),
    );
  }
}