import 'package:get/get.dart';
import 'package:smacofit/app/modules/home/controllers/home_controller.dart';
import 'package:smacofit/app/modules/home/controllers/beranda_controller.dart';
import 'package:smacofit/app/modules/home/controllers/laporan_controller.dart';
import 'package:smacofit/app/modules/home/controllers/profil_controller.dart';
import 'package:smacofit/app/modules/nutrition/controllers/nutrition_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<BerandaController>(() => BerandaController());
    Get.lazyPut<LaporanController>(() => LaporanController());
    Get.lazyPut<ProfilController>(() => ProfilController());
    Get.put<NutritionController>(NutritionController());
  }
}

