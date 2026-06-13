import os
import re
import shutil

# Root directory of the mobile app
root_dir = r"c:\Users\Subandrio\Downloads\Capstone S6\renew\mobile-app"
lib_dir = os.path.join(root_dir, "lib")

moves = {
    # 1. Models and Services
    "models/user_model.dart": "app/data/models/user_model.dart",
    "services/auth_service.dart": "app/data/services/auth_service.dart",
    "services/chatbot_service.dart": "app/data/services/chatbot_service.dart",
    "services/notification_service.dart": "app/data/services/notification_service.dart",
    "services/plan_service.dart": "app/data/services/plan_service.dart",
    "services/pose_detector_service.dart": "app/data/services/pose_detector_service.dart",
    "services/trends_service.dart": "app/data/services/trends_service.dart",
    "services/user_service.dart": "app/data/services/user_service.dart",
    "services/workout_service.dart": "app/data/services/workout_service.dart",

    # 2. Utils
    "utils/colors.dart": "app/utils/colors.dart",
    "utils/device_diagnostics.dart": "app/utils/device_diagnostics.dart",
    "utils/memory_profiler.dart": "app/utils/memory_profiler.dart",
    "utils/snackbar_helper.dart": "app/utils/snackbar_helper.dart",

    # 3. Routes
    "routes/app_pages.dart": "app/routes/app_pages.dart",
    "routes/app_routes.dart": "app/routes/app_routes.dart",
    "routes/onboarding_transition.dart": "app/routes/onboarding_transition.dart",

    # 4. Auth Module
    "controllers/auth_controller.dart": "app/modules/auth/controllers/auth_controller.dart",
    "controllers/user_controller.dart": "app/modules/auth/controllers/user_controller.dart",
    "pages/auth/login_page.dart": "app/modules/auth/views/login_view.dart",
    "pages/auth/register_page.dart": "app/modules/auth/views/register_view.dart",
    "pages/auth/forgot_password_page.dart": "app/modules/auth/views/forgot_password_view.dart",
    "pages/auth/otp_verification_page.dart": "app/modules/auth/views/otp_verification_view.dart",

    # 5. Chatbot Module
    "bindings/chatbot_binding.dart": "app/modules/chatbot/bindings/chatbot_binding.dart",
    "controllers/chatbot_controller.dart": "app/modules/chatbot/controllers/chatbot_controller.dart",
    "pages/chatbot_page.dart": "app/modules/chatbot/views/chatbot_view.dart",

    # 6. Home Module
    "bindings/home_binding.dart": "app/modules/home/bindings/home_binding.dart",
    "controllers/home_controller.dart": "app/modules/home/controllers/home_controller.dart",
    "controllers/beranda_controller.dart": "app/modules/home/controllers/beranda_controller.dart",
    "controllers/laporan_controller.dart": "app/modules/home/controllers/laporan_controller.dart",
    "controllers/profil_controller.dart": "app/modules/home/controllers/profil_controller.dart",
    "homepage.dart": "app/modules/home/views/home_view.dart",
    "pages/beranda_page.dart": "app/modules/home/views/beranda_view.dart",
    "pages/laporan_page.dart": "app/modules/home/views/laporan_view.dart",
    "pages/profil_page.dart": "app/modules/home/views/profil_view.dart",
    "pages/calendar_page.dart": "app/modules/home/views/calendar_view.dart",

    # 7. Onboarding Module
    "controllers/onboarding_controller.dart": "app/modules/onboarding/controllers/onboarding_controller.dart",
    "pages/onboarding/onboarding_age.dart": "app/modules/onboarding/views/onboarding_age_view.dart",
    "pages/onboarding/onboarding_days.dart": "app/modules/onboarding/views/onboarding_days_view.dart",
    "pages/onboarding/onboarding_expertise.dart": "app/modules/onboarding/views/onboarding_expertise_view.dart",
    "pages/onboarding/onboarding_gender.dart": "app/modules/onboarding/views/onboarding_gender_view.dart",
    "pages/onboarding/onboarding_goal.dart": "app/modules/onboarding/views/onboarding_goal_view.dart",
    "pages/onboarding/onboarding_height.dart": "app/modules/onboarding/views/onboarding_height_view.dart",
    "pages/onboarding/onboarding_intensity.dart": "app/modules/onboarding/views/onboarding_intensity_view.dart",
    "pages/onboarding/onboarding_result.dart": "app/modules/onboarding/views/onboarding_result_view.dart",
    "pages/onboarding/onboarding_weight.dart": "app/modules/onboarding/views/onboarding_weight_view.dart",

    # 8. Workout Module
    "pages/exercise_list_page.dart": "app/modules/workout/views/exercise_list_view.dart",
    "pages/workout_list_page.dart": "app/modules/workout/views/workout_list_view.dart",
    "pages/workout_session_page.dart": "app/modules/workout/views/workout_session_view.dart",
    "pages/workout_summary_page.dart": "app/modules/workout/views/workout_summary_view.dart",
    "pages/workout_history_page.dart": "app/modules/workout/views/workout_history_view.dart",
    "pages/warmup_page.dart": "app/modules/workout/views/warmup_view.dart",
    "pages/calibration_page.dart": "app/modules/workout/views/calibration_view.dart",
    "pages/pose_camera_page.dart": "app/modules/workout/views/pose_camera_view.dart",
    "pages/analysis_page.dart": "app/modules/workout/views/analysis_view.dart",
}

