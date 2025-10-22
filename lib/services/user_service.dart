import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:powerhouse/core/config/supabase_config.dart';
import 'package:powerhouse/models/user_model.dart';

class UserService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // ========== GET CURRENT USER PROFILE ==========
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return null;

      final response = await _supabase
          .from('users')
          .select()
          .eq('user_id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // ========== UPDATE USER PROFILE ==========
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) throw Exception('No user logged in');

      await _supabase
          .from('users')
          .update(updates)
          .eq('user_id', userId);
    } catch (e) {
      rethrow;
    }
  }

  // ========== ADD XP POINTS ==========
  Future<void> addXP(int points) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) throw Exception('No user logged in');

      // Get current XP
      final user = await getCurrentUserProfile();
      final newXP = (user?.xpPoints ?? 0) + points;
      final newLevel = _calculateLevel(newXP);

      await _supabase.from('users').update({
        'xp_points': newXP,
        'level': newLevel,
      }).eq('user_id', userId);
    } catch (e) {
      rethrow;
    }
  }

  // Calculate level based on XP (example: 100 XP per level)
  int _calculateLevel(int xp) {
    return (xp / 100).floor() + 1;
  }
}