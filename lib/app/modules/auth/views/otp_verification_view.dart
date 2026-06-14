import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/app/core/config/app_config.dart';
import 'package:mobile_app/app/routes/app_routes.dart';
import 'package:mobile_app/app/core/utils/snackbar_helper.dart';

class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({super.key});

  @override
  State<OtpVerificationView> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationView> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final RxBool _isLoading = false.obs;
  
  late final String _email;
  late final String _username;
  late final String _password;
  late final String _purpose;

  // Countdown timer logic
  final RxInt _resendCountdown = 60.obs;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    _email = args['email'] ?? '';
    _username = args['username'] ?? '';
    _password = args['password'] ?? '';
    _purpose = args['purpose'] ?? 'register';

    _startCountdown();
  }

  void _startCountdown() {
    _resendCountdown.value = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown.value > 0) {
        _resendCountdown.value--;
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleResendOTP() async {
    if (_resendCountdown.value > 0) return;

    _isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/users/otp/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _email,
          'purpose': _purpose,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showCustomSnackbar(
          title: 'Berhasil',
          message: 'Kode OTP baru telah dikirim.',
          backgroundColor: Colors.green,
        );
        _startCountdown();
      } else {
        showCustomSnackbar(
          title: 'Gagal',
          message: 'Gagal mengirim ulang OTP.',
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

  Future<void> _handleVerifyAndRegister() async {
    if (!_formKey.currentState!.validate()) return;

    _isLoading.value = true;
    try {
      // 1. Verify OTP code
      final verifyResponse = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/users/otp/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _email,
          'code': _otpController.text.trim(),
          'purpose': _purpose,
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

      // 2. Registration is authorized now, register user
      final registerResponse = await http.post(
        Uri.parse(AppConfig.usersEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _username,
          'email': _email,
          'password': _password,
        }),
      );

      if (registerResponse.statusCode == 200 || registerResponse.statusCode == 201) {
        showCustomSnackbar(
          title: 'Berhasil',
          message: 'Registrasi berhasil! Silahkan masuk.',
          backgroundColor: Colors.green,
        );
        Get.offAllNamed(AppRoutes.login);
      } else {
        showCustomSnackbar(
          title: 'Gagal',
          message: 'Terjadi kesalahan saat pendaftaran.',
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
                          'VERIFIKASI EMAIL',
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
                Hero(
                  tag: 'auth_form',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      decoration: const BoxDecoration(color: formBg),
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Kode verifikasi 6 digit telah dikirim ke:\n$_email',
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
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
                            const SizedBox(height: 20),
                            Obx(() => Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _resendCountdown.value > 0
                                          ? 'Kirim ulang OTP dalam ${_resendCountdown.value}s'
                                          : 'Tidak menerima kode? ',
                                      style: TextStyle(color: textHint, fontSize: 13),
                                    ),
                                    if (_resendCountdown.value == 0)
                                      GestureDetector(
                                        onTap: _isLoading.value ? null : _handleResendOTP,
                                        child: const Text(
                                          'Kirim Ulang',
                                          style: TextStyle(
                                            color: accentGreen,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                )),
                            const SizedBox(height: 24),
                            Obx(() => SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _isLoading.value ? null : _handleVerifyAndRegister,
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
                                            'Verifikasi',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
