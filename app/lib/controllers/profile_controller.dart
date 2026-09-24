import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService = ProfileService();

  // Controllers
  final fullNameController = TextEditingController();
  final ageController = TextEditingController();
  final phoneController = TextEditingController();

  // Observable selections
  final selectedGender = RxnString();
  final selectedTravelExperience = RxnString();
  final selectedEnvironmentPreferences = <String>[].obs;
  final selectedAccommodationStandard = <String>[].obs;
  final selectedDietaryNeeds = <String>[].obs;
  final isSmoker = false.obs;
  final isDrinker = false.obs;

  final isLoading = false.obs;
  final errorMessage = RxnString();

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

    // Try fetching existing profile from database
    final existing = await _profileService.getProfile(user.id);
    if (existing != null) {
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
      selectedEnvironmentPreferences.assignAll(existing.environmentPreferences);
      selectedAccommodationStandard.assignAll(existing.accommodationStandard);
      selectedDietaryNeeds.assignAll(existing.dietaryNeeds);
      isSmoker.value = existing.isSmoker;
      isDrinker.value = existing.isDrinker;
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

  Future<bool> saveProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      errorMessage.value = 'User is not logged in. Please sign in again.';
      return false;
    }

    final name = fullNameController.text.trim();
    if (name.isEmpty) {
      errorMessage.value = 'Please enter your full name';
      return false;
    }

    int? parsedAge;
    if (ageController.text.trim().isNotEmpty) {
      parsedAge = int.tryParse(ageController.text.trim());
      if (parsedAge == null || parsedAge < 10 || parsedAge > 120) {
        errorMessage.value = 'Please enter a valid age (10 - 120)';
        return false;
      }
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final profile = UserProfile(
        id: user.id,
        fullName: name,
        age: parsedAge,
        gender: selectedGender.value,
        phoneNumber: phoneController.text.trim().isEmpty
            ? null
            : phoneController.text.trim(),
        travelExperience: selectedTravelExperience.value,
        environmentPreferences: selectedEnvironmentPreferences.toList(),
        accommodationStandard: selectedAccommodationStandard.toList(),
        dietaryNeeds: selectedDietaryNeeds.toList(),
        isSmoker: isSmoker.value,
        isDrinker: isDrinker.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await _profileService.saveProfile(profile);
      return success;
    } catch (e) {
      errorMessage.value = 'Could not save profile. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
