import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeController extends GetxController {
  final supabase = Supabase.instance.client;
  final RxInt selectedIndex = 0.obs;

  final RxString userName = 'User'.obs;
  final RxInt targetKalori = 2000.obs;
  final RxDouble beratBadan = 0.0.obs;
  final RxDouble tinggiBadan = 0.0.obs;
  final RxString bmiCategory = 'Normal'.obs;
  final RxDouble bmiValue = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  Future<void> fetchUserData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final data = await supabase
            .from('users')
            .select('nama, berat_badan, tinggi_badan, calculated_tdee')
            .eq('user_id', user.id)
            .single();

        userName.value = data['nama'] ?? 'User';
        beratBadan.value = (data['berat_badan'] as num?)?.toDouble() ?? 0.0;
        tinggiBadan.value = (data['tinggi_badan'] as num?)?.toDouble() ?? 0.0;
        targetKalori.value = data['calculated_tdee'] ?? 2000;

        if (tinggiBadan.value > 0 && beratBadan.value > 0) {
          double heightM = tinggiBadan.value / 100;
          bmiValue.value = beratBadan.value / (heightM * heightM);
          
          if (bmiValue.value < 18.5) {
            bmiCategory.value = 'Kurus';
          } else if (bmiValue.value < 25) {
            bmiCategory.value = 'Normal';
          } else if (bmiValue.value < 30) {
            bmiCategory.value = 'Gemuk';
          } else {
            bmiCategory.value = 'Obesitas';
          }
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }
}
