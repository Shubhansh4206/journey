import 'package:flutter/material.dart';
import 'state/guide_state.dart';
import 'theme/app_theme.dart';
import 'screens/login_landing_screen.dart';
import 'screens/guide_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GuideApp());
}

class GuideApp extends StatefulWidget {
  const GuideApp({super.key});

  @override
  State<GuideApp> createState() => _GuideAppState();
}

class _GuideAppState extends State<GuideApp> {
  final GuideState _guideState = GuideState();

  @override
  void initState() {
    super.initState();
    _guideState.initSupabaseSync();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Journey - Guide Command Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: ListenableBuilder(
        listenable: _guideState,
        builder: (context, _) {
          if (!_guideState.isLoggedIn) {
            return LoginLandingScreen(
              guideState: _guideState,
              onLoginSuccess: () {
                // Notifier updates automatically
              },
            );
          }
          return GuideDashboardScreen(
            guideState: _guideState,
            onLogout: () {
              _guideState.logout();
            },
          );
        },
      ),
    );
  }
}
