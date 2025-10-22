import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:powerhouse/core/config/supabase_config.dart';
import 'package:powerhouse/models/badge_model.dart';
import 'package:powerhouse/models/user_badge_model.dart';

class BadgeService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // ========== GET ALL BADGES ==========
  Future<List<BadgeModel>> getAllBadges() async {
    try {
      final response = await _supabase
          .from('badges')
          .select()
          .order('badge_name');

      return (response as List)
          .map((json) => BadgeModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting badges: $e');
      return [];
    }
  }

  // ========== GET USER'S BADGES ==========
  Future<List<UserBadgeModel>> getUserBadges() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return [];

      final response = await _supabase
          .from('user_badges')
          .select('*, badges(*)')
          .eq('user_id', userId)
          .order('date_earned', ascending: false);

      return (response as List)
          .map((json) => UserBadgeModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting user badges: $e');
      return [];
    }
  }

  // ========== AWARD BADGE ==========
  Future<void> awardBadge(String badgeId) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) throw Exception('No user logged in');

      // Check if already has badge
      final existing = await _supabase
          .from('user_badges')
          .select()
          .eq('user_id', userId)
          .eq('badge_id', badgeId)
          .maybeSingle();

      if (existing != null) {
        print('User already has this badge');
        return;
      }

      await _supabase.from('user_badges').insert({
        'user_id': userId,
        'badge_id': badgeId,
        'date_earned': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error awarding badge: $e');
      rethrow;
    }
  }

  // ========== CHECK IF USER HAS BADGE ==========
  Future<bool> hasBadge(String badgeId) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return false;

      final response = await _supabase
          .from('user_badges')
          .select()
          .eq('user_id', userId)
          .eq('badge_id', badgeId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking badge: $e');
      return false;
    }
  }
}