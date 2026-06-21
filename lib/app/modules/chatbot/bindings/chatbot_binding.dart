import 'package:get/get.dart';
import 'package:smacofit/app/modules/chatbot/controllers/chatbot_controller.dart';

class ChatbotBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatbotController>(() => ChatbotController());
  }
}
