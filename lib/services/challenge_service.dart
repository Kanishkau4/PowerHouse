import 'package:powerhouse/services/progress_service.dart';
import 'package:powerhouse/services/health_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:powerhouse/core/config/supabase_config.dart';
import 'package:powerhouse/models/challenge_model.dart';
import 'package:powerhouse/models/user_challenge_model.dart';

class ChallengeService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final _progressService = ProgressService();
  final _healthService = HealthService();

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

  // ========== GET SPECIFIC USER CHALLENGE ==========
  Future<UserChallengeModel?> getUserChallenge(String challengeId) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return null;

      final response = await _supabase
          .from('user_challenges')
          .select('*, challenges(*)')
          .eq('user_id', userId)
          .eq('challenge_id', challengeId)
          .single();

      return UserChallengeModel.fromJson(response);
    } catch (e) {
      print('Error getting user challenge: $e');
      return null;
    }
  }

  // ========== JOIN CHALLENGE ==========
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

      final xpResult = await _progressService.awardChallengeJoinXP();
      return xpResult;
    } catch (e) {
      print('Error joining challenge: $e');
      rethrow;
    }
  }

  // ========== SYNC HEALTH DATA FOR CHALLENGE ==========
  Future<Map<String, dynamic>> syncHealthData(
    String challengeId,
    String unit,
  ) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) throw Exception('No user logged in');

      int newProgress = 0;

      // Get data based on challenge unit type
      switch (unit.toLowerCase()) {
        case 'steps':
          newProgress = await _healthService.getTodaySteps();
          break;
        case 'calories':
          newProgress = await _healthService.getTodayCalories();
          break;
        case 'km':
        case 'distance':
          double distance = await _healthService.getTodayDistance();
          newProgress = (distance / 1000).round(); // Convert meters to km
          break;
        default:
          // For workout-based challenges, just increment by 1
          final currentChallenge = await getUserChallenge(challengeId);
          newProgress = (currentChallenge?.progress ?? 0) + 1;
      }

      // Update challenge progress
      await updateChallengeProgress(
        challengeId: challengeId,
        progress: newProgress,
      );

      // Check if challenge is completed
      final userChallenge = await getUserChallenge(challengeId);
      if (userChallenge != null && userChallenge.challenge != null) {
        if (newProgress >= userChallenge.challenge!.targetValue) {
          final completeResult = await completeChallenge(challengeId);
          return {
            'success': true,
            'progress': newProgress,
            'completed': true,
            'xp_reward': userChallenge.challenge!.xpReward,
            'xp_added': completeResult['xp_added'],
          };
        }
      }

      return {'success': true, 'progress': newProgress, 'completed': false};
    } catch (e) {
      print('Error syncing health data: $e');
      rethrow;
    }
  }

  // ========== MANUAL PROGRESS UPDATE ==========
  Future<Map<String, dynamic>> manualProgressUpdate({
    required String challengeId,
    required int incrementValue,
  }) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) throw Exception('No user logged in');

      // Get current progress
      final userChallenge = await getUserChallenge(challengeId);
      if (userChallenge == null) throw Exception('Challenge not found');

      final newProgress = userChallenge.progress + incrementValue;

      // Update progress
      await updateChallengeProgress(
        challengeId: challengeId,
        progress: newProgress,
      );

      // Check if completed
      if (userChallenge.challenge != null &&
          newProgress >= userChallenge.challenge!.targetValue) {
        final completeResult = await completeChallenge(challengeId);
        return {
          'success': true,
          'progress': newProgress,
          'completed': true,
          'xp_added': completeResult['xp_added'],
        };
      }

      return {'success': true, 'progress': newProgress, 'completed': false};
    } catch (e) {
      print('Error manual progress update: $e');
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
          .update({
            'progress': progress,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('challenge_id', challengeId);
    } catch (e) {
      print('Error updating challenge progress: $e');
      rethrow;
    }
  }

  // ========== COMPLETE CHALLENGE ==========
  Future<Map<String, dynamic>> completeChallenge(String challengeId) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) throw Exception('No user logged in');

      await _supabase
          .from('user_challenges')
          .update({
            'status': 'Completed',
            'completed_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('challenge_id', challengeId);

      final xpResult = await _progressService.awardChallengeCompleteXP();
      return xpResult;
    } catch (e) {
      print('Error completing challenge: $e');
      rethrow;
    }
  }

  // ========== GET CHALLENGE LEADERBOARD ==========
  Future<List<Map<String, dynamic>>> getChallengeLeaderboard(
    String challengeId,
  ) async {
    try {
      final response = await _supabase
          .from('user_challenges')
          .select('user_id, progress, users(username, profile_picture_url)')
          .eq('challenge_id', challengeId)
          .order('progress', ascending: false)
          .limit(10);

      return (response as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error getting challenge leaderboard: $e');
      return [];
    }
  }

  // ========== GET GLOBAL XP LEADERBOARD ==========
  Future<List<Map<String, dynamic>>> getGlobalLeaderboard() async {
    try {
      print('🔍 Fetching global leaderboard...');
      print('🔍 Current user ID: ${SupabaseConfig.currentUserId}');

      final response = await _supabase
          .from('users')
          .select('user_id, username, profile_picture_url, xp_points, level')
          .order('xp_points', ascending: false)
          .limit(10);

      print('🏆 Leaderboard response: $response');
      print('🏆 Number of users fetched: ${(response as List).length}');

      // Print each user's data
      for (var i = 0; i < (response as List).length; i++) {
        final user = response[i];
        print(
          '🏆 User $i: ${user['username']} - ${user['xp_points']} XP (ID: ${user['user_id']})',
        );
      }

      return (response as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('❌ Error getting global leaderboard: $e');
      return [];
    }
  }
}
