import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app/app_config.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  late final SupabaseClient client;

  Future<void> init() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      authFlowType: AuthFlowType.pkce,
    );
    client = Supabase.instance.client;
  }

  User? get currentAuthUser => client.auth.currentUser;
  bool get isLoggedIn => currentAuthUser != null;
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}