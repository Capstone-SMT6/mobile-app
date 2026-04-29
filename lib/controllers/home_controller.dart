import 'package:get/get.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';

class HomeController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
  }
}
