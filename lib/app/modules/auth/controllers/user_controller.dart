import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smacofit/app/data/models/user_model.dart';
import 'package:smacofit/app/data/services/user_service.dart';
import 'package:smacofit/app/data/services/notification_service.dart';

class UserController extends GetxController {
  static UserController get to => Get.find();

  final Rxn<User> user = Rxn<User>();
  final Rxn<UserStats> stats = Rxn<UserStats>();
  final Rxn<UserFitnessProfile> fitnessProfile = Rxn<UserFitnessProfile>();
  final Rxn<DashboardReport> dashboardReport = Rxn<DashboardReport>();
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

      // Request notification permissions and schedule reminders
      try {
        final ns = NotificationService();
        final granted = await ns.requestPermissions();
        if (granted) {
          await ns.scheduleDailyReminder();
        }
      } catch (e) {
        debugPrint('Failed to schedule notifications: $e');
      }

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

      // Fetch Dashboard Report
      try {
        final reportData = await UserService.getDashboardReport();
        dashboardReport.value = reportData;
      } catch (e) {
        dashboardReport.value = null;
        debugPrint('Dashboard report not found: $e');
      }
    } catch (e) {
      debugPrint('Error refreshing user data: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
