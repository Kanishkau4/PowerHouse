import 'package:powerhouse/models/food_item_model.dart';

class FoodLogModel {
  final String logId;
  final String userId;
  final String foodId;
  final DateTime dateLogged;
  final String mealType; // 'Breakfast', 'Lunch', 'Dinner', 'Snack'
  final double quantity;
  final String servingUnit;
  final DateTime createdAt;
  
  // Populated from join
  final FoodItemModel? food;

  FoodLogModel({
    required this.logId,
    required this.userId,
    required this.foodId,
    required this.dateLogged,
    required this.mealType,
    required this.quantity,
    required this.servingUnit,
    required this.createdAt,
    this.food,
  });

  factory FoodLogModel.fromJson(Map<String, dynamic> json) {
    return FoodLogModel(
      logId: json['log_id'] as String,
      userId: json['user_id'] as String,
      foodId: json['food_id'] as String,
      dateLogged: DateTime.parse(json['date_logged']),
      mealType: json['meal_type'] as String,
      quantity: double.parse(json['quantity'].toString()),
      servingUnit: json['serving_unit'] as String,
      createdAt: DateTime.parse(json['created_at']),
      food: json['foods'] != null 
          ? FoodItemModel.fromJson(json['foods']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'food_id': foodId,
      'date_logged': dateLogged.toIso8601String(),
      'meal_type': mealType,
      'quantity': quantity,
      'serving_unit': servingUnit,
    };
  }

  // Helper: Calculate total calories for this log
  int get totalCalories {
    if (food == null) return 0;
    return (food!.calories * quantity).round();
  }

  // Helper: Calculate total protein
  double get totalProtein {
    if (food == null) return 0;
    return food!.protein * quantity;
  }

  // Helper: Calculate total carbs
  double get totalCarbs {
    if (food == null) return 0;
    return food!.carbs * quantity;
  }

  // Helper: Calculate total fat
  double get totalFat {
    if (food == null) return 0;
    return food!.fat * quantity;
  }
}