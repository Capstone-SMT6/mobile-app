import 'package:get/get.dart';

class BerandaController extends GetxController {
  final RxInt selectedChip = 0.obs;

  final List<String> chips = ['All', 'Strength', 'Cardio', 'Flexibility'];

  void selectChip(int index) {
    selectedChip.value = index;
  }
}
