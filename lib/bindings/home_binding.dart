import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/beranda_controller.dart';
import '../controllers/laporan_controller.dart';
import '../controllers/profil_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<BerandaController>(() => BerandaController());
    Get.lazyPut<LaporanController>(() => LaporanController());
    Get.lazyPut<ProfilController>(() => ProfilController());
  }
}
