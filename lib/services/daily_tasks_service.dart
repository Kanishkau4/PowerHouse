import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:powerhouse/core/config/supabase_config.dart';
import 'package:powerhouse/services/progress_service.dart';

class DailyTasksService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final _progressService = ProgressService();

  // ========== GET TODAY'S TASKS ==========
  Future<List<Map<String, dynamic>>> getTodayTasks() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return [];

      // Generate tasks if they don't exist
      await _generateTasksForToday();

      final today = DateTime.now();
      final dateString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final response = await _supabase
          .from('daily_tasks')
          .select()
          .eq('user_id', userId)
          .eq('task_date', dateString)
          .order('created_at');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting today\'s tasks: $e');
      return [];
    }
  }

  // ========== GENERATE TASKS FOR TODAY ==========
  Future<void> _generateTasksForToday() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return;

      await _supabase.rpc(
        'generate_daily_tasks_for_user',
        params: {'p_user_id': userId},
      );
    } catch (e) {
      print('Error generating tasks: $e');
    }
  }

  // ========== MARK TASK AS COMPLETE ==========
  Future<Map<String, dynamic>> completeTask(String taskId) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) throw Exception('No user logged in');

      // Update task
      await _supabase
          .from('daily_tasks')
          .update({
            'is_completed': true,
            'completed_at': DateTime.now().toIso8601String(),
          })
          .eq('task_id', taskId);

      print('✅ Task completed');

      // Award XP (small amount for daily tasks)
      final xpResult = await _progressService.addXP(
        5,
        reason: 'Daily task completed',
      );

      return xpResult;
    } catch (e) {
      print('Error completing task: $e');
      rethrow;
    }
  }

  // ========== MARK TASK AS INCOMPLETE ==========
  Future<void> uncompleteTask(String taskId) async {
    try {
      await _supabase
          .from('daily_tasks')
          .update({'is_completed': false, 'completed_at': null})
          .eq('task_id', taskId);

      print('Task marked as incomplete');
    } catch (e) {
      print('Error uncompleting task: $e');
      rethrow;
    }
  }

  // ========== GET TASK COMPLETION STATS ==========
  Future<Map<String, int>> getTaskStats() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return {'completed': 0, 'total': 0};

      final today = DateTime.now();
      final dateString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final response = await _supabase
          .from('daily_tasks')
          .select()
          .eq('user_id', userId)
          .eq('task_date', dateString);

      final tasks = List<Map<String, dynamic>>.from(response);
      final completed = tasks.where((t) => t['is_completed'] == true).length;

      return {'completed': completed, 'total': tasks.length};
    } catch (e) {
      print('Error getting task stats: $e');
      return {'completed': 0, 'total': 0};
    }
  }

  // ========== ADD CUSTOM TASK ==========
  Future<void> addCustomTask({
    required String title,
    String type = 'custom',
    int? duration,
    int? calories,
  }) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) throw Exception('No user logged in');

      final today = DateTime.now();
      final dateString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      await _supabase.from('daily_tasks').insert({
        'user_id': userId,
        'task_title': title,
        'task_type': type,
        'duration': duration,
        'calories': calories,
        'task_date': dateString,
        'is_completed': false,
      });

      print('Custom task added');
    } catch (e) {
      print('Error adding custom task: $e');
      rethrow;
    }
  }

  // ========== GET CURRENT STREAK ==========
  Future<int> getCurrentStreak() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return 0;

      // Fetch dates with at least one completed task
      final response = await _supabase
          .from('daily_tasks')
          .select('task_date')
          .eq('user_id', userId)
          .eq('is_completed', true)
          .order('task_date', ascending: false);

      if ((response as List).isEmpty) {
        return 0;
      }

      final completedDates =
          (response as List)
              .map((e) => DateTime.parse(e['task_date'] as String))
              .toSet() // Remove duplicates for same day
              .toList()
            ..sort((a, b) => b.compareTo(a)); // Sort descending (newest first)

      if (completedDates.isEmpty) return 0;

      int streak = 0;
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      // Normalize dates to ignore time parts
      final yesterdayDate = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
      );

      // Check if streak is active (completed today OR yesterday)
      final lastCompletedDate = DateTime(
        completedDates.first.year,
        completedDates.first.month,
        completedDates.first.day,
      );

      // If last completed task was before yesterday, streak is broken
      if (lastCompletedDate.isBefore(yesterdayDate)) {
        return 0;
      }

      // Calculate streak
      // We start checking from the last completed date going backwards
      DateTime checksDate = lastCompletedDate;

      for (var date in completedDates) {
        final currentDate = DateTime(date.year, date.month, date.day);

        // precise match for sequence
        if (currentDate.isAtSameMomentAs(checksDate)) {
          streak++;
          checksDate = checksDate.subtract(const Duration(days: 1));
        } else if (currentDate.isBefore(checksDate)) {
          // Gap found
          break;
        }
      }

      return streak;
    } catch (e) {
      print('Error getting streak: $e');
      return 0;
    }
  }
}
