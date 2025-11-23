import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:powerhouse/core/config/supabase_config.dart';
import 'package:powerhouse/services/badge_service.dart';
import 'package:powerhouse/models/badge_model.dart';

class ProgressService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final _badgeService = BadgeService();

  // XP rewards for different activities
  static const int XP_WORKOUT_COMPLETED = 50;
  static const int XP_FOOD_LOGGED = 10;
  static const int XP_CHALLENGE_JOINED = 20;
  static const int XP_CHALLENGE_COMPLETED = 100;
  static const int XP_DAILY_LOGIN = 5;
  static const int XP_STREAK_BONUS = 25; // Weekly streak

  // Level calculation: Level = floor(XP / 100) + 1
  // Level 1: 0-99 XP
  // Level 2: 100-199 XP
  // Level 3: 200-299 XP, etc.

  // ========== ADD XP ==========
  Future<Map<String, dynamic>> addXP(int points, {String? reason}) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) throw Exception('No user logged in');

      print('🎯 Adding $points XP for: $reason');

      // Get current user data
      final user = await _supabase
          .from('users')
          .select('xp_points, level')
          .eq('user_id', userId)
          .single();

      final currentXP = user['xp_points'] as int? ?? 0;
      final currentLevel = user['level'] as int? ?? 1;

      // Calculate new XP and level
      final newXP = currentXP + points;
      final newLevel = _calculateLevel(newXP);

      // Check if leveled up
      final leveledUp = newLevel > currentLevel;

      // Update database
      await _supabase
          .from('users')
          .update({
            'xp_points': newXP,
            'level': newLevel,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      print('✅ XP added! New XP: $newXP, New Level: $newLevel');

      // Award badges for milestones and return newly awarded badges
      final newBadges = await _checkAndAwardBadges(newXP, newLevel);

      return {
        'xp_added': points,
        'total_xp': newXP,
        'current_level': newLevel,
        'leveled_up': leveledUp,
        'previous_level': currentLevel,
        'new_badges': newBadges, // Include newly awarded badges
      };
    } catch (e) {
      print('❌ Error adding XP: $e');
      rethrow;
    }
  }

  // ========== CALCULATE LEVEL FROM XP ==========
  int _calculateLevel(int xp) {
    // Simple formula: 100 XP per level
    return (xp / 100).floor() + 1;
  }

  // ========== GET XP NEEDED FOR NEXT LEVEL ==========
  int getXPForNextLevel(int currentLevel) {
    return currentLevel * 100;
  }

  // ========== GET CURRENT LEVEL PROGRESS (0.0 to 1.0) ==========
  double getLevelProgress(int currentXP, int currentLevel) {
    final xpInCurrentLevel = currentXP % 100;
    final xpForNextLevel = 100;
    return xpInCurrentLevel / xpForNextLevel;
  }

  // ========== CHECK AND AWARD BADGES ==========
  Future<List<BadgeModel>> _checkAndAwardBadges(int totalXP, int level) async {
    final newBadges = <BadgeModel>[];
    try {
      // Award badges based on level milestones
      if (level == 5) {
        final badge = await _awardBadgeByName('First 5 Levels');
        if (badge != null) newBadges.add(badge);
      } else if (level == 10) {
        final badge = await _awardBadgeByName('Level 10 Warrior');
        if (badge != null) newBadges.add(badge);
      } else if (level == 20) {
        final badge = await _awardBadgeByName('Level 20 Champion');
        if (badge != null) newBadges.add(badge);
      }

      // Award badges based on XP milestones
      if (totalXP >= 1000) {
        final badge = await _awardBadgeByName('First 1000 XP');
        if (badge != null) newBadges.add(badge);
      }
      if (totalXP >= 5000) {
        final badge = await _awardBadgeByName('5000 XP Master');
        if (badge != null) newBadges.add(badge);
      }
    } catch (e) {
      print('Error checking badges: $e');
    }
    return newBadges;
  }

  // ========== AWARD BADGE BY NAME ==========
  Future<BadgeModel?> _awardBadgeByName(String badgeName) async {
    try {
      // Find badge by name
      final badges = await _supabase
          .from('badges')
          .select('badge_id')
          .eq('badge_name', badgeName)
          .maybeSingle();

      if (badges != null) {
        final badgeId = badges['badge_id'] as String;
        final badge = await _badgeService.awardBadge(badgeId);
        if (badge != null) {
          print('🏆 Badge awarded: $badgeName');
          return badge;
        }
      }
    } catch (e) {
      print('Error awarding badge: $e');
    }
    return null;
  }

  // ========== AWARD XP FOR SPECIFIC ACTIVITIES ==========

  Future<Map<String, dynamic>> awardWorkoutXP() async {
    return await addXP(XP_WORKOUT_COMPLETED, reason: 'Workout completed');
  }

  Future<Map<String, dynamic>> awardFoodLogXP() async {
    return await addXP(XP_FOOD_LOGGED, reason: 'Food logged');
  }

  Future<Map<String, dynamic>> awardChallengeJoinXP() async {
    return await addXP(XP_CHALLENGE_JOINED, reason: 'Challenge joined');
  }

  Future<Map<String, dynamic>> awardChallengeCompleteXP() async {
    return await addXP(XP_CHALLENGE_COMPLETED, reason: 'Challenge completed');
  }

  Future<Map<String, dynamic>> awardDailyLoginXP() async {
    return await addXP(XP_DAILY_LOGIN, reason: 'Daily login');
  }

  Future<Map<String, dynamic>> awardStreakBonusXP() async {
    return await addXP(XP_STREAK_BONUS, reason: 'Weekly streak bonus');
  }

  // ========== GET USER PROGRESS STATS ==========
  Future<Map<String, dynamic>> getUserProgressStats() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return {};

      final user = await _supabase
          .from('users')
          .select('xp_points, level')
          .eq('user_id', userId)
          .single();

      final xp = user['xp_points'] as int? ?? 0;
      final level = user['level'] as int? ?? 1;

      return {
        'total_xp': xp,
        'current_level': level,
        'xp_in_current_level': xp % 100,
        'xp_for_next_level': 100,
        'level_progress': getLevelProgress(xp, level),
      };
    } catch (e) {
      print('Error getting progress stats: $e');
      return {};
    }
  }
}
