import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../config.dart';
import '../routes/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = Get.find<AuthController>();
  final RxBool _isLoading = false.obs;
  final RxBool _obscurePassword = true.obs;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    _isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse(AppConfig.loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        if (token != null) {
          await _authController.saveToken(token);
        }
        Get.snackbar('Success', 'Login successful!',
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.snackbar('Login Failed', 'Invalid email or password',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Network Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _handleGoogleLogin() async {
    _isLoading.value = true;
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: AppConfig.googleClientId,
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
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final token = data['access_token'];
          if (token != null) {
            await _authController.saveToken(token);
          }
          Get.snackbar('Success', 'Google Login successful!',
              backgroundColor: Colors.green, colorText: Colors.white);
          Get.offAllNamed(AppRoutes.home);
        } else {
          Get.snackbar('Failed', 'Server rejected Google Login',
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar('Google Auth Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentGreen = Color(0xFF5AC837);
    const darkBg = Color(0xFF1A1A1A);
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
                          'MASUK',
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

                // ── Form container (only form + forgot password + main button) ──
                Hero(
                  tag: 'auth_form',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: formBg,
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Email field
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
    
                            // Password field
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
    
                            // Forgot password
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
                                  style:
                                      TextStyle(color: Colors.white, fontSize: 13),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
    
                            // Main action button
                            Obx(() => SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed:
                                        _isLoading.value ? null : _handleLogin,
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
                                            'Masuk',
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

                // ── Google section ──
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
    
                          // Google button
                          Obx(() => SizedBox(
                                height: 52,
                                child: OutlinedButton(
                                  onPressed:
                                      _isLoading.value ? null : _handleGoogleLogin,
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

                // ── Outside container: nav link ──
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Belum punya akun? ',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () => Get.offAllNamed(AppRoutes.register),
                        child: const Text(
                          'Daftar disini',
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
