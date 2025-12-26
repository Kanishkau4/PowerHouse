import 'dart:io';
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

      await _supabase.from('users').update(updates).eq('user_id', userId);
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

      await _supabase
          .from('users')
          .update({'xp_points': newXP, 'level': newLevel})
          .eq('user_id', userId);
    } catch (e) {
      rethrow;
    }
  }

  // Calculate level based on XP (example: 100 XP per level)
  int _calculateLevel(int xp) {
    return (xp / 100).floor() + 1;
  }

  // ========== GET LEADERBOARD USERS ==========
  Future<List<UserModel>> getLeaderboardUsers([int limit = 10]) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .neq('username', 'Admin') // Exclude admin users
          .order('xp_points', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting leaderboard users: $e');
      return [];
    }
  }

  // ========== UPLOAD PROFILE PICTURE ==========
  Future<String> uploadProfilePicture(File imageFile) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) throw Exception('No user logged in');

      // Create a unique file name
      final fileExt = imageFile.path.split('.').last;
      final fileName =
          '$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'profile_pictures/$fileName';

      // Upload to Supabase Storage
      await _supabase.storage
          .from('avatars')
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Get public URL
      final publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

      // Update user profile with new URL
      await _supabase
          .from('users')
          .update({
            'profile_picture_url': publicUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      return publicUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      rethrow;
    }
  }

  // ========== DELETE OLD PROFILE PICTURE ==========
  Future<void> deleteProfilePicture(String? oldUrl) async {
    try {
      if (oldUrl == null || oldUrl.isEmpty) return;

      // Extract file path from URL
      final uri = Uri.parse(oldUrl);
      final path = uri.pathSegments.last;

      if (path.isNotEmpty && path.contains('profile_pictures')) {
        await _supabase.storage.from('avatars').remove([
          'profile_pictures/$path',
        ]);
      }
    } catch (e) {
      print('Error deleting old profile picture: $e');
      // Don't throw - we still want to proceed even if deletion fails
    }
  }
}
