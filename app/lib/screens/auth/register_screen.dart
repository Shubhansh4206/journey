import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../common_widgets/widgets.dart';
import '../../controllers/register_controller.dart';
import '../../utils/colors.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final RegisterController controller = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Register heading and welcome message ─────────────────────
                  SizedBox(
                    width: size.width * 0.85,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Create Account',
                          style: GoogleFonts.poppins(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigoAccent,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Create an account so you can explore all the existing features',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── Rate Limit Notice Banner (Special Supabase Free-Tier Alert) ──
                  Obx(() {
                    if (!controller.rateLimitNotice.value) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFB45309),
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Supabase Email Rate Limit',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF92400E),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Supabase's default mailer is capped at ~3 confirmation emails/hour on free tier projects.\n\nQuick Fix in Supabase Dashboard:\n• Go to Authentication > Providers > Email\n• Turn OFF 'Confirm email'\n\nThis lets users register and sign in instantly without hitting email limits.",
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              color: const Color(0xFF78350F),
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // ── Email Confirmation Sent Banner ───────────────────────────
                  Obx(() {
                    if (!controller.emailConfirmationNotice.value) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA7F3D0), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.mark_email_read_outlined,
                                color: Color(0xFF047857),
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Verification Email Sent!',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF065F46),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please check your inbox (and spam folder) for the verification link. Once verified, you can sign in.',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFF065F46),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => context.go('/login'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF047857),
                                side: const BorderSide(color: Color(0xFF047857)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Go to Login',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // ── General Error Alert ──────────────────────────────────────
                  Obx(() {
                    final err = controller.errorMessage.value;
                    if (err == null || controller.rateLimitNotice.value) {
                      return const SizedBox.shrink();
                    }

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

                  // ── Form Fields ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomTextField(
                          label: 'Full Name',
                          controller: controller.nameController,
                          prefixIcon: Icons.person_outline_rounded,
                          hintText: 'John Doe',
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 18),
                        CustomTextField(
                          label: 'Email',
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          hintText: 'Enter your email',
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 18),
                        CustomTextField(
                          label: 'Password',
                          controller: controller.passwordController,
                          obscureText: true,
                          prefixIcon: Icons.lock_outline_rounded,
                          hintText: 'Minimum 6 characters',
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 18),
                        CustomTextField(
                          label: 'Confirm Password',
                          controller: controller.confirmPasswordController,
                          obscureText: true,
                          prefixIcon: Icons.lock_reset_rounded,
                          hintText: 'Re-enter password',
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Sign Up button ───────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () async {
                                  final result = await controller.register();
                                  if (result == RegisterResult.sessionCreated &&
                                      context.mounted) {
                                    context.go('/home');
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent,
                            disabledBackgroundColor:
                                Colors.indigoAccent.withValues(alpha: 0.6),
                            elevation: 4,
                            shadowColor: Colors.indigoAccent.withValues(alpha: 0.4),
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
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  'Sign up',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        )),
                  ),

                  const SizedBox(height: 24),

                  // ── Already have an account link ─────────────────────────────
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      'Already have an account',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── Or continue with ─────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.indigoAccent.withValues(alpha: 0.25),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Or continue with',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigoAccent,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.indigoAccent.withValues(alpha: 0.25),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Sign in with Google button ───────────────────────────────
                  IconButton(
                    onPressed: () async {
                      final success = await controller.signInWithGoogle();
                      if (success && context.mounted) {
                        context.go('/home');
                      }
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.google,
                      color: Colors.white,
                      size: 26,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      padding: const EdgeInsets.all(16),
                      elevation: 3,
                      shadowColor: (Colors.yellow[700] ?? Colors.orange)
                          .withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
