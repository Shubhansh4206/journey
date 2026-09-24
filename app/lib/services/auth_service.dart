import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Registers user with Supabase Auth.
  /// If email confirmation is enabled in Supabase, [response.session] will be null
  /// and an email verification is sent (subject to Supabase hourly rate limits).
  /// If email confirmation is disabled, user is immediately logged in with an active session.
  Future<AuthResponse> registerWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: (fullName != null && fullName.isNotEmpty)
          ? {'display_name': fullName, 'full_name': fullName}
          : null,
    );

    // If profile table exists and user was created, attempt upsert
    if (response.user != null) {
      try {
        await _client.from('users').upsert({
          'id': response.user!.id,
          'email': response.user!.email,
          if (fullName != null && fullName.isNotEmpty) 'name': fullName,
        });
      } catch (e) {
        // RLS or schema might differ; do not break auth flow if table insert fails
        debugPrint('Profile sync notice (non-fatal): $e');
      }
    }

    return response;
  }

  /// Sign in with Email and Password
  Future<AuthResponse> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with Google OAuth using Supabase
  Future<bool> signInWithGoogle() async {
    try {
      final success = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.journey://login-callback/',
      );
      return success;
    } catch (e) {
      debugPrint('Google OAuth error: $e');
      rethrow;
    }
  }

  /// Send password reset link to user's email
  Future<void> sendPasswordReset(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: kIsWeb ? null : 'io.supabase.journey://reset-callback/',
    );
  }

  /// Sign out current session
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
}