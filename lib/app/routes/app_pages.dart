import 'package:get/get.dart';
import '../modules/auth/views/login_page.dart';
import '../modules/auth/views/register_page.dart';
import '../modules/home/views/homepage.dart';
import '../modules/chatbot/views/chatbot_page.dart';
import '../modules/onboarding/views/onboarding_goal.dart';
import '../modules/onboarding/views/onboarding_gender.dart';
import '../modules/onboarding/views/onboarding_age.dart';
import '../modules/onboarding/views/onboarding_height.dart';
import '../modules/onboarding/views/onboarding_weight.dart';
import '../modules/onboarding/views/onboarding_expertise.dart';
import '../modules/onboarding/views/onboarding_intensity.dart';
import '../modules/onboarding/views/onboarding_equipment.dart';

import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_result.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/chatbot/bindings/chatbot_binding.dart';
import '../modules/pose_detection/views/pose_detection_view.dart';
import '../modules/pose_detection/bindings/pose_detection_binding.dart';
import 'app_routes.dart';
import 'onboarding_transition.dart';

// Shared carousel transition instance reused across all onboarding pages.
final _carousel = OnboardingCarouselTransition();

abstract class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.chatbot,
      page: () => const ChatbotPage(),
      binding: ChatbotBinding(),
    ),
    GetPage(
      name: AppRoutes.onboardingGoal,
      page: () => const OnboardingGoalPage(),
      binding: OnboardingBinding(),
      customTransition: _carousel,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.onboardingGender,
      page: () => const OnboardingGenderPage(),
      customTransition: _carousel,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.onboardingAge,
      page: () => const OnboardingAgePage(),
      customTransition: _carousel,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.onboardingHeight,
      page: () => const OnboardingHeightPage(),
      customTransition: _carousel,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.onboardingWeight,
      page: () => const OnboardingWeightPage(),
      customTransition: _carousel,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.onboardingExpertise,
      page: () => const OnboardingExpertisePage(),
      customTransition: _carousel,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.onboardingIntensity,
      page: () => const OnboardingIntensityPage(),
      customTransition: _carousel,
      transitionDuration: const Duration(milliseconds: 350),
    ),

    GetPage(
      name: AppRoutes.onboardingEquipment,
      page: () => const OnboardingEquipmentPage(),
      customTransition: _carousel,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.onboardingResult,
      page: () => const OnboardingResultPage(),
      customTransition: _carousel,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.poseDetection,
      page: () => const PoseDetectionView(),
      binding: PoseDetectionBinding(),
    ),
  ];
}
