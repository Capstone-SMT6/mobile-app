import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/app/core/config/app_config.dart';
import 'package:mobile_app/app/data/models/nutrition_model.dart';
import 'auth_service.dart';

class NutritionService {
  static final _authService = AuthService();

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('User not logged in');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<FoodItem>> searchFoods(String? query, String? category) async {
    var uri = Uri.parse(AppConfig.nutritionFoodsEndpoint);
    
    // Add query parameters
    final params = <String, String>{};
    if (query != null && query.isNotEmpty) {
      params['q'] = query;
    }
    if (category != null && category.isNotEmpty) {
      params['category'] = category;
    }
    
    if (params.isNotEmpty) {
      uri = uri.replace(queryParameters: params);
    }

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((json) => FoodItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search foods: ${response.statusCode}');
    }
  }

  static Future<FoodLog> logFood({
    required String foodItemId,
    required double quantity,
    required String mealType,
    String? notes,
    String? date,
  }) async {
    final headers = await _getAuthHeaders();
    final body = {
      'food_item_id': foodItemId,
      'quantity': quantity,
      'meal_type': mealType,
      if (notes != null) 'notes': notes,
      if (date != null) 'date': date,
    };

    final response = await http.post(
      Uri.parse(AppConfig.nutritionLogEndpoint),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return FoodLog.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to log food: ${response.statusCode}');
    }
  }

  static Future<List<FoodLog>> getTodayLogs() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse(AppConfig.nutritionLogTodayEndpoint),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((json) => FoodLog.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch today\'s logs: ${response.statusCode}');
    }
  }

  static Future<List<FoodLog>> getLogsForDate(String dateStr) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse(AppConfig.nutritionLogDateEndpoint(dateStr)),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list.map((json) => FoodLog.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch logs for $dateStr: ${response.statusCode}');
    }
  }

  static Future<void> deleteLog(String entryId) async {
    final headers = await _getAuthHeaders();
    final response = await http.delete(
      Uri.parse('${AppConfig.nutritionLogEndpoint}/$entryId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete log entry: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getDaySummary(String dateStr) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse(AppConfig.nutritionSummaryDayEndpoint(dateStr)),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to fetch daily summary: ${response.statusCode}');
    }
  }

  static Future<List<dynamic>> getWeekSummary() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse(AppConfig.nutritionSummaryWeekEndpoint),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to fetch weekly summary: ${response.statusCode}');
    }
  }

  static Future<List<dynamic>> getMonthSummary() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse(AppConfig.nutritionSummaryMonthEndpoint),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to fetch monthly summary: ${response.statusCode}');
    }
  }

  static Future<NutritionFeedback> getDayFeedback(String dateStr) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse(AppConfig.nutritionFeedbackDayEndpoint(dateStr)),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return NutritionFeedback.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch feedback: ${response.statusCode}');
    }
  }
}
