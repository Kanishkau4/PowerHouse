import 'package:powerhouse/core/config/supabase_config.dart';
import 'package:powerhouse/models/weight_history_model.dart';

class WeightHistoryService {
  final _supabase = SupabaseConfig.client;

  /// Add a new weight entry
  Future<void> addWeightEntry(double weight) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabase.from('weight_history').insert({
        'user_id': userId,
        'weight': weight,
        'recorded_at': DateTime.now().toIso8601String(),
      });

      // Also update current_weight in users table
      await _supabase
          .from('users')
          .update({
            'current_weight': weight,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      print('✅ Weight entry added: $weight kg');
    } catch (e) {
      print('❌ Error adding weight entry: $e');
      rethrow;
    }
  }

  /// Get weight history for the last N days
  Future<List<WeightHistoryModel>> getWeightHistory(int days) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final startDate = DateTime.now().subtract(Duration(days: days));

      final response = await _supabase
          .from('weight_history')
          .select()
          .eq('user_id', userId)
          .gte('recorded_at', startDate.toIso8601String())
          .order('recorded_at', ascending: true);

      final List<WeightHistoryModel> history = (response as List)
          .map((json) => WeightHistoryModel.fromJson(json))
          .toList();

      print('✅ Fetched ${history.length} weight entries');
      return history;
    } catch (e) {
      print('❌ Error fetching weight history: $e');
      return [];
    }
  }

  /// Check if user has logged weight today
  Future<bool> hasLoggedWeightToday() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('weight_history')
          .select()
          .eq('user_id', userId)
          .gte('recorded_at', startOfDay.toIso8601String())
          .lt('recorded_at', endOfDay.toIso8601String())
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      print('❌ Error checking today\'s weight: $e');
      return false;
    }
  }

  /// Get the latest weight entry
  Future<WeightHistoryModel?> getLatestWeight() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('weight_history')
          .select()
          .eq('user_id', userId)
          .order('recorded_at', ascending: false)
          .limit(1);

      if ((response as List).isEmpty) return null;

      return WeightHistoryModel.fromJson(response.first);
    } catch (e) {
      print('❌ Error fetching latest weight: $e');
      return null;
    }
  }

  /// Get all weight entries (for analytics)
  Future<List<WeightHistoryModel>> getAllWeightHistory() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('weight_history')
          .select()
          .eq('user_id', userId)
          .order('recorded_at', ascending: true);

      final List<WeightHistoryModel> history = (response as List)
          .map((json) => WeightHistoryModel.fromJson(json))
          .toList();

      return history;
    } catch (e) {
      print('❌ Error fetching all weight history: $e');
      return [];
    }
  }
}
