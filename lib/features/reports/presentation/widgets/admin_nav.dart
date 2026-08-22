import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../school/presentation/providers/school_provider.dart';

/// Ek single navigation item ka model.
class AdminNavItem {
  final String label;
  final IconData icon;
  final String route;

  const AdminNavItem({required this.label, required this.icon, required this.route});
}

/// Ek group/section of nav items (jaise "Academics", "Operations" waghera)
class AdminNavSection {
  final String? title;
  final List<AdminNavItem> items;

  const AdminNavSection({this.title, required this.items});
}

/// Poori app mein sidebar aur drawer dono is single source of truth se banenge,
/// taake navigation items kabhi out-of-sync na hon.
const List<AdminNavSection> adminNavSections = [
  AdminNavSection(items: [
    AdminNavItem(label: 'Dashboard', icon: Icons.dashboard_outlined, route: '/dashboard/admin'),
  ]),
  AdminNavSection(title: 'ACADEMICS', items: [
    AdminNavItem(label: 'Classes', icon: Icons.class_outlined, route: '/admin/classes'),
    AdminNavItem(label: 'Students', icon: Icons.groups_outlined, route: '/admin/students'),
    AdminNavItem(label: 'Teachers', icon: Icons.person_outline, route: '/admin/teachers'),
    AdminNavItem(label: 'Timetable', icon: Icons.calendar_view_week_outlined, route: '/timetable'),
    AdminNavItem(label: 'Exams', icon: Icons.assignment_outlined, route: '/admin/exams'),
  ]),
  AdminNavSection(title: 'OPERATIONS', items: [
    AdminNavItem(label: 'Attendance Reports', icon: Icons.fact_check_outlined, route: '/admin/attendance/reports'),
    AdminNavItem(label: 'Fees', icon: Icons.receipt_long_outlined, route: '/fees/dashboard'),
    AdminNavItem(label: 'Transport', icon: Icons.directions_bus_outlined, route: '/transport/vehicles'),
  ]),
  AdminNavSection(title: 'ENGAGEMENT', items: [
    AdminNavItem(label: 'Announcements', icon: Icons.campaign_outlined, route: '/announcements'),
    AdminNavItem(label: 'Complaints', icon: Icons.report_problem_outlined, route: '/complaints'),
    AdminNavItem(label: 'Notifications', icon: Icons.notifications_outlined, route: '/notifications'),
  ]),
  AdminNavSection(title: 'ACCOUNT', items: [
    AdminNavItem(label: 'School Profile', icon: Icons.school_outlined, route: '/admin/school-profile'),
    AdminNavItem(label: 'Subscription', icon: Icons.workspace_premium_outlined, route: '/subscription/my'),
    AdminNavItem(label: 'Support', icon: Icons.support_agent_outlined, route: '/support'),
    AdminNavItem(label: 'Settings', icon: Icons.settings_outlined, route: '/profile'),
  ]),
];

/// Permanent sidebar — wide screens (web/tablet) ke liye.
class AdminSidebar extends ConsumerWidget {
  final String currentRoute;
  const AdminSidebar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 260,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          const _SidebarHeader(),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: _NavList(currentRoute: currentRoute, onTap: (route) => _navigate(context, route)),
            ),
          ),
          const Divider(height: 1),
          _LogoutTile(onTap: () => _logout(context, ref)),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// Mobile/narrow screens ke liye Drawer — same content, Drawer widget mein wrapped.
class AdminDrawer extends ConsumerWidget {
  final String currentRoute;
  const AdminDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const _SidebarHeader(),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: _NavList(
                  currentRoute: currentRoute,
                  onTap: (route) {
                    Navigator.of(context).pop(); // drawer close karo
                    _navigate(context, route);
                  },
                ),
              ),
            ),
            const Divider(height: 1),
            _LogoutTile(onTap: () => _logout(context, ref)),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

void _navigate(BuildContext context, String route) {
  if (GoRouterState.of(context).matchedLocation == route) return;
  context.go(route);
}

Future<void> _logout(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Kya aap logout karna chahte hain?'),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Logout')),
      ],
    ),
  );
  if (confirmed == true) {
    await ref.read(authControllerProvider.notifier).logout();
    if (context.mounted) context.go('/login');
  }
}

class _SidebarHeader extends ConsumerWidget {
  const _SidebarHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schoolAsync = ref.watch(currentSchoolProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TaleemOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                schoolAsync.when(
                  data: (school) => Text(
                    school?.name ?? 'School',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  loading: () => Text('...', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  error: (_, __) => Text('School', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavList extends StatelessWidget {
  final String currentRoute;
  final ValueChanged<String> onTap;
  const _NavList({required this.currentRoute, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final section in adminNavSections) ...[
          if (section.title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                section.title!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          for (final item in section.items) _NavTile(item: item, selected: currentRoute == item.route, onTap: () => onTap(item.route)),
        ],
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  final AdminNavItem item;
  final bool selected;
  final VoidCallback onTap;
  const _NavTile({required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(item.icon, size: 20, color: selected ? primary : Colors.grey.shade700),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      color: selected ? primary : Colors.grey.shade800,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(Icons.logout, size: 20, color: Colors.red),
                SizedBox(width: 14),
                Text('Logout', style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}