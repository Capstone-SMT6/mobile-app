import 'package:get/get.dart';
import '../auth/login_page.dart';
import '../auth/register_page.dart';
import '../homepage.dart';
import '../pages/chatbot_page.dart';
import '../bindings/home_binding.dart';
import '../bindings/chatbot_binding.dart';
import 'app_routes.dart';

abstract class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.chatbot,
      page: () => const ChatbotPage(),
      binding: ChatbotBinding(),
    ),
  ];
}
