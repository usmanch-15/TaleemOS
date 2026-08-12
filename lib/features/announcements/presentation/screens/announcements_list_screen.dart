import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/announcement_provider.dart';
import '../widgets/announcement_card.dart';

class AnnouncementsListScreen extends ConsumerWidget {
  const AnnouncementsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementsListProvider);
    final authState = ref.watch(authControllerProvider);
    final canCreate = authState.user?.role.toDbString() == 'admin' || authState.user?.role.toDbString() == 'teacher';

    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
        onPressed: () => context.push('/announcements/create'),
        icon: const Icon(Icons.campaign_outlined),
        label: const Text('New'),
      )
          : null,
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(announcementsListProvider),
        child: announcementsAsync.when(
          data: (list) {
            if (list.isEmpty) {
              return ListView(children: const [SizedBox(height: 100), Center(child: Text('Koi announcement nahi hai'))]);
            }
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final a = list[index];
                return AnnouncementCard(
                  announcement: a,
                  onTap: () {
                    ref.read(announcementControllerProvider.notifier).markAsRead(a.id);
                    context.push('/announcements/${a.id}', extra: a);
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}