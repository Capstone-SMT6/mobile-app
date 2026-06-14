import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/app/data/models/nutrition_model.dart';
import 'package:mobile_app/app/data/services/nutrition_service.dart';

class NutritionController extends GetxController {
  final todayLogs = <FoodLog>[].obs;
  final selectedDateLogs = <FoodLog>[].obs;
  
  final todaySummary = Rxn<NutritionSummary>();
  final selectedDateSummary = Rxn<NutritionSummary>();
  
  final dayFeedback = Rxn<NutritionFeedback>();
  
  final isLoading = false.obs;
  
  final selectedDate = DateTime.now().obs;
  
  // Reporting state
  final selectedPeriod = 'day'.obs; // 'day' | 'week' | 'month'
  final weeklySummaries = <dynamic>[].obs;
  final monthlySummaries = <dynamic>[].obs;
  final reportLoading = false.obs;

  // Search/logging state
  final searchQuery = ''.obs;
  final selectedCategory = ''.obs; // '' | 'makanan' | 'minuman' | 'snack'
  final searchResults = <FoodItem>[].obs;
  final searchLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadTodayData();
  }

  String get formattedSelectedDate {
    return DateFormat('yyyy-MM-dd').format(selectedDate.value);
  }

  String get formattedSelectedDateDisplay {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(selectedDate.value.year, selectedDate.value.month, selectedDate.value.day);
    
    if (selected == today) {
      return 'Hari Ini';
    } else if (selected == today.subtract(const Duration(days: 1))) {
      return 'Kemarin';
    } else {
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(selectedDate.value);
    }
  }

  Future<void> loadTodayData() async {
    selectedDate.value = DateTime.now();
    await loadDateData(selectedDate.value);
  }

  Future<void> loadDateData(DateTime date) async {
    isLoading.value = true;
    selectedDate.value = date;
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    
    try {
      // Fetch logs
      final logs = await NutritionService.getLogsForDate(dateStr);
      selectedDateLogs.assignAll(logs);
      if (dateStr == DateFormat('yyyy-MM-dd').format(DateTime.now())) {
        todayLogs.assignAll(logs);
      }
      
      // Fetch daily summary
      try {
        final summaryRaw = await NutritionService.getDaySummary(dateStr);
        final actual = summaryRaw['actual'] as Map<String, dynamic>;
        
        // Mock a summary structure that parses with model
        final mockSummaryJson = {
          'date': dateStr,
          'total_kcal': actual['calories'],
          'total_protein_g': actual['protein'],
          'total_carbs_g': actual['carbs'],
          'total_fat_g': actual['fat'],
          'entry_count': logs.length,
        };
        
        final summaryParsed = NutritionSummary.fromJson(mockSummaryJson);
        selectedDateSummary.value = summaryParsed;
        if (dateStr == DateFormat('yyyy-MM-dd').format(DateTime.now())) {
          todaySummary.value = summaryParsed;
        }
      } catch (e) {
        selectedDateSummary.value = null;
        if (dateStr == DateFormat('yyyy-MM-dd').format(DateTime.now())) {
          todaySummary.value = null;
        }
      }

      // Fetch feedback
      try {
        final feedback = await NutritionService.getDayFeedback(dateStr);
        dayFeedback.value = feedback;
      } catch (e) {
        dayFeedback.value = null;
      }

    } catch (e) {
      debugPrint('Error loading date data: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat data nutrisi: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeDate(int daysOffset) async {
    final newDate = selectedDate.value.add(Duration(days: daysOffset));
    await loadDateData(newDate);
  }

  Future<void> deleteLogEntry(String id) async {
    try {
      await NutritionService.deleteLog(id);
      await loadDateData(selectedDate.value);
      Get.snackbar(
        'Sukses',
        'Makanan berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF67C23A),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus makanan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> logFoodItem({
    required String foodItemId,
    required double quantity,
    required String mealType,
    String? notes,
  }) async {
    isLoading.value = true;
    try {
      final dateStr = formattedSelectedDate;
      await NutritionService.logFood(
        foodItemId: foodItemId,
        quantity: quantity,
        mealType: mealType,
        notes: notes,
        date: dateStr,
      );
      await loadDateData(selectedDate.value);
      Get.back(); // Back to main nutrition view
      Get.snackbar(
        'Sukses',
        'Makanan berhasil dicatat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF67C23A),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mencatat makanan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logMultipleFoodItems({
    required Map<String, double> items,
    required String mealType,
  }) async {
    isLoading.value = true;
    try {
      final dateStr = formattedSelectedDate;
      await Future.wait(
        items.entries.map((entry) => NutritionService.logFood(
          foodItemId: entry.key,
          quantity: entry.value,
          mealType: mealType,
          date: dateStr,
        )),
      );
      await loadDateData(selectedDate.value);
      Get.back(); // Back to main nutrition view
      Get.snackbar(
        'Sukses',
        'Makanan berhasil dicatat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF67C23A),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mencatat makanan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchFoodItems(String query, String category) async {
    searchLoading.value = true;
    searchQuery.value = query;
    selectedCategory.value = category;
    
    try {
      final results = await NutritionService.searchFoods(query, category);
      searchResults.assignAll(results);
    } catch (e) {
      debugPrint('Error searching foods: $e');
    } finally {
      searchLoading.value = false;
    }
  }

  Future<void> loadReportData() async {
    reportLoading.value = true;
    try {
      if (selectedPeriod.value == 'week') {
        final data = await NutritionService.getWeekSummary();
        weeklySummaries.assignAll(data);
      } else if (selectedPeriod.value == 'month') {
        final data = await NutritionService.getMonthSummary();
        monthlySummaries.assignAll(data);
      }
    } catch (e) {
      debugPrint('Error loading report: $e');
    } finally {
      reportLoading.value = false;
    }
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    if (period != 'day') {
      loadReportData();
    }
  }
}
