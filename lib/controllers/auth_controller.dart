import 'package:get/get.dart';
import '../auth/auth_service.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
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

  Future<void> saveToken(String token) async {
    await _authService.saveToken(token);
    isLoggedIn.value = true;
  }

  Future<void> logout() async {
    await _authService.deleteToken();
    isLoggedIn.value = false;
    Get.offAllNamed(AppRoutes.login);
  }
}
