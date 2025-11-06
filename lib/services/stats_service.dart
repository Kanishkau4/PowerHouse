import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:powerhouse/core/config/supabase_config.dart';

class StatsService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // ========== GET TOTAL WORKOUTS COUNT ==========
  Future<int> getTotalWorkoutsCount() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return 0;

      final response = await _supabase
          .from('workout_logs')
          .select()
          .eq('user_id', userId)
          .count(CountOption.exact);

      // In newer versions of Supabase, the count is accessed via response.count
      return response.count ?? 0;
    } catch (e) {
      print('Error getting total workouts count: $e');
      return 0;
    }
  }

  // ========== GET TOTAL CALORIES BURNED ==========
  Future<int> getTotalCaloriesBurned() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return 0;

      final response = await _supabase
          .from('workout_logs')
          .select('calories_burned')
          .eq('user_id', userId);

      final List<dynamic> data = response as List<dynamic>;
      return data.fold<int>(0, (sum, item) {
        if (item is Map<String, dynamic> && item['calories_burned'] is int) {
          return sum + (item['calories_burned'] as int);
        }
        return sum;
      });
    } catch (e) {
      print('Error getting total calories burned: $e');
      return 0;
    }
  }

  // ========== GET TOTAL FOOD LOGS COUNT ==========
  Future<int> getTotalFoodLogsCount() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return 0;

      final response = await _supabase
          .from('food_logs')
          .select()
          .eq('user_id', userId)
          .count(CountOption.exact);

      return response.count ?? 0;
    } catch (e) {
      print('Error getting total food logs count: $e');
      return 0;
    }
  }

  // ========== GET TOTAL CHALLENGES COMPLETED ==========
  Future<int> getTotalChallengesCompleted() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return 0;

      final response = await _supabase
          .from('user_challenges')
          .select()
          .eq('user_id', userId)
          .eq('status', 'Completed')
          .count(CountOption.exact);

      return response.count ?? 0;
    } catch (e) {
      print('Error getting total challenges completed: $e');
      return 0;
    }
  }

  // ========== GET TOTAL XP EARNED ==========
  Future<int> getTotalXpEarned() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return 0;

      final response = await _supabase
          .from('users')
          .select('xp_points')
          .eq('user_id', userId)
          .single();
      
      // When using single(), the response is a Map<String, dynamic>
      final data = response;
      return data['xp_points'] as int? ?? 0;
    } catch (e) {
      print('Error getting total XP earned: $e');
      return 0;
    }
  }
}