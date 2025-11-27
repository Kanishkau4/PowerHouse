import 'package:powerhouse/core/config/supabase_config.dart';
import 'package:powerhouse/models/models.dart';

class TipsService {
  final _supabase = SupabaseConfig.client;

  // ========== GET TIP OF THE DAY ==========
  // Returns a random featured tip
  Future<TipModel?> getTipOfTheDay() async {
    try {
      final response = await _supabase
          .from('tips')
          .select()
          .eq('is_featured', true)
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isEmpty) {
        // If no featured tips, return any random tip
        final anyTip = await _supabase.from('tips').select().limit(1);

        if (anyTip.isEmpty) return null;
        return TipModel.fromJson(anyTip.first);
      }

      return TipModel.fromJson(response.first);
    } catch (e) {
      print('Error getting tip of the day: $e');
      return null;
    }
  }

  // ========== GET ALL TIPS ==========
  Future<List<TipModel>> getAllTips() async {
    try {
      final response = await _supabase
          .from('tips')
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((tip) => TipModel.fromJson(tip)).toList();
    } catch (e) {
      print('Error getting all tips: $e');
      return [];
    }
  }

  // ========== GET TIPS BY CATEGORY ==========
  Future<List<TipModel>> getTipsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('tips')
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);

      return (response as List).map((tip) => TipModel.fromJson(tip)).toList();
    } catch (e) {
      print('Error getting tips by category: $e');
      return [];
    }
  }

  // ========== GET TIP BY ID ==========
  Future<TipModel?> getTipById(String tipId) async {
    try {
      final response = await _supabase
          .from('tips')
          .select()
          .eq('tip_id', tipId)
          .single();

      return TipModel.fromJson(response);
    } catch (e) {
      print('Error getting tip by ID: $e');
      return null;
    }
  }

  // ========== GET ALL CATEGORIES ==========
  Future<List<TipCategoryModel>> getCategories() async {
    try {
      final response = await _supabase
          .from('tip_categories')
          .select()
          .order('sort_order', ascending: true);

      return (response as List)
          .map((category) => TipCategoryModel.fromJson(category))
          .toList();
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  // ========== GET USER TIP PROGRESS ==========
  Future<UserTipProgressModel?> getUserTipProgress(String tipId) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return null;

      final response = await _supabase
          .from('user_tips_progress')
          .select()
          .eq('user_id', userId)
          .eq('tip_id', tipId)
          .maybeSingle();

      if (response == null) return null;
      return UserTipProgressModel.fromJson(response);
    } catch (e) {
      print('Error getting user tip progress: $e');
      return null;
    }
  }

  // ========== MARK TIP AS READ ==========
  Future<bool> markTipAsRead(String tipId) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return false;

      // Check if progress record exists
      final existing = await getUserTipProgress(tipId);

      if (existing != null) {
        // Update existing record
        await _supabase
            .from('user_tips_progress')
            .update({
              'is_read': true,
              'read_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('tip_id', tipId);
      } else {
        // Create new record
        await _supabase.from('user_tips_progress').insert({
          'user_id': userId,
          'tip_id': tipId,
          'is_read': true,
          'read_at': DateTime.now().toIso8601String(),
        });
      }

      return true;
    } catch (e) {
      print('Error marking tip as read: $e');
      return false;
    }
  }

  // ========== TOGGLE TIP LIKE ==========
  Future<bool> toggleTipLike(String tipId) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return false;

      // Get current progress
      final existing = await getUserTipProgress(tipId);
      final currentLikeStatus = existing?.isLiked ?? false;
      final newLikeStatus = !currentLikeStatus;

      if (existing != null) {
        // Update existing record
        await _supabase
            .from('user_tips_progress')
            .update({
              'is_liked': newLikeStatus,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('tip_id', tipId);
      } else {
        // Create new record
        await _supabase.from('user_tips_progress').insert({
          'user_id': userId,
          'tip_id': tipId,
          'is_liked': newLikeStatus,
        });
      }

      // Update like count in tips table
      await _supabase.rpc('update_tip_like_count', params: {'tip_uuid': tipId});

      return newLikeStatus;
    } catch (e) {
      print('Error toggling tip like: $e');
      return false;
    }
  }

  // ========== TOGGLE TIP BOOKMARK ==========
  Future<bool> toggleTipBookmark(String tipId) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return false;

      // Get current progress
      final existing = await getUserTipProgress(tipId);
      final currentBookmarkStatus = existing?.isBookmarked ?? false;
      final newBookmarkStatus = !currentBookmarkStatus;

      if (existing != null) {
        // Update existing record
        await _supabase
            .from('user_tips_progress')
            .update({
              'is_bookmarked': newBookmarkStatus,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('tip_id', tipId);
      } else {
        // Create new record
        await _supabase.from('user_tips_progress').insert({
          'user_id': userId,
          'tip_id': tipId,
          'is_bookmarked': newBookmarkStatus,
        });
      }

      return newBookmarkStatus;
    } catch (e) {
      print('Error toggling tip bookmark: $e');
      return false;
    }
  }

  // ========== INCREMENT VIEW COUNT ==========
  Future<void> incrementViewCount(String tipId) async {
    try {
      await _supabase.rpc(
        'increment_tip_view_count',
        params: {'tip_uuid': tipId},
      );
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  // ========== GET BOOKMARKED TIPS ==========
  Future<List<TipModel>> getBookmarkedTips() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return [];

      final response = await _supabase
          .from('user_tips_progress')
          .select('tip_id, tips(*)')
          .eq('user_id', userId)
          .eq('is_bookmarked', true);

      return (response as List)
          .map((item) => TipModel.fromJson(item['tips']))
          .toList();
    } catch (e) {
      print('Error getting bookmarked tips: $e');
      return [];
    }
  }

  // ========== GET READ TIPS COUNT ==========
  Future<int> getReadTipsCount() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return 0;

      final response = await _supabase
          .from('user_tips_progress')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', true);

      return (response as List).length;
    } catch (e) {
      print('Error getting read tips count: $e');
      return 0;
    }
  }
}
