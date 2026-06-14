import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/firebase_options.dart';
import 'package:mobile_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:mobile_app/app/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:mobile_app/app/modules/auth/controllers/user_controller.dart';
import 'package:mobile_app/app/routes/app_pages.dart';
import 'package:mobile_app/app/routes/app_routes.dart';
import 'package:mobile_app/app/data/services/notification_service.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Register Controllers permanently so they're available app-wide
  Get.put(AuthController(), permanent: true);
  Get.put(UserController(), permanent: true);
  Get.put(OnboardingController(), permanent: true);
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Smart Coach',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4FFFB0),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: const Color(0xFFE8EAF2), displayColor: Colors.white),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.login,
      getPages: AppPages.pages,
    );
  }
}
