import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  var mobile = ''.obs;
  var isLoading = false.obs;

  final String masterOTP = "5555";

  static const _keyLoggedIn = 'auth_logged_in';

  /// Returns whether the user was previously logged in (persisted).
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  /// Persists login state. Call with true after OTP success, false on logout.
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, value);
  }

  void setMobile(String number) {
    mobile.value = number;
  }

  /// Only OTP "5555" is valid for verification.
  bool verifyOtp(String otp) {
    return otp == masterOTP;
  }

  void reset() {
    mobile.value = '';
    isLoading.value = false;
  }
}
