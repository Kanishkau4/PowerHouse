import 'package:powerhouse/models/recipe_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:powerhouse/core/config/supabase_config.dart';
import 'package:powerhouse/models/food_item_model.dart';
import 'package:powerhouse/services/progress_service.dart';

class NutritionService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final _progressService = ProgressService();

  // ========== GET ALL FOODS ==========
  Future<List<FoodItemModel>> getAllFoods() async {
    try {
      final response = await _supabase
          .from('foods')
          .select()
          .order('food_name');

      return (response as List)
          .map((json) => FoodItemModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error getting foods: $e');
      return [];
    }
  }

  // ========== GET SRI LANKAN FOODS ==========
  Future<List<FoodItemModel>> getSriLankanFoods() async {
    try {
      final response = await _supabase
          .from('foods')
          .select()
          .eq('is_sri_lankan', true)
          .order('food_name');

      return (response as List)
          .map((json) => FoodItemModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error getting Sri Lankan foods: $e');
      return [];
    }
  }

  // ========== SEARCH FOODS ==========
  Future<List<FoodItemModel>> searchFoods(String query) async {
    try {
      final response = await _supabase
          .from('foods')
          .select()
          .ilike('food_name', '%$query%')
          .limit(20);

      return (response as List)
          .map((json) => FoodItemModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error searching foods: $e');
      return [];
    }
  }

  // ========== LOG FOOD ==========
  Future<Map<String, dynamic>> logFood({
    required String foodId,
    required String mealType,
    required double quantity,
    required String servingUnit,
    FoodItemModel? scannedFood, // Optional: for scanned foods
  }) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) throw Exception('No user logged in');

      print('💾 Logging food...');

      String actualFoodId = foodId;

      // If this is a scanned food (temporary ID), insert it into foods table first
      if (foodId.startsWith('scanned_') && scannedFood != null) {
        print('📸 Detected scanned food, inserting into database...');

        final insertedFood = await _supabase
            .from('foods')
            .insert({
              'food_name': scannedFood.foodName,
              'serving_size_description': scannedFood.servingSizeDescription,
              'calories': scannedFood.calories,
              'protein': scannedFood.protein,
              'carbs': scannedFood.carbs,
              'fat': scannedFood.fat,
              'is_sri_lankan': scannedFood.isSriLankan,
              'image_url': scannedFood.imageUrl,
            })
            .select('food_id')
            .single();

        actualFoodId = insertedFood['food_id'] as String;
        print('✅ Scanned food inserted with ID: $actualFoodId');
      }

      await _supabase.from('food_logs').insert({
        'user_id': userId,
        'food_id': actualFoodId,
        'meal_type': mealType,
        'quantity': quantity,
        'serving_unit': servingUnit,
        'date_logged': DateTime.now().toIso8601String(),
      });

      print('✅ Food logged successfully');

      // Award XP
      final xpResult = await _progressService.awardFoodLogXP();

      return xpResult;
    } catch (e) {
      print('❌ Error logging food: $e');
      rethrow;
    }
  }

  // ========== GET TODAY'S FOOD LOGS ==========
  Future<List<Map<String, dynamic>>> getTodayFoodLogs() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return [];

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('food_logs')
          .select('*, foods(*)')
          .eq('user_id', userId)
          .gte('date_logged', startOfDay.toIso8601String())
          .lt('date_logged', endOfDay.toIso8601String())
          .order('date_logged');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error getting food logs: $e');
      return [];
    }
  }

  // ========== GET FOOD LOGS BY DATE ==========
  Future<List<Map<String, dynamic>>> getFoodLogsByDate(DateTime date) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return [];

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('food_logs')
          .select('*, foods(*)')
          .eq('user_id', userId)
          .gte('date_logged', startOfDay.toIso8601String())
          .lt('date_logged', endOfDay.toIso8601String())
          .order('date_logged');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error getting food logs by date: $e');
      return [];
    }
  }

  // ========== DELETE FOOD LOG ==========
  Future<void> deleteFoodLog(String logId) async {
    try {
      await _supabase.from('food_logs').delete().eq('log_id', logId);

      print('✅ Food log deleted');
    } catch (e) {
      print('❌ Error deleting food log: $e');
      rethrow;
    }
  }

  // ========== GET NUTRITION STATS FOR DATE ==========
  Future<Map<String, dynamic>> getNutritionStatsForDate(DateTime date) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) {
        return {'calories': 0, 'protein': 0.0, 'carbs': 0.0, 'fat': 0.0};
      }

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('food_logs')
          .select('quantity, foods(calories, protein, carbs, fat)')
          .eq('user_id', userId)
          .gte('date_logged', startOfDay.toIso8601String())
          .lt('date_logged', endOfDay.toIso8601String());

      int totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;

      for (var log in response) {
        final quantity = (log['quantity'] as num).toDouble();
        final food = log['foods'];

        if (food != null) {
          totalCalories += ((food['calories'] as int) * quantity).round();
          totalProtein += ((food['protein'] as num).toDouble() * quantity);
          totalCarbs += ((food['carbs'] as num).toDouble() * quantity);
          totalFat += ((food['fat'] as num).toDouble() * quantity);
        }
      }

      return {
        'calories': totalCalories,
        'protein': totalProtein.round(),
        'carbs': totalCarbs.round(),
        'fat': totalFat.round(),
      };
    } catch (e) {
      print('❌ Error getting nutrition stats: $e');
      return {'calories': 0, 'protein': 0.0, 'carbs': 0.0, 'fat': 0.0};
    }
  }

  // Add these methods to the existing NutritionService class

  // ========== GET RECIPES ==========
  Future<List<RecipeModel>> getRecipes({int limit = 20}) async {
    try {
      final response = await _supabase
          .from('recipes')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => RecipeModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error getting recipes: $e');
      return [];
    }
  }

  // ========== GET SRI LANKAN RECIPES ==========
  Future<List<RecipeModel>> getSriLankanRecipes({int limit = 20}) async {
    try {
      final response = await _supabase
          .from('recipes')
          .select()
          .eq('is_sri_lankan', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => RecipeModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error getting Sri Lankan recipes: $e');
      return [];
    }
  }

  // ========== GET RECIPE BY ID ==========
  Future<RecipeModel?> getRecipeById(String recipeId) async {
    try {
      final response = await _supabase
          .from('recipes')
          .select()
          .eq('recipe_id', recipeId)
          .single();

      return RecipeModel.fromJson(response);
    } catch (e) {
      print('❌ Error getting recipe: $e');
      return null;
    }
  }
}
