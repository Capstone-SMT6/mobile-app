import 'package:get/get.dart';

class OnboardingController extends GetxController {
  // Reactive state fields
  final RxString goal = 'Pembentukan Otot'.obs;
  final RxString gender = 'Laki-laki'.obs;
  final RxInt age = 21.obs;
  final RxDouble height = 170.0.obs;
  final RxDouble weight = 65.0.obs;
  final RxString expertise = 'Pemula'.obs;
  final RxString intensity = 'Sedang'.obs;

  Future<void> submitOnboarding() async {
    // API submit logic
  }
}
