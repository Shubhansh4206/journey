import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Global reactive notifier for current user's name across screens
  static final ValueNotifier<String?> currentUserNameNotifier =
      ValueNotifier<String?>(null);

  /// Fetch user profile from Supabase
  Future<UserProfile?> getProfile(String userId) async {
    try {
      for (final table in ['user_profiles', 'profiles', 'users']) {
        try {
          final data = await _client
              .from(table)
              .select()
              .eq('id', userId)
              .maybeSingle();
          if (data != null) {
            final profile = UserProfile.fromJson(data);
            if (profile.fullName.isNotEmpty) {
              currentUserNameNotifier.value = profile.fullName;
            }
            return profile;
          }
        } catch (e) {
          final err = e.toString();
          if (err.contains('PGRST205') || err.contains('42P01') || err.contains('not find the table')) {
            continue;
          }
          debugPrint('Notice: Checking $table table: $e');
        }
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
        if (profile.fullName.isNotEmpty) {
          currentUserNameNotifier.value = profile.fullName;
        }
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
