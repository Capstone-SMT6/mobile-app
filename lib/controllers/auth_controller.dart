import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';
import '../config.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final RxBool isLoggedIn = false.obs;

  @override
  void onReady() {
    super.onReady();
    checkAuth();
  }

  Future<void> checkAuth() async {
    isLoggedIn.value = await _authService.isLoggedIn();
    if (isLoggedIn.value) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<String?> getToken() => _authService.getToken();
  Future<String?> getRefreshToken() => _authService.getRefreshToken();

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _authService.saveTokens(accessToken, refreshToken);
    isLoggedIn.value = true;
  }

  Future<void> logout() async {
    await _authService.deleteTokens();
    isLoggedIn.value = false;
    Get.offAllNamed(AppRoutes.login);
  }

  Future<bool> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      await logout();
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(AppConfig.refreshEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access_token'];
        if (newAccessToken != null) {
          await saveTokens(newAccessToken, refreshToken);
          return true;
        }
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
    }

    // Jika gagal me-refresh, paksa user untuk login kembali
    await logout();
    return false;
  }
}
