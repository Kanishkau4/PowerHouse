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
      final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

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

      await _supabase.rpc('generate_daily_tasks_for_user', params: {
        'p_user_id': userId,
      });
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
      await _supabase.from('daily_tasks').update({
        'is_completed': true,
        'completed_at': DateTime.now().toIso8601String(),
      }).eq('task_id', taskId);

      print('✅ Task completed');

      // Award XP (small amount for daily tasks)
      final xpResult = await _progressService.addXP(5, reason: 'Daily task completed');

      return xpResult;
    } catch (e) {
      print('Error completing task: $e');
      rethrow;
    }
  }

  // ========== MARK TASK AS INCOMPLETE ==========
  Future<void> uncompleteTask(String taskId) async {
    try {
      await _supabase.from('daily_tasks').update({
        'is_completed': false,
        'completed_at': null,
      }).eq('task_id', taskId);

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
      final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final response = await _supabase
          .from('daily_tasks')
          .select()
          .eq('user_id', userId)
          .eq('task_date', dateString);

      final tasks = List<Map<String, dynamic>>.from(response);
      final completed = tasks.where((t) => t['is_completed'] == true).length;

      return {
        'completed': completed,
        'total': tasks.length,
      };
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
      final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

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
}