import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/providers/auth_state.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/otp_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/domain/entities/user_entity.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoading = authState.status == AuthStatus.loading || authState.status == AuthStatus.initial;
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isAuthRoute = ['/login', '/register', '/otp-login', '/forgot-password'].contains(state.matchedLocation);
      final isSplash = state.matchedLocation == '/splash';

      if (isLoading) return isSplash ? null : '/splash';
      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && (isAuthRoute || isSplash)) {
        return _dashboardPathForRole(authState.user!.role);
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/otp-login', builder: (context, state) => const OtpScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/reset-password', builder: (context, state) => const ResetPasswordScreen()),

      // Role dashboards — Phase 2+ mein actual screens yahan add hongi
      GoRoute(path: '/dashboard/admin', builder: (context, state) => const _PlaceholderDashboard('Admin')),
      GoRoute(path: '/dashboard/teacher', builder: (context, state) => const _PlaceholderDashboard('Teacher')),
      GoRoute(path: '/dashboard/parent', builder: (context, state) => const _PlaceholderDashboard('Parent')),
      GoRoute(path: '/dashboard/student', builder: (context, state) => const _PlaceholderDashboard('Student')),
      GoRoute(path: '/dashboard/super-admin', builder: (context, state) => const _PlaceholderDashboard('Super Admin')),
      GoRoute(path: '/dashboard/accountant', builder: (context, state) => const _PlaceholderDashboard('Accountant')),
      GoRoute(path: '/dashboard/transport', builder: (context, state) => const _PlaceholderDashboard('Transport')),
    ],
  );
});

String _dashboardPathForRole(UserRole role) {
  switch (role) {
    case UserRole.superAdmin:
      return '/dashboard/super-admin';
    case UserRole.admin:
      return '/dashboard/admin';
    case UserRole.teacher:
      return '/dashboard/teacher';
    case UserRole.parent:
      return '/dashboard/parent';
    case UserRole.student:
      return '/dashboard/student';
    case UserRole.accountant:
      return '/dashboard/accountant';
    case UserRole.transportManager:
      return '/dashboard/transport';
  }
}

class _PlaceholderDashboard extends StatelessWidget {
  final String role;
  const _PlaceholderDashboard(this.role);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('$role Dashboard')), body: Center(child: Text('$role Dashboard — Phase 2')));
  }
}