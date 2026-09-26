import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../utils/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final ProfileService _profileService = ProfileService();
  UserProfile? _existingProfile;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // Default metadata fallback
    final metaName = user.userMetadata?['display_name'] ??
        user.userMetadata?['full_name'] ??
        user.email?.split('@').first ??
        '';
    final metaPhone = user.phone ?? '';

    _nameController.text = metaName.toString();
    _phoneController.text = metaPhone;

    try {
      final profile = await _profileService.getProfile(user.id);
      if (profile != null) {
        _existingProfile = profile;
        if (profile.fullName.isNotEmpty) {
          _nameController.text = profile.fullName;
        }
        if (profile.age != null) {
          _ageController.text = profile.age.toString();
        }
        if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty) {
          _phoneController.text = profile.phoneNumber!;
        }
      }
    } catch (e) {
      debugPrint('Error loading profile in ProfileScreen: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'User not logged in.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Full name cannot be empty',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final ageVal = int.tryParse(_ageController.text.trim());
      final phoneVal = _phoneController.text.trim();

      final updatedProfile = (_existingProfile ??
              UserProfile(
                id: user.id,
                fullName: newName,
              ))
          .copyWith(
        fullName: newName,
        age: ageVal,
        phoneNumber: phoneVal.isNotEmpty ? phoneVal : null,
      );

      final success = await _profileService.saveProfile(updatedProfile);
      _existingProfile = updatedProfile;

      // Also update Supabase Auth User Metadata for sync
      try {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(
            data: {
              'display_name': newName,
              'full_name': newName,
            },
          ),
        );
      } catch (authErr) {
        debugPrint('Notice: Error updating auth metadata: $authErr');
      }

      // Update global notifier so Home Screen updates immediately
      ProfileService.currentUserNameNotifier.value = newName;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Profile updated successfully!'
                  : 'Profile saved locally. (RLS notice)',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.electricBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update profile: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.electricBlue,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 24,
                  bottom: 120, // space for floating bottom navigation bar
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── 1. Identity & Prominent Verification ──────────────────────
                    const Center(
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Color(0xFFE0E7FF),
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.electricBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Prominent Verified Badge
                    Center(
                      child: Container(
                        width: 180,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.verified_user_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'VERIFIED',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── 2. Trophy Cabinet (The Awards Section) ─────────────────────
                    Row(
                      children: [
                        Text(
                          'Trophy Cabinet',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '3 Unlocked',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 140,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildTrophyBadge(
                            title: 'First Blood',
                            borderColor: Colors.amber,
                            icon: Icons.military_tech_rounded,
                            gradientColors: const [
                              Color(0xFF1E3A8A),
                              Color(0xFF7E22CE),
                            ],
                          ),
                          const SizedBox(width: 12),
                          _buildTrophyBadge(
                            title: 'Trailblazer',
                            borderColor: Colors.amber,
                            icon: Icons.local_fire_department_rounded,
                            gradientColors: const [
                              Color(0xFFEA580C),
                              Color(0xFFC026D3),
                            ],
                          ),
                          const SizedBox(width: 12),
                          _buildTrophyBadge(
                            title: 'Top 1%',
                            borderColor: Colors.blueGrey.shade300,
                            icon: Icons.diamond_rounded,
                            gradientColors: const [
                              Color(0xFF0284C7),
                              Color(0xFF4338CA),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── 2. Editable Vitals ─────────────────────────────────────────
                    _buildSectionHeader('Personal Vitals'),
                    const SizedBox(height: 12),
                    _buildVitalTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildVitalTextField(
                      controller: _ageController,
                      label: 'Age',
                      icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildVitalTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.electricBlue,
                          elevation: 2,
                          shadowColor:
                              AppColors.electricBlue.withValues(alpha: 0.35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Save Profile',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 28),

              // ── 3. Travel Utilities (My Journey) ───────────────────────────
              _buildSectionHeader('My Journey'),
              const SizedBox(height: 12),
              _buildUtilityCard([
                _buildUtilityTile(
                  title: 'Past Trips',
                  icon: Icons.history_rounded,
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _buildUtilityTile(
                  title: 'Travel Preferences',
                  icon: Icons.tune_rounded,
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _buildUtilityTile(
                  title: 'Emergency Contacts',
                  icon: Icons.health_and_safety_rounded,
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56, endIndent: 16),
                _buildUtilityTile(
                  title: 'Saved Payment Methods',
                  icon: Icons.credit_card_rounded,
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 28),

              // ── 4. Support & Exit ───────────────────────────────────────────
              _buildSectionHeader('Support'),
              const SizedBox(height: 12),
              _buildUtilityCard([
                _buildUtilityTile(
                  title: 'Customer Care & Support',
                  icon: Icons.headset_mic_rounded,
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 32),

              // Log Out Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                  label: Text(
                    'Log Out',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(
                      color: Color(0xFFEF4444),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrophyBadge({
    required String title,
    required Color borderColor,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    return SizedBox(
      width: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Medal Container
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: 4,
              ),
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Trophy Label
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.darkCharcoal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.darkCharcoal,
        ),
      ),
    );
  }

  Widget _buildVitalTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.darkCharcoal,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.electricBlue,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildUtilityCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildUtilityTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.electricBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppColors.electricBlue,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.darkCharcoal,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Colors.grey,
        size: 22,
      ),
      onTap: onTap,
    );
  }
}
