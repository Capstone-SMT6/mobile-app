import 'package:get/get.dart';
import 'package:smacofit/app/modules/nutrition/controllers/nutrition_controller.dart';

class NutritionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NutritionController>(() => NutritionController());
  }
}
