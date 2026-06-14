$appDir = "c:\Users\Subandrio\Downloads\Capstone S6\renew\mobile-app\lib\app"

# Get all dart files under lib/app
$files = Get-ChildItem -Path $appDir -Filter "*.dart" -Recurse

$updatedCount = 0

foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    $original = $content

    # --- Import path replacements (ordered from most specific to least) ---

    # Config
    $content = $content.Replace("'../config.dart'", "'package:mobile_app/app/core/config/app_config.dart'")
    $content = $content.Replace("'../../config.dart'", "'package:mobile_app/app/core/config/app_config.dart'")
    $content = $content.Replace("'../../../config.dart'", "'package:mobile_app/app/core/config/app_config.dart'")
    $content = $content.Replace("'config.dart'", "'package:mobile_app/app/core/config/app_config.dart'")
    $content = $content.Replace("'package:mobile_app/config.dart'", "'package:mobile_app/app/core/config/app_config.dart'")

    # Colors
    $content = $content.Replace("'../utils/colors.dart'", "'package:mobile_app/app/core/theme/app_colors.dart'")
    $content = $content.Replace("'../../utils/colors.dart'", "'package:mobile_app/app/core/theme/app_colors.dart'")
    $content = $content.Replace("'../../../utils/colors.dart'", "'package:mobile_app/app/core/theme/app_colors.dart'")
    $content = $content.Replace("'package:mobile_app/utils/colors.dart'", "'package:mobile_app/app/core/theme/app_colors.dart'")

    # Snackbar helper
    $content = $content.Replace("'../utils/snackbar_helper.dart'", "'package:mobile_app/app/core/utils/snackbar_helper.dart'")
    $content = $content.Replace("'../../utils/snackbar_helper.dart'", "'package:mobile_app/app/core/utils/snackbar_helper.dart'")
    $content = $content.Replace("'../../../utils/snackbar_helper.dart'", "'package:mobile_app/app/core/utils/snackbar_helper.dart'")

    # Device diagnostics
    $content = $content.Replace("'../utils/device_diagnostics.dart'", "'package:mobile_app/app/core/utils/device_diagnostics.dart'")
    $content = $content.Replace("'../../utils/device_diagnostics.dart'", "'package:mobile_app/app/core/utils/device_diagnostics.dart'")

    # Memory profiler
    $content = $content.Replace("'../utils/memory_profiler.dart'", "'package:mobile_app/app/core/utils/memory_profiler.dart'")
    $content = $content.Replace("'../../utils/memory_profiler.dart'", "'package:mobile_app/app/core/utils/memory_profiler.dart'")

    # User model
    $content = $content.Replace("'../models/user_model.dart'", "'package:mobile_app/app/data/models/user_model.dart'")
    $content = $content.Replace("'../../models/user_model.dart'", "'package:mobile_app/app/data/models/user_model.dart'")
    $content = $content.Replace("'../../../models/user_model.dart'", "'package:mobile_app/app/data/models/user_model.dart'")

    # Services (all)
    $content = $content.Replace("'../services/auth_service.dart'", "'package:mobile_app/app/data/services/auth_service.dart'")
    $content = $content.Replace("'../../services/auth_service.dart'", "'package:mobile_app/app/data/services/auth_service.dart'")
    $content = $content.Replace("'../../../services/auth_service.dart'", "'package:mobile_app/app/data/services/auth_service.dart'")

    $content = $content.Replace("'../services/chatbot_service.dart'", "'package:mobile_app/app/data/services/chatbot_service.dart'")
    $content = $content.Replace("'../../services/chatbot_service.dart'", "'package:mobile_app/app/data/services/chatbot_service.dart'")

    $content = $content.Replace("'../services/notification_service.dart'", "'package:mobile_app/app/data/services/notification_service.dart'")
    $content = $content.Replace("'../../services/notification_service.dart'", "'package:mobile_app/app/data/services/notification_service.dart'")

    $content = $content.Replace("'../services/plan_service.dart'", "'package:mobile_app/app/data/services/plan_service.dart'")
    $content = $content.Replace("'../../services/plan_service.dart'", "'package:mobile_app/app/data/services/plan_service.dart'")

    $content = $content.Replace("'../services/pose_detector_service.dart'", "'package:mobile_app/app/data/services/pose_detector_service.dart'")
    $content = $content.Replace("'../../services/pose_detector_service.dart'", "'package:mobile_app/app/data/services/pose_detector_service.dart'")

    $content = $content.Replace("'../services/trends_service.dart'", "'package:mobile_app/app/data/services/trends_service.dart'")
    $content = $content.Replace("'../../services/trends_service.dart'", "'package:mobile_app/app/data/services/trends_service.dart'")

    $content = $content.Replace("'../services/user_service.dart'", "'package:mobile_app/app/data/services/user_service.dart'")
    $content = $content.Replace("'../../services/user_service.dart'", "'package:mobile_app/app/data/services/user_service.dart'")
    $content = $content.Replace("'../../../services/user_service.dart'", "'package:mobile_app/app/data/services/user_service.dart'")

    $content = $content.Replace("'../services/workout_service.dart'", "'package:mobile_app/app/data/services/workout_service.dart'")
    $content = $content.Replace("'../../services/workout_service.dart'", "'package:mobile_app/app/data/services/workout_service.dart'")

    # Controllers
    $content = $content.Replace("'../controllers/auth_controller.dart'", "'package:mobile_app/app/modules/auth/controllers/auth_controller.dart'")
    $content = $content.Replace("'../../controllers/auth_controller.dart'", "'package:mobile_app/app/modules/auth/controllers/auth_controller.dart'")
    $content = $content.Replace("'controllers/auth_controller.dart'", "'package:mobile_app/app/modules/auth/controllers/auth_controller.dart'")

    $content = $content.Replace("'../controllers/user_controller.dart'", "'package:mobile_app/app/modules/auth/controllers/user_controller.dart'")
    $content = $content.Replace("'../../controllers/user_controller.dart'", "'package:mobile_app/app/modules/auth/controllers/user_controller.dart'")
    $content = $content.Replace("'controllers/user_controller.dart'", "'package:mobile_app/app/modules/auth/controllers/user_controller.dart'")

    $content = $content.Replace("'../controllers/chatbot_controller.dart'", "'package:mobile_app/app/modules/chatbot/controllers/chatbot_controller.dart'")
    $content = $content.Replace("'../../controllers/chatbot_controller.dart'", "'package:mobile_app/app/modules/chatbot/controllers/chatbot_controller.dart'")

    $content = $content.Replace("'../controllers/home_controller.dart'", "'package:mobile_app/app/modules/home/controllers/home_controller.dart'")
    $content = $content.Replace("'../../controllers/home_controller.dart'", "'package:mobile_app/app/modules/home/controllers/home_controller.dart'")
    $content = $content.Replace("'controllers/home_controller.dart'", "'package:mobile_app/app/modules/home/controllers/home_controller.dart'")

    $content = $content.Replace("'../controllers/beranda_controller.dart'", "'package:mobile_app/app/modules/home/controllers/beranda_controller.dart'")
    $content = $content.Replace("'../../controllers/beranda_controller.dart'", "'package:mobile_app/app/modules/home/controllers/beranda_controller.dart'")

    $content = $content.Replace("'../controllers/laporan_controller.dart'", "'package:mobile_app/app/modules/home/controllers/laporan_controller.dart'")
    $content = $content.Replace("'../../controllers/laporan_controller.dart'", "'package:mobile_app/app/modules/home/controllers/laporan_controller.dart'")

    $content = $content.Replace("'../controllers/profil_controller.dart'", "'package:mobile_app/app/modules/home/controllers/profil_controller.dart'")
    $content = $content.Replace("'../../controllers/profil_controller.dart'", "'package:mobile_app/app/modules/home/controllers/profil_controller.dart'")

    $content = $content.Replace("'../controllers/onboarding_controller.dart'", "'package:mobile_app/app/modules/onboarding/controllers/onboarding_controller.dart'")
    $content = $content.Replace("'../../controllers/onboarding_controller.dart'", "'package:mobile_app/app/modules/onboarding/controllers/onboarding_controller.dart'")
    $content = $content.Replace("'controllers/onboarding_controller.dart'", "'package:mobile_app/app/modules/onboarding/controllers/onboarding_controller.dart'")

    # Routes
    $content = $content.Replace("'../routes/app_routes.dart'", "'package:mobile_app/app/routes/app_routes.dart'")
    $content = $content.Replace("'../../routes/app_routes.dart'", "'package:mobile_app/app/routes/app_routes.dart'")
    $content = $content.Replace("'../../../routes/app_routes.dart'", "'package:mobile_app/app/routes/app_routes.dart'")
    $content = $content.Replace("'routes/app_routes.dart'", "'package:mobile_app/app/routes/app_routes.dart'")

    # Pages -> Views references
    $content = $content.Replace("'pages/beranda_page.dart'", "'package:mobile_app/app/modules/home/views/beranda_view.dart'")
    $content = $content.Replace("'pages/laporan_page.dart'", "'package:mobile_app/app/modules/home/views/laporan_view.dart'")
    $content = $content.Replace("'pages/profil_page.dart'", "'package:mobile_app/app/modules/home/views/profil_view.dart'")
    $content = $content.Replace("'pages/exercise_list_page.dart'", "'package:mobile_app/app/modules/workout/views/exercise_list_view.dart'")
    $content = $content.Replace("'pages/calendar_page.dart'", "'package:mobile_app/app/modules/home/views/calendar_view.dart'")

    # Class renames (using regex for word boundaries)
    $renames = @(
        @('LoginPage', 'LoginView'),
        @('RegisterPage', 'RegisterView'),
        @('ForgotPasswordPage', 'ForgotPasswordView'),
        @('OtpVerificationPage', 'OtpVerificationView'),
        @('HomePage', 'HomeView'),
        @('BerandaPage', 'BerandaView'),
        @('LaporanPage', 'LaporanView'),
        @('ProfilPage', 'ProfilView'),
        @('CalendarPage', 'CalendarView'),
        @('ChatbotPage', 'ChatbotView'),
        @('OnboardingGoalPage', 'OnboardingGoalView'),
        @('OnboardingGenderPage', 'OnboardingGenderView'),
        @('OnboardingAgePage', 'OnboardingAgeView'),
        @('OnboardingHeightPage', 'OnboardingHeightView'),
        @('OnboardingWeightPage', 'OnboardingWeightView'),
        @('OnboardingExpertisePage', 'OnboardingExpertiseView'),
        @('OnboardingIntensityPage', 'OnboardingIntensityView'),
        @('OnboardingDaysPage', 'OnboardingDaysView'),
        @('OnboardingResultPage', 'OnboardingResultView'),
        @('ExerciseListPage', 'ExerciseListView'),
        @('WorkoutListPage', 'WorkoutListView'),
        @('WorkoutSessionPage', 'WorkoutSessionView'),
        @('WorkoutSummaryPage', 'WorkoutSummaryView'),
        @('WorkoutHistoryPage', 'WorkoutHistoryView'),
        @('WarmupPage', 'WarmupView'),
        @('CalibrationPage', 'CalibrationView'),
        @('PoseCameraPage', 'PoseCameraView'),
        @('AnalysisPage', 'AnalysisView')
    )

    foreach ($rename in $renames) {
        $pattern = "(?<![a-zA-Z0-9_])$($rename[0])(?![a-zA-Z0-9_])"
        $content = [regex]::Replace($content, $pattern, $rename[1])
    }

    if ($content -ne $original) {
        [System.IO.File]::WriteAllText($file.FullName, $content)
        $updatedCount++
        Write-Host "Updated: $($file.Name)"
    }
}

Write-Host "`nDone! Updated $updatedCount files."
