import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch user profile from Supabase
  Future<UserProfile?> getProfile(String userId) async {
    try {
      // 1. Try 'profiles' table first
      try {
        final data = await _client
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();
        if (data != null) {
          return UserProfile.fromJson(data);
        }
      } catch (e) {
        debugPrint('Notice: Checking profiles table: $e');
      }

      // 2. Fallback to 'users' table
      try {
        final data = await _client
            .from('users')
            .select()
            .eq('id', userId)
            .maybeSingle();
        if (data != null) {
          return UserProfile.fromJson(data);
        }
      } catch (e) {
        debugPrint('Notice: Checking users table: $e');
      }

      return null;
    } catch (e) {
      debugPrint('Error getting profile for $userId: $e');
      return null;
    }
  }

  /// Save or update user profile in Supabase
  Future<bool> saveProfile(UserProfile profile) async {
    final payload = profile.toJson();
    payload['updated_at'] = DateTime.now().toIso8601String();

    bool saved = false;

    // Try 'profiles' table
    try {
      await _client.from('profiles').upsert(payload);
      saved = true;
    } catch (e) {
      debugPrint('Notice: Could not upsert to profiles table: $e');
    }

    // Try 'users' table
    try {
      await _client.from('users').upsert(payload);
      saved = true;
    } catch (e) {
      debugPrint('Notice: Could not upsert to users table: $e');
    }

    if (!saved) {
      debugPrint('Warning: Failed to save profile to both tables. Check Supabase RLS policies.');
    }

    return saved;
  }

  /// Check if the user has already completed onboarding
  Future<bool> hasCompletedProfile(String userId) async {
    try {
      final profile = await getProfile(userId);
      if (profile == null) return false;
      return profile.isCompleted;
    } catch (e) {
      debugPrint('Error checking profile completion: $e');
      return false;
    }
  }
}
