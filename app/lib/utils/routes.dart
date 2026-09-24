import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home_screen.dart';

/// ── App Router ──────────────────────────────────────────────────────────────
/// Uses GoRouter for declarative, path-based navigation.
/// The initial route is determined by whether the user is already signed in.
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isOnAuth = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    // Already logged in → send to home
    if (session != null && isOnAuth) return '/home';

    // Not logged in and trying to access protected routes → send to login
    if (session == null && !isOnAuth) return '/login';

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
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
