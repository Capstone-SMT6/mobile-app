import 'package:get/get.dart';
import 'package:mobile_app/app/modules/chatbot/controllers/chatbot_controller.dart';

class ChatbotBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatbotController>(() => ChatbotController());
  }
}
