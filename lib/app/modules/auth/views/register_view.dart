import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:mobile_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:mobile_app/app/core/config/app_config.dart';
import 'package:mobile_app/app/routes/app_routes.dart';
import 'package:mobile_app/app/core/utils/snackbar_helper.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authController = Get.find<AuthController>();
  final RxBool _isLoading = false.obs;
  final RxBool _obscurePassword = true.obs;
  final RxBool _obscureConfirmPassword = true.obs;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    _isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/users/otp/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'purpose': 'register',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showCustomSnackbar(
          title: 'OTP Terkirim',
          message: 'Silakan periksa email Anda untuk kode verifikasi.',
          backgroundColor: Colors.green,
        );
        Get.toNamed(
          AppRoutes.otpVerification,
          arguments: {
            'email': _emailController.text.trim(),
            'username': _nameController.text.trim(),
            'password': _passwordController.text,
            'purpose': 'register',
          },
        );
      } else {
        final error = jsonDecode(response.body);
        showCustomSnackbar(
          title: 'Gagal',
          message: error['detail'] ?? 'Registrasi gagal, email mungkin sudah dipakai',
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

  Future<void> _handleGoogleRegister() async {
    _isLoading.value = true;
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: GetPlatform.isAndroid ? null : AppConfig.googleClientId,
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final response = await http.post(
          Uri.parse(AppConfig.googleLoginEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': googleUser.email,
            'username': googleUser.displayName ?? 'Google User',
            'google_id': googleUser.id,
            'photo_url': googleUser.photoUrl,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final accessToken = data['access_token'];
          final refreshToken = data['refresh_token'];
          if (accessToken != null && refreshToken != null) {
            await _authController.saveTokens(accessToken, refreshToken);
          }
          showCustomSnackbar(
            title: 'Berhasil',
            message: 'Registrasi via Google berhasil!',
            backgroundColor: Colors.green,
          );
          Get.offAllNamed(AppRoutes.onboardingGoal);
        } else {
          showCustomSnackbar(
            title: 'Gagal',
            message: 'Server menolak registrasi Google',
            backgroundColor: Colors.red,
          );
        }
      }
    } catch (e) {
      showCustomSnackbar(
        title: 'Error Google Auth',
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
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen background image
          Image.asset(
            'assets/images/authBackground.jfif',
            fit: BoxFit.cover,
          ),

          // Content column
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),

                // ── Title over the background image ──
                Hero(
                  tag: 'auth_title',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'DAFTAR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              'Sma',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 46,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Fit',
                              style: TextStyle(
                                color: accentGreen,
                                fontSize: 46,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Hero(
                  tag: 'auth_form',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      decoration: const BoxDecoration(color: formBg),
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller: _nameController,
                              style: const TextStyle(color: textLight),
                              decoration: InputDecoration(
                                hintText: 'Masukkan Nama Pengguna',
                                hintStyle: const TextStyle(color: textHint),
                                filled: true,
                                fillColor: fieldBg,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: borderColor, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: borderColor, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: accentGreen, width: 1.5),
                                ),
                                errorStyle:
                                    const TextStyle(color: Colors.redAccent),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Masukkan nama pengguna Anda';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: textLight),
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'Masukkan Email',
                                hintStyle: const TextStyle(color: textHint),
                                filled: true,
                                fillColor: fieldBg,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: borderColor, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: borderColor, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: accentGreen, width: 1.5),
                                ),
                                errorStyle:
                                    const TextStyle(color: Colors.redAccent),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Masukkan email Anda';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                                    .hasMatch(value.trim())) {
                                  return 'Email tidak valid';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            Obx(() => TextFormField(
                                  controller: _passwordController,
                                  style: const TextStyle(color: textLight),
                                  obscureText: _obscurePassword.value,
                                  decoration: InputDecoration(
                                    hintText: 'Masukkan Password',
                                    hintStyle: const TextStyle(color: textHint),
                                    filled: true,
                                    fillColor: fieldBg,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 16),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: borderColor, width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: borderColor, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: accentGreen, width: 1.5),
                                    ),
                                    suffixIcon: GestureDetector(
                                      onTap: () => _obscurePassword.toggle(),
                                      child: Icon(
                                        _obscurePassword.value
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: textHint,
                                      ),
                                    ),
                                    errorStyle:
                                        const TextStyle(color: Colors.redAccent),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Masukkan password Anda';
                                    }
                                    if (value.length < 6) {
                                      return 'Password minimal 6 karakter';
                                    }
                                    return null;
                                  },
                                )),
                            const SizedBox(height: 12),
                            Obx(() => TextFormField(
                                  controller: _confirmPasswordController,
                                  style: const TextStyle(color: textLight),
                                  obscureText: _obscureConfirmPassword.value,
                                  decoration: InputDecoration(
                                    hintText: 'Konfirmasi Password',
                                    hintStyle: const TextStyle(color: textHint),
                                    filled: true,
                                    fillColor: fieldBg,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 16),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: borderColor, width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: borderColor, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: accentGreen, width: 1.5),
                                    ),
                                    suffixIcon: GestureDetector(
                                      onTap: () =>
                                          _obscureConfirmPassword.toggle(),
                                      child: Icon(
                                        _obscureConfirmPassword.value
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: textHint,
                                      ),
                                    ),
                                    errorStyle:
                                        const TextStyle(color: Colors.redAccent),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Konfirmasi password Anda';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Password tidak sama';
                                    }
                                    return null;
                                  },
                                )),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Lupa Password?',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Obx(() => SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _isLoading.value
                                        ? null
                                        : _handleRegister,
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
                                            'Daftar',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ),
                ),

                Hero(
                  tag: 'auth_google',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: Column(
                        children: [
                          const Text(
                            'Atau masuk menggunakan',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          Obx(() => SizedBox(
                                height: 52,
                                child: OutlinedButton(
                                  onPressed: _isLoading.value
                                      ? null
                                      : _handleGoogleRegister,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: Colors.white,
                                    side: BorderSide.none,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      FaIcon(FontAwesomeIcons.google,
                                          size: 18, color: Colors.red),
                                      SizedBox(width: 10),
                                      Text(
                                        'Google',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah punya akun? ',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () => Get.offAllNamed(AppRoutes.login),
                        child: const Text(
                          'Masuk disini',
                          style: TextStyle(
                            color: accentGreen,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
