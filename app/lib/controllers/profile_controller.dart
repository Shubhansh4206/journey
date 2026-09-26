import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class ProfileController extends GetxController {
  // Reactive loading & error state
  final isLoading = false.obs;
  final errorMessage = RxnString();

  // Form field controllers
  final fullNameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();

  // Reactive selection state
  final selectedGender = RxnString();
  final selectedTravelExperience = RxnString();
  final selectedEnvironmentPreferences = <String>[].obs;
  final selectedAccommodationStandard = <String>[].obs;
  final selectedDietaryNeeds = <String>[].obs;
  final isSmoker = false.obs;
  final isDrinker = false.obs;

  // Preset options
  static const List<String> genderOptions = [
    'Male',
    'Female',
    'Non-Binary',
    'Prefer not to say',
  ];

  static const List<String> travelExperienceOptions = [
    'Beginner',
    'Occasional Explorer',
    'Frequent Adventurer',
    'Globetrotter / Pro',
  ];

  static const List<String> environmentOptions = [
    '🏖️ Beaches',
    '⛰️ Mountains',
    '🏙️ Cities & Culture',
    '🌲 Forests & Nature',
    '🏛️ Historic Sites',
    '🏜️ Deserts',
    '❄️ Snow & Winter',
    '🌴 Tropical Islands',
  ];

  static const List<String> accommodationOptions = [
    'Budget / Hostel',
    'Standard Hotel',
    'Boutique Stay',
    'Luxury Resort',
    'Vacation Rental / Villa',
    'Glamping / Eco-Lodge',
  ];

  static const List<String> dietaryOptions = [
    'No Restrictions',
    'Vegetarian',
    'Vegan',
    'Halal',
    'Kosher',
    'Gluten-Free',
    'Dairy-Free',
  ];

  @override
  void onInit() {
    super.onInit();
    loadExistingProfile();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  /// Load any existing profile data from Supabase for the current user
  void loadExistingProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // Pre-populate with auth metadata if available
    final metaName = user.userMetadata?['display_name'] ??
        user.userMetadata?['full_name'];
    if (metaName != null && metaName.toString().isNotEmpty) {
      fullNameController.text = metaName.toString();
    }

    final metaPhone = user.phone;
    if (metaPhone != null && metaPhone.isNotEmpty) {
      phoneController.text = metaPhone;
    }

    for (final table in ['user_profiles', 'profiles', 'users']) {
      try {
        final data = await Supabase.instance.client
            .from(table)
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (data != null) {
          final existing = UserProfile.fromJson(data);
          if (existing.fullName.isNotEmpty) {
            fullNameController.text = existing.fullName;
          }
          if (existing.age != null) {
            ageController.text = existing.age.toString();
          }
          if (existing.phoneNumber != null) {
            phoneController.text = existing.phoneNumber!;
          }
          selectedGender.value = existing.gender;
          selectedTravelExperience.value = existing.travelExperience;
          selectedEnvironmentPreferences
              .assignAll(existing.environmentPreferences);
          selectedAccommodationStandard
              .assignAll(existing.accommodationStandard);
          selectedDietaryNeeds.assignAll(existing.dietaryNeeds);
          isSmoker.value = existing.isSmoker;
          isDrinker.value = existing.isDrinker;
          break;
        }
      } catch (_) {
        // Continue trying fallback tables
      }
    }
  }

  void toggleEnvironment(String item) {
    if (selectedEnvironmentPreferences.contains(item)) {
      selectedEnvironmentPreferences.remove(item);
    } else {
      selectedEnvironmentPreferences.add(item);
    }
  }

  void toggleAccommodation(String item) {
    if (selectedAccommodationStandard.contains(item)) {
      selectedAccommodationStandard.remove(item);
    } else {
      selectedAccommodationStandard.add(item);
    }
  }

  void toggleDietary(String item) {
    if (item == 'No Restrictions') {
      selectedDietaryNeeds.clear();
      selectedDietaryNeeds.add('No Restrictions');
      return;
    }

    selectedDietaryNeeds.remove('No Restrictions');
    if (selectedDietaryNeeds.contains(item)) {
      selectedDietaryNeeds.remove(item);
    } else {
      selectedDietaryNeeds.add(item);
    }
  }

  /// Saves the user profile to Supabase 'user_profiles' / 'profiles' table
  Future<bool> saveProfile(UserProfile profile) async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) {
      errorMessage.value =
          'No authenticated user found. Please sign in or create an account first.';
      debugPrint('Error: currentUser is null when saving profile');
      return false;
    }

    try {
      isLoading.value = true;
      errorMessage.value = null;

      final payload = profile.toJson();
      debugPrint('Saving profile to Supabase: $payload');

      // Try candidate tables in order: user_profiles, profiles, users
      for (final table in ['user_profiles', 'profiles', 'users']) {
        try {
          await Supabase.instance.client.from(table).upsert(payload);
          debugPrint('Profile successfully saved to Supabase table "$table"!');
          return true;
        } catch (e) {
          final err = e.toString();
          if (err.contains('PGRST205') || err.contains('42P01') || err.contains('not find the table')) {
            continue;
          }
          debugPrint('Notice on table "$table": $e');
        }
      }

      errorMessage.value = 'Failed to save profile. Please check Supabase table permissions.';
      return false;
    } catch (error) {
      debugPrint('General error saving profile: $error');
      errorMessage.value = 'Failed to save profile: $error';
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
