import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:powerhouse/core/config/supabase_config.dart';
import 'package:powerhouse/models/team_model.dart';
import 'package:uuid/uuid.dart';

class TeamService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final _uuid = const Uuid();

  // ========== CREATE TEAM ==========
  Future<TeamModel> createTeam({
    required String teamName,
    String? description,
    String? imageUrl,
  }) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) throw Exception('No user logged in');

      final teamId = _uuid.v4();

      // Create team
      await _supabase.from('teams').insert({
        'team_id': teamId,
        'team_name': teamName,
        'description': description,
        'image_url': imageUrl,
        'created_by': userId,
        'member_count': 1,
        'total_xp': 0,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Add creator as team leader
      await _supabase.from('team_members').insert({
        'team_id': teamId,
        'user_id': userId,
        'role': 'leader',
        'joined_at': DateTime.now().toIso8601String(),
      });

      return TeamModel(
        teamId: teamId,
        teamName: teamName,
        description: description,
        imageUrl: imageUrl,
        createdBy: userId,
        memberCount: 1,
        totalXp: 0,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Error creating team: $e');
      rethrow;
    }
  }

  // ========== JOIN TEAM ==========
  Future<void> joinTeam(String teamId) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) throw Exception('No user logged in');

      // Check if already a member to avoid duplicate key error
      final existingMember = await _supabase
          .from('team_members')
          .select()
          .eq('team_id', teamId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingMember != null) {
        // User is already a member, return gracefully
        return;
      }

      // Add user to team
      await _supabase.from('team_members').insert({
        'team_id': teamId,
        'user_id': userId,
        'role': 'member',
        'joined_at': DateTime.now().toIso8601String(),
      });

      // Increment member count
      await _supabase.rpc(
        'increment_team_member_count',
        params: {'team_id_param': teamId},
      );
    } catch (e) {
      print('Error joining team: $e');
      rethrow;
    }
  }

  // ========== LEAVE TEAM ==========
  Future<void> leaveTeam(String teamId) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) throw Exception('No user logged in');

      // Remove user from team
      await _supabase
          .from('team_members')
          .delete()
          .eq('team_id', teamId)
          .eq('user_id', userId);

      // Decrement member count
      await _supabase.rpc(
        'decrement_team_member_count',
        params: {'team_id_param': teamId},
      );
    } catch (e) {
      print('Error leaving team: $e');
      rethrow;
    }
  }

  // ========== GET USER'S TEAMS ==========
  Future<List<TeamModel>> getUserTeams() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return [];

      final response = await _supabase
          .from('team_members')
          .select('team_id, teams(*)')
          .eq('user_id', userId);

      return (response as List)
          .map((json) => TeamModel.fromJson(json['teams']))
          .toList();
    } catch (e) {
      print('Error getting user teams: $e');
      return [];
    }
  }

  // ========== GET ALL TEAMS ==========
  Future<List<TeamModel>> getAllTeams() async {
    try {
      final response = await _supabase
          .from('teams')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TeamModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting all teams: $e');
      return [];
    }
  }

  // ========== GET TEAM MEMBERS ==========
  Future<List<TeamMemberModel>> getTeamMembers(String teamId) async {
    try {
      final response = await _supabase
          .from('team_members')
          .select('*, users(username, profile_picture_url, xp_points)')
          .eq('team_id', teamId)
          .order('joined_at', ascending: true);

      return (response as List)
          .map((json) => TeamMemberModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting team members: $e');
      return [];
    }
  }

  // ========== GET TEAM LEADERBOARD ==========
  Future<List<Map<String, dynamic>>> getTeamLeaderboard() async {
    try {
      final response = await _supabase
          .from('teams')
          .select('team_id, team_name, image_url, total_xp, member_count')
          .order('total_xp', ascending: false)
          .limit(10);

      return (response as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error getting team leaderboard: $e');
      return [];
    }
  }

  // ========== START TEAM CHALLENGE ==========
  Future<void> startTeamChallenge({
    required String teamId,
    required String challengeId,
  }) async {
    try {
      final teamChallengeId = _uuid.v4();

      await _supabase.from('team_challenges').insert({
        'team_challenge_id': teamChallengeId,
        'team_id': teamId,
        'challenge_id': challengeId,
        'team_progress': 0,
        'status': 'In-Progress',
        'started_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error starting team challenge: $e');
      rethrow;
    }
  }

  // ========== GET TEAM CHALLENGES ==========
  Future<List<TeamChallengeModel>> getTeamChallenges(String teamId) async {
    try {
      final response = await _supabase
          .from('team_challenges')
          .select()
          .eq('team_id', teamId)
          .eq('status', 'In-Progress');

      return (response as List)
          .map((json) => TeamChallengeModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting team challenges: $e');
      return [];
    }
  }

  // ========== UPDATE TEAM CHALLENGE PROGRESS ==========
  Future<void> updateTeamChallengeProgress({
    required String teamChallengeId,
    required int progress,
  }) async {
    try {
      await _supabase
          .from('team_challenges')
          .update({'team_progress': progress})
          .eq('team_challenge_id', teamChallengeId);
    } catch (e) {
      print('Error updating team challenge progress: $e');
      rethrow;
    }
  }
}
