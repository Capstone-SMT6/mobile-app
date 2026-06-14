import 'package:get/get.dart';
import 'package:mobile_app/app/modules/nutrition/controllers/nutrition_controller.dart';

class NutritionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NutritionController>(() => NutritionController());
  }
}
