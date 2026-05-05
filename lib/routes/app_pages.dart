import 'package:get/get.dart';
import '../auth/login_page.dart';
import '../auth/register_page.dart';
import '../homepage.dart';
import '../pages/chatbot_page.dart';
import '../pages/onboarding/onboarding_goal.dart';
import '../pages/onboarding/onboarding_gender.dart';
import '../pages/onboarding/onboarding_age.dart';
import '../pages/onboarding/onboarding_height.dart';
import '../pages/onboarding/onboarding_weight.dart';
import '../pages/onboarding/onboarding_expertise.dart';
import '../pages/onboarding/onboarding_intensity.dart';
import '../pages/onboarding/onboarding_kalori.dart';
import '../pages/onboarding/onboarding_result.dart';
import '../bindings/home_binding.dart';
import '../bindings/chatbot_binding.dart';
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
      name: AppRoutes.onboardingKalori,
      page: () => const OnboardingKaloriPage(),
      customTransition: _carousel,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.onboardingResult,
      page: () => const OnboardingResultPage(),
      customTransition: _carousel,
      transitionDuration: const Duration(milliseconds: 350),
    ),
  ];
}
