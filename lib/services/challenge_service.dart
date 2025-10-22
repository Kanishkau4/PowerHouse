import 'package:powerhouse/services/progress_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:powerhouse/core/config/supabase_config.dart';
import 'package:powerhouse/models/challenge_model.dart';
import 'package:powerhouse/models/user_challenge_model.dart';

class ChallengeService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final _progressService = ProgressService();

  // ========== GET ALL CHALLENGES ==========
  Future<List<ChallengeModel>> getAllChallenges() async {
    try {
      final response = await _supabase
          .from('challenges')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ChallengeModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting challenges: $e');
      return [];
    }
  }

  // ========== GET USER'S ACTIVE CHALLENGES ==========
  Future<List<UserChallengeModel>> getUserActiveChallenges() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return [];

      final response = await _supabase
          .from('user_challenges')
          .select('*, challenges(*)')
          .eq('user_id', userId)
          .eq('status', 'In-Progress');

      return (response as List)
          .map((json) => UserChallengeModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting user challenges: $e');
      return [];
    }
  }

  // ========== JOIN CHALLENGE (UPDATED WITH XP) ==========
  Future<Map<String, dynamic>> joinChallenge(String challengeId) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) throw Exception('No user logged in');

      await _supabase.from('user_challenges').insert({
        'user_id': userId,
        'challenge_id': challengeId,
        'progress': 0,
        'status': 'In-Progress',
        'started_at': DateTime.now().toIso8601String(),
      });

      // 🎯 AWARD XP FOR JOINING CHALLENGE
      final xpResult = await _progressService.awardChallengeJoinXP();

      return xpResult;
    } catch (e) {
      print('Error joining challenge: $e');
      rethrow;
    }
  }

  // ========== COMPLETE CHALLENGE (UPDATED WITH XP) ==========
  Future<Map<String, dynamic>> completeChallenge(String challengeId) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) throw Exception('No user logged in');

      await _supabase.from('user_challenges').update({
        'status': 'Completed',
        'completed_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId).eq('challenge_id', challengeId);

      // 🎯 AWARD XP FOR COMPLETING CHALLENGE
      final xpResult = await _progressService.awardChallengeCompleteXP();

      return xpResult;
    } catch (e) {
      print('Error completing challenge: $e');
      rethrow;
    }
  }

  // ========== UPDATE CHALLENGE PROGRESS ==========
  Future<void> updateChallengeProgress({
    required String challengeId,
    required int progress,
  }) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) throw Exception('No user logged in');

      await _supabase
          .from('user_challenges')
          .update({'progress': progress})
          .eq('user_id', userId)
          .eq('challenge_id', challengeId);
    } catch (e) {
      print('Error updating challenge progress: $e');
      rethrow;
    }
  }
}