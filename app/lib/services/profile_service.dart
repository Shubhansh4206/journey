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
            .from('user_profiles')
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

    for (final table in ['user_profiles', 'profiles', 'users']) {
      try {
        await _client.from(table).upsert(payload);
        return true;
      } catch (e) {
        final err = e.toString();
        if (err.contains('PGRST205') || err.contains('42P01') || err.contains('not find the table')) {
          continue;
        }
        debugPrint('Notice on saving to $table: $e');
      }
    }

    debugPrint('Warning: Failed to save profile. Check Supabase RLS policies.');
    return false;
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
