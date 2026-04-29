import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/auth_controller.dart';
import '../controllers/user_controller.dart';
import '../routes/app_routes.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class ProfilController extends GetxController {
  final RxBool notificationsEnabled = true.obs;
  final RxBool hapticEnabled = true.obs;

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    // Optional: Update on backend too
  }

  void toggleHaptic(bool value) {
    hapticEnabled.value = value;
  }

  Future<void> logout() async {
    final authController = Get.find<AuthController>();
    await authController.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> updateAvatar() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final userController = Get.find<UserController>();
        final user = userController.user.value;
        if (user != null) {
          final updatedUser = await UserService.uploadAvatar(user.id, image.path);
          userController.user.value = updatedUser;
          Get.snackbar('Berhasil', 'Foto profil berhasil diperbarui');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui foto profil');
      print('Error updating avatar: $e');
    }
  }
}
