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
  Future<BadgeModel?> awardBadge(String badgeId) async {
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
        return null;
      }

      // Award the badge
      await _supabase.from('user_badges').insert({
        'user_id': userId,
        'badge_id': badgeId,
        'date_earned': DateTime.now().toIso8601String(),
      });

      // Get the badge details to return
      final badgeResponse = await _supabase
          .from('badges')
          .select()
          .eq('badge_id', badgeId)
          .single();

      return BadgeModel.fromJson(badgeResponse);
    } catch (e) {
      print('Error awarding badge: $e');
      rethrow;
    }
  }

  // ========== CHECK AND AWARD BADGES BASED ON USER STATS ==========
  Future<List<BadgeModel>> checkAndAwardBadges() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return [];

      final newBadges = <BadgeModel>[];

      // Get user stats
      final userResponse = await _supabase
          .from('users')
          .select()
          .eq('user_id', userId)
          .single();

      final xpPoints = userResponse['xp_points'] as int? ?? 0;
      final level = userResponse['level'] as int? ?? 1;

      // Get workout count
      final workoutCount = await _getWorkoutCount();
      
      // Get total calories burned
      final totalCalories = await _getTotalCalories();

      // Check XP badges
      if (xpPoints >= 1000) {
        final badge = await _checkAndAwardBadgeByName('First 1000 XP');
        if (badge != null) newBadges.add(badge);
      }
      if (xpPoints >= 5000) {
        final badge = await _checkAndAwardBadgeByName('5000 XP Master');
        if (badge != null) newBadges.add(badge);
      }

      // Check Level badges
      if (level >= 5) {
        final badge = await _checkAndAwardBadgeByName('First 5 Levels');
        if (badge != null) newBadges.add(badge);
      }
      if (level >= 10) {
        final badge = await _checkAndAwardBadgeByName('Level 10 Warrior');
        if (badge != null) newBadges.add(badge);
      }
      if (level >= 20) {
        final badge = await _checkAndAwardBadgeByName('Level 20 Champion');
        if (badge != null) newBadges.add(badge);
      }

      // Check Workout badges
      if (workoutCount >= 50) {
        final badge = await _checkAndAwardBadgeByName('Workout Warrior');
        if (badge != null) newBadges.add(badge);
      }

      // Check Cardio badges
      final cardioCount = await _getCardioWorkoutCount();
      if (cardioCount >= 10) {
        final badge = await _checkAndAwardBadgeByName('Cardio King');
        if (badge != null) newBadges.add(badge);
      }

      return newBadges;
    } catch (e) {
      print('Error checking badges: $e');
      return [];
    }
  }

  // ========== HELPER: CHECK AND AWARD BADGE BY NAME ==========
  Future<BadgeModel?> _checkAndAwardBadgeByName(String badgeName) async {
    try {
      // Get badge by name
      final badgeResponse = await _supabase
          .from('badges')
          .select()
          .eq('badge_name', badgeName)
          .maybeSingle();

      if (badgeResponse == null) return null;

      final badgeId = badgeResponse['badge_id'] as String;

      // Check if user already has it
      final hasIt = await hasBadge(badgeId);
      if (hasIt) return null;

      // Award it
      return await awardBadge(badgeId);
    } catch (e) {
      print('Error checking badge by name: $e');
      return null;
    }
  }

  // ========== HELPER: GET WORKOUT COUNT ==========
  Future<int> _getWorkoutCount() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return 0;

      // ✅ FIXED: Just get the list and count it
      final response = await _supabase
          .from('workout_logs')
          .select('workout_id')
          .eq('user_id', userId);

      return (response as List).length;
    } catch (e) {
      print('Error getting workout count: $e');
      return 0;
    }
  }

  // ========== HELPER: GET CARDIO WORKOUT COUNT ==========
  Future<int> _getCardioWorkoutCount() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return 0;

      // ✅ FIXED: Just get the list and count it
      final response = await _supabase
          .from('workout_logs')
          .select('workout_id')
          .eq('user_id', userId)
          .eq('category', 'Cardio');

      return (response as List).length;
    } catch (e) {
      print('Error getting cardio count: $e');
      return 0;
    }
  }

  // ========== HELPER: GET TOTAL CALORIES ==========
  Future<int> _getTotalCalories() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return 0;

      final response = await _supabase
          .from('workout_logs')
          .select('calories_burned')
          .eq('user_id', userId);

      int total = 0;
      for (var log in (response as List)) {
        total += (log['calories_burned'] as int? ?? 0);
      }

      return total;
    } catch (e) {
      print('Error getting total calories: $e');
      return 0;
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