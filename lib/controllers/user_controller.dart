import 'package:flutter/material.dart';
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
      
      // Clear previous cached values first to prevent data leakage
      user.value = null;
      stats.value = null;
      fitnessProfile.value = null;
      
      // Fetch User Info
      final userData = await UserService.getCurrentUser();
      debugPrint('DEBUG: User Photo URL: ${userData.photoUrl}');
      user.value = userData;

      // Fetch Stats
      try {
        final statsData = await UserService.getUserStats();
        stats.value = statsData;
      } catch (e) {
        stats.value = null;
        debugPrint('Error fetching stats: $e');
      }

      // Fetch Fitness Profile
      try {
        final profileData = await UserService.getFitnessProfile();
        fitnessProfile.value = profileData;
      } catch (e) {
        fitnessProfile.value = null;
        debugPrint('Fitness profile not found: $e');
      }
    } catch (e) {
      debugPrint('Error refreshing user data: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
