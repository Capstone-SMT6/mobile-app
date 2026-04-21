import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';

class ProfilController extends GetxController {
  final RxBool notificationsEnabled = true.obs;
  final RxBool hapticEnabled = true.obs;

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
  }

  void toggleHaptic(bool value) {
    hapticEnabled.value = value;
  }

  Future<void> logout() async {
    final authController = Get.find<AuthController>();
    await authController.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}
