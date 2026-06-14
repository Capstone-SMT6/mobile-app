import 'package:flutter/material.dart';

class FoodItem {
  final String id;
  final String name;
  final String category;
  final double caloriesPerServing;
  final double proteinPerServing;
  final double carbsPerServing;
  final double fatPerServing;
  final String servingUnit;
  final double? servingSizeG;
  final String? imageUrl;

  FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.caloriesPerServing,
    required this.proteinPerServing,
    required this.carbsPerServing,
    required this.fatPerServing,
    required this.servingUnit,
    this.servingSizeG,
    this.imageUrl,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    try {
      return FoodItem(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        caloriesPerServing: (json['calories_per_serving'] as num).toDouble(),
        proteinPerServing: (json['protein_per_serving'] as num).toDouble(),
        carbsPerServing: (json['carbs_per_serving'] as num).toDouble(),
        fatPerServing: (json['fat_per_serving'] as num).toDouble(),
        servingUnit: json['serving_unit'] as String? ?? 'porsi',
        servingSizeG: json['serving_size_g'] != null ? (json['serving_size_g'] as num).toDouble() : null,
        imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String?,
      );
    } catch (e) {
      debugPrint('DEBUG ERROR: FoodItem parsing failed. JSON: $json. Error: $e');
      rethrow;
    }
  }
}

class FoodLog {
  final String id;
  final String date;
  final String mealType;
  final double quantity;
  final double caloriesKcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final String? notes;
  final FoodItem foodItem;

  FoodLog({
    required this.id,
    required this.date,
    required this.mealType,
    required this.quantity,
    required this.caloriesKcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.notes,
    required this.foodItem,
  });

  factory FoodLog.fromJson(Map<String, dynamic> json) {
    try {
      return FoodLog(
        id: json['id'] as String,
        date: json['date'] as String,
        mealType: (json['meal_type'] ?? json['mealType'] ?? 'breakfast') as String,
        quantity: (json['quantity'] as num).toDouble(),

        caloriesKcal: (json['calories_kcal'] as num? ?? json['calories'] as num? ?? 0.0).toDouble(),
        proteinG: (json['protein_g'] as num? ?? json['protein'] as num? ?? 0.0).toDouble(),
        carbsG: (json['carbs_g'] as num? ?? json['carbs'] as num? ?? 0.0).toDouble(),
        fatG: (json['fat_g'] as num? ?? json['fat'] as num? ?? 0.0).toDouble(),
        notes: json['notes'] as String?,
        foodItem: FoodItem.fromJson(json['food_item'] as Map<String, dynamic>),
      );
    } catch (e) {
      debugPrint('DEBUG ERROR: FoodLog parsing failed. JSON: $json. Error: $e');
      rethrow;
    }
  }

  String get mealTypeFormatted {
    switch (mealType.toLowerCase()) {
      case 'breakfast': return 'Sarapan';
      case 'lunch': return 'Makan Siang';
      case 'dinner': return 'Makan Malam';
      case 'snack': return 'Camilan';
      default: return mealType;
    }
  }
}

class NutritionSummary {
  final String date;
  final double totalKcal;
  final double totalProteinG;
  final double totalCarbsG;
  final double totalFatG;
  final int entryCount;

  NutritionSummary({
    required this.date,
    required this.totalKcal,
    required this.totalProteinG,
    required this.totalCarbsG,
    required this.totalFatG,
    required this.entryCount,
  });

  factory NutritionSummary.fromJson(Map<String, dynamic> json) {
    try {
      return NutritionSummary(
        date: json['date'] as String,
        totalKcal: (json['total_kcal'] as num? ?? json['calories'] as num? ?? 0.0).toDouble(),
        totalProteinG: (json['total_protein_g'] as num? ?? json['protein'] as num? ?? 0.0).toDouble(),
        totalCarbsG: (json['total_carbs_g'] as num? ?? json['carbs'] as num? ?? 0.0).toDouble(),
        totalFatG: (json['total_fat_g'] as num? ?? json['fat'] as num? ?? 0.0).toDouble(),
        entryCount: json['entry_count'] as int? ?? json['entryCount'] as int? ?? 0,
      );
    } catch (e) {
      debugPrint('DEBUG ERROR: NutritionSummary parsing failed. JSON: $json. Error: $e');
      rethrow;
    }
  }
}

class MacroFeedbackItem {
  final String status;
  final double actual;
  final double target;

  MacroFeedbackItem({
    required this.status,
    required this.actual,
    required this.target,
  });

  factory MacroFeedbackItem.fromJson(Map<String, dynamic> json) {
    return MacroFeedbackItem(
      status: json['status'] as String? ?? 'on_target',
      actual: (json['actual'] as num? ?? 0.0).toDouble(),
      target: (json['target'] as num? ?? 0.0).toDouble(),
    );
  }
}

class NutritionFeedback {
  final String kcalStatus;
  final double kcalGap;
  final MacroFeedbackItem protein;
  final MacroFeedbackItem carbs;
  final MacroFeedbackItem fat;
  final List<String> recommendations;

  NutritionFeedback({
    required this.kcalStatus,
    required this.kcalGap,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.recommendations,
  });

  factory NutritionFeedback.fromJson(Map<String, dynamic> json) {
    try {
      final macros = json['macros'] as Map<String, dynamic>;
      return NutritionFeedback(
        kcalStatus: json['kcal_status'] as String? ?? 'on_target',
        kcalGap: (json['kcal_gap'] as num? ?? 0.0).toDouble(),
        protein: MacroFeedbackItem.fromJson(macros['protein'] as Map<String, dynamic>),
        carbs: MacroFeedbackItem.fromJson(macros['carbs'] as Map<String, dynamic>),
        fat: MacroFeedbackItem.fromJson(macros['fat'] as Map<String, dynamic>),
        recommendations: (json['recommendations'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      );
    } catch (e) {
      debugPrint('DEBUG ERROR: NutritionFeedback parsing failed. JSON: $json. Error: $e');
      rethrow;
    }
  }
}
