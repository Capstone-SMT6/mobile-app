import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../config.dart';
import '../../routes/app_routes.dart';
import '../../utils/snackbar_helper.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyReset = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final RxBool _isLoading = false.obs;
  final RxInt _currentStep = 1.obs; // 1 = input email, 2 = input OTP & new password
  final RxBool _obscurePassword = true.obs;
  final RxBool _obscureConfirmPassword = true.obs;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOTP() async {
    if (!_formKeyEmail.currentState!.validate()) return;

    _isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/users/otp/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'purpose': 'reset_password',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showCustomSnackbar(
          title: 'Berhasil',
          message: 'Kode OTP telah dikirim ke email Anda.',
          backgroundColor: Colors.green,
        );
        _currentStep.value = 2;
      } else {
        final error = jsonDecode(response.body);
        showCustomSnackbar(
          title: 'Gagal',
          message: error['detail'] ?? 'Gagal mengirim OTP. Pastikan email terdaftar.',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      showCustomSnackbar(
        title: 'Error Jaringan',
        message: e.toString(),
        backgroundColor: Colors.red,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _handleResetPassword() async {
    if (!_formKeyReset.currentState!.validate()) return;

    _isLoading.value = true;
    try {
      // 1. Verify OTP first
      final verifyResponse = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/users/otp/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'code': _otpController.text.trim(),
          'purpose': 'reset_password',
        }),
      );

      if (verifyResponse.statusCode != 200) {
        final error = jsonDecode(verifyResponse.body);
        showCustomSnackbar(
          title: 'Gagal Verifikasi',
          message: error['detail'] ?? 'Kode OTP salah atau kedaluwarsa.',
          backgroundColor: Colors.red,
        );
        _isLoading.value = false;
        return;
      }

      // 2. Perform Reset Password
      final resetResponse = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/users/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      if (resetResponse.statusCode == 200) {
        showCustomSnackbar(
          title: 'Berhasil',
          message: 'Password Anda berhasil diatur ulang. Silakan masuk.',
          backgroundColor: Colors.green,
        );
        Get.offAllNamed(AppRoutes.login);
      } else {
        showCustomSnackbar(
          title: 'Gagal',
          message: 'Terjadi kesalahan saat mengatur ulang password.',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      showCustomSnackbar(
        title: 'Error Jaringan',
        message: e.toString(),
        backgroundColor: Colors.red,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentGreen = Color(0xFF5AC837);
    const formBg = Color(0xFF242424);
    const fieldBg = Color(0xFF2E2E2E);
    const textLight = Colors.white;
    const textHint = Color(0xFF888888);
    const borderColor = Color(0xFF3A3A3A);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/authBackground.jfif',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ),
                const Spacer(),
                Hero(
                  tag: 'auth_title',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'RESET PASSWORD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3,
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Obx(() => Hero(
                      tag: 'auth_form',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Container(
                          decoration: const BoxDecoration(color: formBg),
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                          child: _currentStep.value == 1
                              ? _buildStepEmail(accentGreen, fieldBg, textLight, textHint, borderColor)
                              : _buildStepReset(accentGreen, fieldBg, textLight, textHint, borderColor),
                        ),
                      ),
                    )),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepEmail(
    Color accentGreen,
    Color fieldBg,
    Color textLight,
    Color textHint,
    Color borderColor,
  ) {
    return Form(
      key: _formKeyEmail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Masukkan email Anda untuk mendapatkan kode OTP reset password.',
            style: TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            style: TextStyle(color: textLight),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Masukkan Email',
              hintStyle: TextStyle(color: textHint),
              filled: true,
              fillColor: fieldBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: accentGreen, width: 1.5),
              ),
              errorStyle: const TextStyle(color: Colors.redAccent),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Masukkan email Anda';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim())) {
                return 'Email tidak valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading.value ? null : _handleSendOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading.value
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Kirim OTP',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepReset(
    Color accentGreen,
    Color fieldBg,
    Color textLight,
    Color textHint,
    Color borderColor,
  ) {
    return Form(
      key: _formKeyReset,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Kode OTP dikirim ke ${_emailController.text}',
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Single field for OTP
          TextFormField(
            controller: _otpController,
            style: TextStyle(
              color: textLight,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              counterText: '',
              hintText: 'OTP CODE',
              hintStyle: TextStyle(color: textHint, fontSize: 16, letterSpacing: 0),
              filled: true,
              fillColor: fieldBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: accentGreen, width: 1.5),
              ),
              errorStyle: const TextStyle(color: Colors.redAccent),
            ),
            validator: (value) {
              if (value == null || value.trim().length != 6) {
                return 'Masukkan 6 digit kode OTP';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            style: TextStyle(color: textLight),
            obscureText: _obscurePassword.value,
            decoration: InputDecoration(
              hintText: 'Password Baru',
              hintStyle: TextStyle(color: textHint),
              filled: true,
              fillColor: fieldBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: accentGreen, width: 1.5),
              ),
              suffixIcon: GestureDetector(
                onTap: () => _obscurePassword.toggle(),
                child: Icon(
                  _obscurePassword.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: textHint,
                ),
              ),
              errorStyle: const TextStyle(color: Colors.redAccent),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Masukkan password baru Anda';
              }
              if (value.length < 6) {
                return 'Password minimal 6 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmPasswordController,
            style: TextStyle(color: textLight),
            obscureText: _obscureConfirmPassword.value,
            decoration: InputDecoration(
              hintText: 'Konfirmasi Password Baru',
              hintStyle: TextStyle(color: textHint),
              filled: true,
              fillColor: fieldBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: accentGreen, width: 1.5),
              ),
              suffixIcon: GestureDetector(
                onTap: () => _obscureConfirmPassword.toggle(),
                child: Icon(
                  _obscureConfirmPassword.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: textHint,
                ),
              ),
              errorStyle: const TextStyle(color: Colors.redAccent),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Konfirmasi password baru Anda';
              }
              if (value != _passwordController.text) {
                return 'Password tidak sama';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading.value ? null : _handleResetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading.value
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Reset Password',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
