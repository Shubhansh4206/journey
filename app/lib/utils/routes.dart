import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/cart_controller.dart';
import '../data/mock_city_catalog.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/onboarding/profile_onboarding_screen.dart';
import '../screens/home_screen.dart';
import '../screens/packages_screen.dart';
import '../screens/community/community_hub_screen.dart';
import '../screens/groups_nav_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/main_layout.dart';
import '../screens/pending_invites_screen.dart';
import '../screens/create_group_screen.dart';
import '../screens/group_detail_screen.dart';
import '../screens/itinerary_cart_screen.dart';
import '../services/profile_service.dart';
import '../services/travel_mode_service.dart';

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
    GoRoute(
      path: '/invites',
      builder: (context, state) => const PendingInvitesScreen(),
    ),
    GoRoute(
      path: '/create-group',
      builder: (context, state) => const CreateGroupScreen(),
    ),
    GoRoute(
      path: '/groups',
      builder: (context, state) => const GroupsNavScreen(),
    ),
    GoRoute(
      path: '/group/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return GroupDetailScreen(groupId: id);
      },
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) {
        final cartController = Get.isRegistered<CartController>()
            ? Get.find<CartController>()
            : Get.put(CartController());
        final isSolo = TravelModeService.isSolo;
        final city =
            cartController.getActiveCity(isSolo: isSolo) ?? mockCities.first;
        return ItineraryCartScreen(
          city: city,
          isSolo: isSolo,
        );
      },
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
              builder: (context, state) => ValueListenableBuilder<bool>(
                valueListenable: TravelModeService.isSoloNotifier,
                builder: (context, isSolo, _) {
                  return isSolo
                      ? const CommunityHubScreen()
                      : const GroupsNavScreen();
                },
              ),
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
