import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  final RxBool isLoggedIn = false.obs;

  @override
  void onReady() {
    super.onReady();
    // Listen to authentication state changes automatically provided by Supabase
    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      
      isLoggedIn.value = session != null;
      
      // Navigate based on auth state
      if (event == AuthChangeEvent.signedIn) {
        // You can check if the user is new here to redirect to Onboarding
        Get.offAllNamed(AppRoutes.home);
      } else if (event == AuthChangeEvent.signedOut) {
        Get.offAllNamed(AppRoutes.login);
      }
    });
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}
