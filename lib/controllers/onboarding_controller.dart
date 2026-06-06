import 'package:get/get.dart';
import '../services/user_service.dart';

class OnboardingController extends GetxController {
  final RxString goal = 'membentuk_otot'.obs;
  final RxString gender = 'pria'.obs;
  final RxInt age = 21.obs;
  final RxDouble height = 170.0.obs;
  final RxDouble weight = 65.0.obs;
  final RxString skillLevel = 'pemula'.obs;
  final RxString intensity = 'sedang'.obs;
  final RxList<String> selectedDays = <String>[].obs;
  final RxBool isSubmitting = false.obs;

  int get requiredTrainingDays {
    switch (intensity.value) {
      case 'rendah':
        return 3;
      case 'sedang':
        return 4;
      case 'tinggi':
        return 5;
      default:
        return 4;
    }
  }

  bool get hasValidSelectedDays {
    if (intensity.value == 'tinggi') {
      return selectedDays.length == 5 || selectedDays.length == 6;
    }
    return selectedDays.length == requiredTrainingDays;
  }

  Map<String, dynamic> toPayload() {
    return {
      'goal': goal.value,
      'gender': gender.value,
      'age': age.value,
      'height': height.value,
      'weight': weight.value,
      'skill_level': skillLevel.value,
      'intensity': intensity.value,
      'selected_days': selectedDays.toList(),
    };
  }

  Future<void> submitOnboarding() async {
    isSubmitting.value = true;
    try {
      await UserService.submitOnboarding(toPayload());
    } finally {
      isSubmitting.value = false;
    }
  }
}
