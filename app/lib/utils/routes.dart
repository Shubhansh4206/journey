import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/onboarding/profile_onboarding_screen.dart';
import '../screens/home_screen.dart';
import '../services/profile_service.dart';

/// ── App Router ──────────────────────────────────────────────────────────────
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) async {
    final session = Supabase.instance.client.auth.currentSession;
    final isOnAuth = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    // 1. Not logged in -> send to login
    if (session == null && !isOnAuth) {
      return '/login';
    }

    // 2. Already logged in and trying to access auth pages -> check profile
    if (session != null && isOnAuth) {
      final hasProfile =
          await ProfileService().hasCompletedProfile(session.user.id);
      return hasProfile ? '/home' : '/onboarding';
    }

    return null; // no redirect
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => RegisterScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => ProfileOnboardingScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
