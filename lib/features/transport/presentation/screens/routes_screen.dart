import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/transport_provider.dart';

class RoutesScreen extends ConsumerWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(routesListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transport Routes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/transport/routes/create'),
        icon: const Icon(Icons.add),
        label: const Text('Add Route'),
      ),
      body: routesAsync.when(
        data: (routes) {
          if (routes.isEmpty) return const Center(child: Text('Koi route nahi bani'));
          return ListView.builder(
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final r = routes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Color(0xFFE8EAF6), child: Icon(Icons.route, color: Colors.indigo)),
                  title: Text(r.routeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${r.vehicleNumber ?? "No vehicle"} • ${r.driverName ?? "No driver"}'),
                  trailing: Text('Rs. ${r.monthlyFee.toStringAsFixed(0)}/mo', style: const TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () => context.push('/transport/routes/${r.id}'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}