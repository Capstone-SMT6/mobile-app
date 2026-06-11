import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/auth_controller.dart';
import '../controllers/user_controller.dart';
import '../routes/app_routes.dart';
import '../services/user_service.dart';
import '../services/notification_service.dart';
import '../utils/snackbar_helper.dart';

class ProfilController extends GetxController {
  final RxBool notificationsEnabled = true.obs;
  final RxBool hapticEnabled = true.obs;

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    if (value) {
      const trainingDays = [1, 3, 5]; // Mon, Wed, Fri default
      NotificationService().scheduleWorkoutReminders(
        hour: 7,
        minute: 0,
        trainingDays: trainingDays,
      );
      NotificationService().scheduleRestDayMotivation(
        trainingDays: trainingDays,
      );
    } else {
      NotificationService().cancelAll();
    }
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
          showCustomSnackbar(
            title: 'Berhasil',
            message: 'Foto profil berhasil diperbarui',
            backgroundColor: Colors.green,
          );
        }
      }
    } catch (e) {
      showCustomSnackbar(
        title: 'Error',
        message: 'Gagal memperbarui foto profil',
        backgroundColor: Colors.red,
      );
      debugPrint('Error updating avatar: $e');
    }
  }

  Future<void> showChangePasswordDialog(BuildContext context) async {
    final currentPasswordController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final userController = Get.find<UserController>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161824),
          title: const Text('Ubah Password', style: TextStyle(color: Colors.white)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Password Lama',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF262A3D)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF4FFFB0)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan password lama Anda';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Password Baru',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF262A3D)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF4FFFB0)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan password baru';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Konfirmasi Password Baru',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF262A3D)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF4FFFB0)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi password baru';
                    }
                    if (value != passwordController.text) {
                      return 'Password tidak sama';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                debugPrint('DEBUG: Simpan password clicked');
                if (!formKey.currentState!.validate()) {
                  debugPrint('DEBUG: Password form validation failed');
                  return;
                }

                final user = userController.user.value;
                if (user == null) {
                  debugPrint('DEBUG: Cannot update password, current user is null');
                  showCustomSnackbar(
                    title: 'Error',
                    message: 'Data pengguna tidak ditemukan. Silakan login kembali.',
                    backgroundColor: Colors.red,
                  );
                  return;
                }

                try {
                  debugPrint('DEBUG: Calling changePassword');
                  await UserService.changePassword(
                    currentPasswordController.text,
                    passwordController.text,
                  );
                  Get.back();
                  showCustomSnackbar(
                    title: 'Berhasil',
                    message: 'Password berhasil diperbarui',
                    backgroundColor: Colors.green,
                  );
                } catch (e) {
                  debugPrint('DEBUG: Change password error: $e');
                  String errorMessage = e.toString().replaceAll('Exception: ', '');
                  showCustomSnackbar(
                    title: 'Gagal',
                    message: errorMessage,
                    backgroundColor: Colors.red,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FFFB0),
                foregroundColor: Colors.black,
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}
