import 'package:get/get.dart';
import 'package:mobile_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:mobile_app/app/modules/auth/controllers/user_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<UserController>(() => UserController());
  }
}
