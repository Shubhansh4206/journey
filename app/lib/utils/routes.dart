import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/onboarding/profile_onboarding_screen.dart';
import '../screens/home_screen.dart';
import '../screens/packages_screen.dart';
import '../screens/solo_comm_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/main_layout.dart';
import '../services/profile_service.dart';

/// ── App Router ──────────────────────────────────────────────────────────────
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellNavigatorPackagesKey = GlobalKey<NavigatorState>(debugLabel: 'packages');
final _shellNavigatorSoloCommKey = GlobalKey<NavigatorState>(debugLabel: 'solo_comm');
final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
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
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorPackagesKey,
          routes: [
            GoRoute(
              path: '/packages',
              builder: (context, state) => const PackagesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorSoloCommKey,
          routes: [
            GoRoute(
              path: '/solo_comm',
              builder: (context, state) => const SoloCommScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorProfileKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
