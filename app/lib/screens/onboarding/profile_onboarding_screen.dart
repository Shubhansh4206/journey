import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../common_widgets/widgets.dart';
import '../../controllers/profile_controller.dart';
import '../../utils/colors.dart';

class ProfileOnboardingScreen extends StatelessWidget {
  ProfileOnboardingScreen({super.key});

  final ProfileController controller = Get.put(ProfileController());

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
            color: Colors.indigoAccent,
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
                      gradient: LinearGradient(
                        colors: [
                          Colors.indigoAccent.withValues(alpha: 0.12),
                          const Color(0xFFE0E7FF).withValues(alpha: 0.4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.indigoAccent.withValues(alpha: 0.2),
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
                                color: Colors.indigoAccent,
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
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigoAccent,
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

                  const SizedBox(height: 28),

                  // ── Error Notice Banner ──────────────────────────────────
                  Obx(() {
                    final err = controller.errorMessage.value;
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
                    controller: controller.fullNameController,
                    prefixIcon: Icons.badge_outlined,
                    hintText: 'e.g. Alex Smith',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Age',
                          controller: controller.ageController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.calendar_today_outlined,
                          hintText: 'e.g. 26',
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: CustomTextField(
                          label: 'Phone',
                          controller: controller.phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                          hintText: '+91 9876543210',
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
                              controller.selectedGender.value == gender;
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
                            selectedColor: Colors.indigoAccent,
                            backgroundColor: AppColors.inputFill,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.indigoAccent
                                    : Colors.transparent,
                              ),
                            ),
                            onSelected: (selected) {
                              controller.selectedGender.value =
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
                              controller.selectedTravelExperience.value == exp;
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
                            selectedColor: Colors.indigoAccent,
                            backgroundColor: AppColors.inputFill,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.indigoAccent
                                    : Colors.transparent,
                              ),
                            ),
                            onSelected: (selected) {
                              controller.selectedTravelExperience.value =
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
                          final isSelected = controller
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
                            selectedColor: Colors.indigoAccent,
                            backgroundColor: AppColors.inputFill,
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.indigoAccent
                                    : Colors.transparent,
                              ),
                            ),
                            onSelected: (_) => controller.toggleEnvironment(env),
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
                          final isSelected = controller
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
                            selectedColor: Colors.indigoAccent,
                            backgroundColor: AppColors.inputFill,
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.indigoAccent
                                    : Colors.transparent,
                              ),
                            ),
                            onSelected: (_) =>
                                controller.toggleAccommodation(acc),
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
                          final isSelected =
                              controller.selectedDietaryNeeds.contains(diet);
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
                            selectedColor: Colors.indigoAccent,
                            backgroundColor: AppColors.inputFill,
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.indigoAccent
                                    : Colors.transparent,
                              ),
                            ),
                            onSelected: (_) => controller.toggleDietary(diet),
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
                              value: controller.isSmoker.value,
                              activeColor: Colors.indigoAccent,
                              onChanged: (val) =>
                                  controller.isSmoker.value = val,
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
                              value: controller.isDrinker.value,
                              activeColor: Colors.indigoAccent,
                              onChanged: (val) =>
                                  controller.isDrinker.value = val,
                            )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Submit Button ─────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () async {
                                  final success =
                                      await controller.saveProfile();
                                  if (success && context.mounted) {
                                    Get.snackbar(
                                      'Welcome to Journey!',
                                      'Your profile is set up and ready to go.',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.indigoAccent,
                                      colorText: Colors.white,
                                      duration: const Duration(seconds: 3),
                                    );
                                    context.go('/home');
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent,
                            disabledBackgroundColor:
                                Colors.indigoAccent.withValues(alpha: 0.6),
                            elevation: 4,
                            shadowColor:
                                Colors.indigoAccent.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: controller.isLoading.value
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
                                  'Complete Profile & Explore',
                                  style: GoogleFonts.poppins(
                                    fontSize: 17,
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.indigoAccent),
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
