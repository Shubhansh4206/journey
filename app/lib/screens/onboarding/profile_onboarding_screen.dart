import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../common_widgets/widgets.dart';
import '../../controllers/profile_controller.dart';
import '../../models/user_profile.dart';
import '../../utils/colors.dart';

class ProfileOnboardingScreen extends StatelessWidget {
  ProfileOnboardingScreen({super.key});

  // Inject ProfileController
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Journey Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDarkBlue,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero Header ─────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.softGrey,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.border,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryDarkBlue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.flight_takeoff_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Let's Get Started!",
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDarkBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tell us a bit about your travel preferences so we can tailor your experience.',
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Error Notice Banner ──────────────────────────────────
                  Obx(() {
                    final err = profileController.errorMessage.value;
                    if (err == null) return const SizedBox.shrink();

                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: AppColors.danger, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              err,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: const Color(0xFF991B1B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // ── 1. Basic Info ─────────────────────────────────────────
                  _buildSectionTitle('1. Personal Details', Icons.person_rounded),
                  const SizedBox(height: 14),
                  CustomTextField(
                    label: 'Full Name *',
                    controller: profileController.fullNameController,
                    prefixIcon: Icons.badge_outlined,
                    hintText: 'Enter your full name',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Age',
                          controller: profileController.ageController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.calendar_today_outlined,
                          hintText: 'Enter your age',
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: CustomTextField(
                          label: 'Phone',
                          controller: profileController.phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                          hintText: 'Enter phone number',
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Gender',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ProfileController.genderOptions.map((gender) {
                          final isSelected =
                              profileController.selectedGender.value == gender;
                          return ChoiceChip(
                            label: Text(gender),
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primaryDarkBlue,
                            backgroundColor: AppColors.softGrey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primaryDarkBlue
                                    : AppColors.border,
                              ),
                            ),
                            onSelected: (selected) {
                              profileController.selectedGender.value =
                                  selected ? gender : null;
                            },
                          );
                        }).toList(),
                      )),

                  const SizedBox(height: 32),

                  // ── 2. Travel Experience ──────────────────────────────────
                  _buildSectionTitle(
                      '2. Travel Experience', Icons.explore_rounded),
                  const SizedBox(height: 12),
                  Obx(() => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ProfileController.travelExperienceOptions
                            .map((exp) {
                          final isSelected =
                              profileController.selectedTravelExperience.value == exp;
                          return ChoiceChip(
                            label: Text(exp),
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primaryDarkBlue,
                            backgroundColor: AppColors.softGrey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primaryDarkBlue
                                    : AppColors.border,
                              ),
                            ),
                            onSelected: (selected) {
                              profileController.selectedTravelExperience.value =
                                  selected ? exp : null;
                            },
                          );
                        }).toList(),
                      )),

                  const SizedBox(height: 32),

                  // ── 3. Environment Preferences ────────────────────────────
                  _buildSectionTitle(
                      '3. Environment Preferences', Icons.landscape_rounded),
                  const SizedBox(height: 6),
                  Text(
                    'Select all that you enjoy visiting',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            ProfileController.environmentOptions.map((env) {
                          final isSelected = profileController
                              .selectedEnvironmentPreferences
                              .contains(env);
                          return FilterChip(
                            label: Text(env),
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primaryDarkBlue,
                            backgroundColor: AppColors.softGrey,
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primaryDarkBlue
                                    : AppColors.border,
                              ),
                            ),
                            onSelected: (_) =>
                                profileController.toggleEnvironment(env),
                          );
                        }).toList(),
                      )),

                  const SizedBox(height: 32),

                  // ── 4. Accommodation Standard ─────────────────────────────
                  _buildSectionTitle(
                      '4. Preferred Accommodation', Icons.hotel_rounded),
                  const SizedBox(height: 12),
                  Obx(() => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            ProfileController.accommodationOptions.map((acc) {
                          final isSelected = profileController
                              .selectedAccommodationStandard
                              .contains(acc);
                          return FilterChip(
                            label: Text(acc),
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primaryDarkBlue,
                            backgroundColor: AppColors.softGrey,
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primaryDarkBlue
                                    : AppColors.border,
                              ),
                            ),
                            onSelected: (_) =>
                                profileController.toggleAccommodation(acc),
                          );
                        }).toList(),
                      )),

                  const SizedBox(height: 32),

                  // ── 5. Dietary Needs ──────────────────────────────────────
                  _buildSectionTitle(
                      '5. Dietary Needs', Icons.restaurant_rounded),
                  const SizedBox(height: 12),
                  Obx(() => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ProfileController.dietaryOptions.map((diet) {
                          final isSelected = profileController
                              .selectedDietaryNeeds
                              .contains(diet);
                          return FilterChip(
                            label: Text(diet),
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primaryDarkBlue,
                            backgroundColor: AppColors.softGrey,
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.primaryDarkBlue
                                    : AppColors.border,
                              ),
                            ),
                            onSelected: (_) =>
                                profileController.toggleDietary(diet),
                          );
                        }).toList(),
                      )),

                  const SizedBox(height: 32),

                  // ── 6. Lifestyle / Habits ─────────────────────────────────
                  _buildSectionTitle('6. Lifestyle', Icons.local_bar_rounded),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Obx(() => SwitchListTile(
                              title: Text(
                                'Smoker',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                'Helps select smoking/non-smoking rooms',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              value: profileController.isSmoker.value,
                              activeTrackColor: Colors.indigoAccent,
                              onChanged: (val) =>
                                  profileController.isSmoker.value = val,
                            )),
                        const Divider(height: 1),
                        Obx(() => SwitchListTile(
                              title: Text(
                                'Drinker',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                'Helps recommend nightlife & social experiences',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              value: profileController.isDrinker.value,
                              activeTrackColor: Colors.indigoAccent,
                              onChanged: (val) =>
                                  profileController.isDrinker.value = val,
                            )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── "Complete Profile" Button ─────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: Obx(() => ElevatedButton(
                          onPressed: profileController.isLoading.value
                              ? null
                              : () async {
                                  final currentUser =
                                      Supabase.instance.client.auth.currentUser;
                                  if (currentUser == null) {
                                    profileController.errorMessage.value =
                                        'No authenticated user found. Please sign in or create an account first.';
                                    return;
                                  }

                                  final fullName = profileController
                                      .fullNameController.text
                                      .trim();
                                  if (fullName.isEmpty) {
                                    profileController.errorMessage.value =
                                        'Please enter your full name';
                                    return;
                                  }

                                  final userProfile = UserProfile(
                                    id: currentUser.id,
                                    fullName: fullName,
                                    age: int.tryParse(profileController
                                        .ageController.text
                                        .trim()),
                                    gender: profileController
                                        .selectedGender.value,
                                    phoneNumber: profileController
                                            .phoneController.text
                                            .trim()
                                            .isEmpty
                                        ? null
                                        : profileController
                                            .phoneController.text
                                            .trim(),
                                    travelExperience: profileController
                                        .selectedTravelExperience.value,
                                    environmentPreferences: profileController
                                        .selectedEnvironmentPreferences
                                        .toList(),
                                    accommodationStandard: profileController
                                        .selectedAccommodationStandard
                                        .toList(),
                                    dietaryNeeds: profileController
                                        .selectedDietaryNeeds
                                        .toList(),
                                    isSmoker:
                                        profileController.isSmoker.value,
                                    isDrinker:
                                        profileController.isDrinker.value,
                                  );

                                  final success = await profileController
                                      .saveProfile(userProfile);

                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Profile saved successfully! Welcome to Journey.'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    context.go('/home');
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDarkBlue,
                            disabledBackgroundColor:
                                AppColors.primaryDarkBlue.withValues(alpha: 0.6),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: profileController.isLoading.value
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  'Complete profile',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        )),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient themeHeaderGradient() {
    return LinearGradient(
      colors: [
        AppColors.primaryDarkBlue.withValues(alpha: 0.08),
        AppColors.primaryLight.withValues(alpha: 0.4),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryDarkBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
