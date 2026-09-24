import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final supabase = Supabase.instance.client;

  // Reactive variables
  final isLoading = false.obs;
  final otpSent = false.obs;
  final currentPhone = ''.obs;

  /// Sends an OTP to the provided [phone] number.
  Future<void> sendOtp(String phone) async {
    try {
      isLoading.value = true;
      currentPhone.value = phone;
      await supabase.auth.signInWithOtp(phone: phone);
      otpSent.value = true;
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Verifies the received [otp] for the stored phone number.
  /// On success, navigates to the home screen.
  Future<void> verifyOtp(String otp) async {
    try {
      isLoading.value = true;
      await supabase.auth.verifyOTP(
        type: OtpType.sms,
        token: otp,
        phone: currentPhone.value,
      );
      // Navigate to home on successful verification
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
