import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingController extends GetxController {
  final supabase = Supabase.instance.client;

  // Onboarding data fields
  final RxString target = ''.obs;
  final RxString jenisKelamin = ''.obs;
  final RxInt usia = 0.obs;
  final RxDouble tinggiBadan = 0.0.obs;
  final RxDouble beratBadan = 0.0.obs;
  final RxString pengalamanFitness = ''.obs;
  final RxString tingkatAktivitas = ''.obs;
  final RxString ketersediaanAlat = ''.obs;

  final RxBool isSubmitting = false.obs;

  int _calculateTDEE() {
    double bmr;
    if (jenisKelamin.value == 'Pria') {
      bmr = 10 * beratBadan.value + 6.25 * tinggiBadan.value - 5 * usia.value + 5;
    } else {
      bmr = 10 * beratBadan.value + 6.25 * tinggiBadan.value - 5 * usia.value - 161;
    }

    double multiplier = 1.2;
    if (tingkatAktivitas.value == 'Rendah') multiplier = 1.375;
    else if (tingkatAktivitas.value == 'Sedang') multiplier = 1.55;
    else if (tingkatAktivitas.value == 'Tinggi') multiplier = 1.725;

    double tdee = bmr * multiplier;

    if (target.value == 'Bulking') {
      tdee += 300;
    } else if (target.value == 'Cutting/Fat Loss') {
      tdee -= 300;
    }

    return tdee.round();
  }

  Future<bool> submitOnboardingData() async {
    isSubmitting.value = true;
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User tidak ditemukan. Silakan login kembali.');
      }

      int tdee = _calculateTDEE();

      await supabase.from('users').update({
        'target': target.value,
        'jenis_kelamin': jenisKelamin.value,
        'usia': usia.value,
        'tinggi_badan': tinggiBadan.value,
        'berat_badan': beratBadan.value,
        'pengalaman_fitness': pengalamanFitness.value,
        'tingkat_aktivitas': tingkatAktivitas.value,
        'ketersediaan_alat': ketersediaanAlat.value,
        'calculated_tdee': tdee,
      }).eq('user_id', user.id);

      return true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan data: ${e.toString()}');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
