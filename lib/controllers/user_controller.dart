import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserController extends GetxController {
  final Rxn<User> user = Rxn<User>();
  final Rxn<UserStats> stats = Rxn<UserStats>();
  final Rxn<UserFitnessProfile> fitnessProfile = Rxn<UserFitnessProfile>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> refreshData() async {
    try {
      isLoading.value = true;
      
      // Fetch User Info
      final userData = await UserService.getCurrentUser();
      print('DEBUG: User Photo URL: ${userData.photoUrl}');
      user.value = userData;

      // Fetch Stats
      try {
        final statsData = await UserService.getUserStats();
        stats.value = statsData;
      } catch (e) {
        print('Error fetching stats: $e');
      }

      // Fetch Fitness Profile
      try {
        final profileData = await UserService.getFitnessProfile();
        fitnessProfile.value = profileData;
      } catch (e) {
        print('Fitness profile not found: $e');
      }
    } catch (e) {
      print('Error refreshing user data: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
