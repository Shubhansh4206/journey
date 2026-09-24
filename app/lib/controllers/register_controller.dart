import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

enum RegisterResult {
  sessionCreated, // Auto-confirmed / immediate login
  confirmationEmailSent, // Email confirmation required by Supabase
  failed,
}

class RegisterController extends GetxController {
  final AuthService _authService = AuthService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final rateLimitNotice = false.obs;
  final emailConfirmationNotice = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<RegisterResult> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final fullName = nameController.text.trim();

    // 1. Validation
    if (!GetUtils.isEmail(email)) {
      errorMessage.value = 'Please enter a valid email address';
      return RegisterResult.failed;
    }
    if (password.length < 6) {
      errorMessage.value = 'Password must be at least 6 characters';
      return RegisterResult.failed;
    }
    if (confirmPassword.isNotEmpty && password != confirmPassword) {
      errorMessage.value = 'Passwords do not match';
      return RegisterResult.failed;
    }

    // 2. Execute Registration
    isLoading.value = true;
    errorMessage.value = null;
    rateLimitNotice.value = false;
    emailConfirmationNotice.value = false;

    try {
      final response = await _authService.registerWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );

      // If Supabase has "Confirm email" disabled, it returns an active session
      if (response.session != null) {
        return RegisterResult.sessionCreated;
      }

      // If Supabase has "Confirm email" enabled, session is null, email was sent
      if (response.user != null) {
        emailConfirmationNotice.value = true;
        return RegisterResult.confirmationEmailSent;
      }

      return RegisterResult.failed;
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();

      if (msg.contains('rate limit') || e.statusCode == '429') {
        rateLimitNotice.value = true;
        errorMessage.value =
            'Email rate limit exceeded.\n\nSupabase allows only ~3-4 emails/hour on the free tier. To fix this:\n1. Open your Supabase Dashboard\n2. Go to Authentication > Providers > Email\n3. Turn OFF "Confirm email"\n\nThis will allow immediate sign-ups without hitting rate limits.';
      } else if (msg.contains('already registered') || msg.contains('user already exists')) {
        errorMessage.value = 'An account with this email already exists. Please log in.';
      } else {
        errorMessage.value = e.message;
      }
      return RegisterResult.failed;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred. Please try again.';
      return RegisterResult.failed;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final success = await _authService.signInWithGoogle();
      return success;
    } on AuthException catch (e) {
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      errorMessage.value = 'Google sign-in failed. Please verify Supabase OAuth settings.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}