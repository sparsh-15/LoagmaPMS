import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../router/app_router.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _focusNodes = List.generate(4, (_) => FocusNode());
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onOtpChanged(int index, String value) {
    if (value.length > 1) {
      value = value[value.length - 1];
      _controllers[index].text = value;
      _controllers[index].selection = TextSelection.collapsed(offset: 1);
    }
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  Future<void> _verify(AuthController auth) async {
    if (_otp.length != 4) {
      Get.snackbar(
        'Invalid OTP',
        'Please enter 4 digits',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2C2416),
        colorText: const Color(0xFFFFFBF0),
      );
      return;
    }
    if (auth.verifyOtp(_otp)) {
      await AuthController.setLoggedIn(true);
      Get.toNamed(AppRoutes.dashboard);
    } else {
      Get.snackbar(
        'Wrong OTP',
        'Please check and try again',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2C2416),
        colorText: const Color(0xFFFFFBF0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Verify OTP',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2C2416),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => Text(
                  'We sent a code to ${auth.mobile.value.isNotEmpty ? auth.mobile.value : "your number"}',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6B5D4A),
                    fontWeight: FontWeight.w500,
                  ),
                )),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (i) {
                    return SizedBox(
                      width: 56,
                      child: TextFormField(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C2416),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          filled: true,
                          fillColor: const Color(0xFFFFF8E7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE8D5A3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFB8860B), width: 2),
                          ),
                        ),
                        onChanged: (v) => _onOtpChanged(i, v),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _verify(auth),
                    child: const Text('Verify'),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Change number'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
