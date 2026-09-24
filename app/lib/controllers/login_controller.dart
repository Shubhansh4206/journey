import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final infoMessage = RxnString();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<bool> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (!GetUtils.isEmail(email)) {
      errorMessage.value = 'Please enter a valid email address';
      return false;
    }
    if (password.isEmpty) {
      errorMessage.value = 'Please enter your password';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = null;
    infoMessage.value = null;

    try {
      final res = await _authService.loginWithEmail(
        email: email,
        password: password,
      );

      if (res.user != null) {
        return true;
      }
      return false;
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('email not confirmed')) {
        errorMessage.value =
            'Email not verified yet. Please check your inbox for the confirmation link, or disable "Confirm email" in Supabase settings.';
      } else {
        errorMessage.value = e.message;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred. Please try again.';
      return false;
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

  Future<bool> sendPasswordReset(String email) async {
    final cleanEmail = email.trim();
    if (!GetUtils.isEmail(cleanEmail)) {
      Get.snackbar(
        'Invalid Email',
        'Please enter a valid email address to reset password.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      await _authService.sendPasswordReset(cleanEmail);
      Get.snackbar(
        'Email Sent',
        'Password reset link has been sent to $cleanEmail',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } on AuthException catch (e) {
      Get.snackbar(
        'Reset Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not send reset email. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }
  }
}