import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? const Center(child: Text('Login required'))
          : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 45,
              backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child: user.photoUrl == null ? Text(user.name.isNotEmpty ? user.name[0] : '?', style: const TextStyle(fontSize: 30)) : null,
            ),
          ),
          const SizedBox(height: 12),
          Center(child: Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          Center(child: Text(user.email, style: TextStyle(color: Colors.grey.shade600))),
          Center(
            child: Chip(
              label: Text(user.role.toDbString().replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontSize: 11)),
            ),
          ),
          const SizedBox(height: 24),
          _MenuTile(icon: Icons.edit_outlined, title: 'Edit Profile', onTap: () => context.push('/profile/edit')),
          _MenuTile(icon: Icons.lock_outline, title: 'Change Password', onTap: () => context.push('/profile/change-password')),
          _MenuTile(icon: Icons.notifications_outlined, title: 'Notification Preferences', onTap: () => context.push('/notifications/preferences')),
          _MenuTile(icon: Icons.help_outline, title: 'Help & Support', onTap: () => context.push('/help')),
          _MenuTile(icon: Icons.privacy_tip_outlined, title: 'Privacy Policy', onTap: () => context.push('/privacy-policy')),
          _MenuTile(icon: Icons.description_outlined, title: 'Terms & Conditions', onTap: () => context.push('/terms')),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.logout,
            title: 'Logout',
            color: Colors.red,
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Kya aap logout karna chahte hain?'),
                  actions: [
                    TextButton(onPressed: () => context.pop(false), child: const Text('Cancel')),
                    TextButton(onPressed: () => context.pop(true), child: const Text('Logout')),
                  ],
                ),
              );
              if (confirmed == true) {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _MenuTile({required this.icon, required this.title, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}