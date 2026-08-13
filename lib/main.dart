import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app_router.dart';
import 'core/services/supabase_service.dart';
import 'core/services/push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.instance.init();
  await Firebase.initializeApp();
  await PushNotificationService.instance.init(client: SupabaseService.instance.client);
  runApp(const ProviderScope(child: TaleemOSApp()));
}

class TaleemOSApp extends ConsumerWidget {
  const TaleemOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'TaleemOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(filled: true),
      ),
      routerConfig: router,
    );
  }
}