class_renames = {
    # Auth
    r"\bLoginPage\b": "LoginView",
    r"\bRegisterPage\b": "RegisterView",
    r"\bForgotPasswordPage\b": "ForgotPasswordView",
    r"\bOtpVerificationPage\b": "OtpVerificationView",
    
    # Home
    r"\bHomePage\b": "HomeView",
    r"\bBerandaPage\b": "BerandaView",
    r"\bLaporanPage\b": "LaporanView",
    r"\bProfilPage\b": "ProfilView",
    r"\bCalendarPage\b": "CalendarView",

    # Chatbot
    r"\bChatbotPage\b": "ChatbotView",

    # Onboarding
    r"\bOnboardingGoalPage\b": "OnboardingGoalView",
    r"\bOnboardingGenderPage\b": "OnboardingGenderView",
    r"\bOnboardingAgePage\b": "OnboardingAgeView",
    r"\bOnboardingHeightPage\b": "OnboardingHeightView",
    r"\bOnboardingWeightPage\b": "OnboardingWeightView",
    r"\bOnboardingExpertisePage\b": "OnboardingExpertiseView",
    r"\bOnboardingIntensityPage\b": "OnboardingIntensityView",
    r"\bOnboardingDaysPage\b": "OnboardingDaysView",
    r"\bOnboardingResultPage\b": "OnboardingResultView",

    # Workout
    r"\bExerciseListPage\b": "ExerciseListView",
    r"\bWorkoutListPage\b": "WorkoutListView",
    r"\bWorkoutSessionPage\b": "WorkoutSessionView",
    r"\bWorkoutSummaryPage\b": "WorkoutSummaryView",
    r"\bWorkoutHistoryPage\b": "WorkoutHistoryView",
    r"\bWarmupPage\b": "WarmupView",
    r"\bCalibrationPage\b": "CalibrationView",
    r"\bPoseCameraPage\b": "PoseCameraView",
    r"\bAnalysisPage\b": "AnalysisView",
}

def main():
    print("Starting restructuring script...")

    # Create inverse mapping to find old relative paths
    reverse_moves = {v: k for k, v in moves.items()}

    # Perform moves
    for old, new in moves.items():
        old_abs = os.path.join(lib_dir, old.replace("/", os.sep))
        new_abs = os.path.join(lib_dir, new.replace("/", os.sep))

        if os.path.exists(old_abs):
            print(f"Moving: {old} -> {new}")
            os.makedirs(os.path.dirname(new_abs), exist_ok=True)
            shutil.move(old_abs, new_abs)
        else:
            print(f"Warning: Source file not found: {old_abs}")

    # Process all dart files in lib recursively
    print("Updating imports and class names...")
    import_regex = re.compile(r"""(import\s+['"])([^'"]+)(['"]\s*(?:as\s+\w+)?\s*(?:show\s+[^;]+)?\s*(?:hide\s+[^;]+)?\s*;)""")

    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if not file.endswith(".dart"):
                continue

            file_abs = os.path.join(root, file)
            # Find its new relative path to lib/
            new_rel = os.path.relpath(file_abs, lib_dir).replace("\\", "/")

            # Find its old relative path to lib/
            old_rel = reverse_moves.get(new_rel, new_rel)

            with open(file_abs, "r", encoding="utf-8") as f:
                content = f.read()

            # Replace imports
            def replace_import(match):
                g1 = match.group(1)
                import_path = match.group(2)
                g3 = match.group(3)

                # Skip if external or dart SDK
                if import_path.startswith("dart:") or (import_path.startswith("package:") and not import_path.startswith("package:mobile_app/")):
                    return match.group(0)

                # Resolve to old relative target in lib/
                if import_path.startswith("package:mobile_app/"):
                    old_target = import_path[len("package:mobile_app/"):]
                else:
                    # Relative import
                    old_dir = os.path.dirname(old_rel)
                    old_target = os.path.normpath(os.path.join(old_dir, import_path)).replace("\\", "/")

                # Map to new target in lib/
                new_target = moves.get(old_target, old_target)

                # Construct new package-based import
                new_import = f"{g1}package:mobile_app/{new_target}{g3}"
                return new_import

            new_content = import_regex.sub(replace_import, content)

            # Rename classes
            for old_class, new_class in class_renames.items():
                new_content = re.sub(old_class, new_class, new_content)

            # Save modified file
            if new_content != content:
                with open(file_abs, "w", encoding="utf-8") as f:
                    f.write(new_content)
                print(f"Updated: {new_rel}")

    # Clean up empty directories
    print("Cleaning up empty directories...")
    for root, dirs, files in os.walk(lib_dir, topdown=False):
        for d in dirs:
            dir_path = os.path.join(root, d)
            # Check if directory is empty or only contains other empty directories
            try:
                if not os.listdir(dir_path):
                    os.rmdir(dir_path)
                    print(f"Removed empty directory: {os.path.relpath(dir_path, lib_dir)}")
            except Exception as e:
                print(f"Error removing {dir_path}: {e}")

    print("Restructuring completed successfully!")

if __name__ == "__main__":
    main()
