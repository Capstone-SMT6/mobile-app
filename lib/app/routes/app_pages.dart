import 'package:get/get.dart';
import 'package:mobile_app/app/modules/auth/views/login_view.dart';
import 'package:mobile_app/app/modules/auth/views/register_view.dart';
import 'package:mobile_app/app/modules/auth/views/otp_verification_view.dart';
import 'package:mobile_app/app/modules/auth/views/forgot_password_view.dart';
import 'package:mobile_app/app/modules/home/views/home_view.dart';
import 'package:mobile_app/app/modules/chatbot/views/chatbot_view.dart';
import 'package:mobile_app/app/modules/onboarding/views/onboarding_goal_view.dart';
import 'package:mobile_app/app/modules/onboarding/views/onboarding_gender_view.dart';
import 'package:mobile_app/app/modules/onboarding/views/onboarding_age_view.dart';
import 'package:mobile_app/app/modules/onboarding/views/onboarding_height_view.dart';
import 'package:mobile_app/app/modules/onboarding/views/onboarding_weight_view.dart';
import 'package:mobile_app/app/modules/onboarding/views/onboarding_expertise_view.dart';
import 'package:mobile_app/app/modules/onboarding/views/onboarding_intensity_view.dart';
import 'package:mobile_app/app/modules/onboarding/views/onboarding_days_view.dart';
import 'package:mobile_app/app/modules/onboarding/views/onboarding_result_view.dart';
import 'package:mobile_app/app/modules/home/bindings/home_binding.dart';
import 'package:mobile_app/app/modules/chatbot/bindings/chatbot_binding.dart';
import 'package:mobile_app/app/routes/app_routes.dart';
import 'package:mobile_app/app/routes/onboarding_transition.dart';

// Shared carousel transition instance reused across all onboarding pages.
final _carousel = OnboardingCarouselTransition();

abstract class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.login, page: () => const LoginView()),
    GetPage(name: AppRoutes.register, page: () => const RegisterView()),
    GetPage(
      name: AppRoutes.otpVerification,
      page: () => const OtpVerificationView(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.chatbot,
      page: () => const ChatbotView(),
      binding: ChatbotBinding(),
    ),
    GetPage(
      name: AppRoutes.onboardingGoal,
      page: () => const OnboardingGoalView(),
      customTransition: _carousel,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.onboardingGender,
      page: () => const OnboardingGenderView(),
      customTransition: _carousel,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.onboardingAge,
      page: () => const OnboardingAgeView(),
      customTransition: _carousel,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.onboardingHeight,
      page: () => const OnboardingHeightView(),
      customTransition: _carousel,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.onboardingWeight,
      page: () => const OnboardingWeightView(),
      customTransition: _carousel,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.onboardingExpertise,
      page: () => const OnboardingExpertiseView(),
      customTransition: _carousel,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.onboardingIntensity,
      page: () => const OnboardingIntensityView(),
      customTransition: _carousel,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.onboardingDays,
      page: () => const OnboardingDaysView(),
      customTransition: _carousel,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.onboardingResult,
      page: () => const OnboardingResultView(),
      customTransition: _carousel,
      transitionDuration: const Duration(milliseconds: 350),
    ),
  ];
}
