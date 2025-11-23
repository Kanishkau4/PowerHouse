import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:powerhouse/core/config/supabase_config.dart';
import 'package:powerhouse/models/workout_model.dart';
import 'package:powerhouse/models/exercise_model.dart';
import 'package:powerhouse/models/workout_log_model.dart';
import 'package:powerhouse/services/progress_service.dart';

class WorkoutService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  final _progressService = ProgressService();

  // ========== GET ALL WORKOUTS ==========
  Future<List<WorkoutModel>> getAllWorkouts() async {
    try {
      final response = await _supabase
          .from('workouts')
          .select()
          .order('workout_name');

      return (response as List)
          .map((json) => WorkoutModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error getting workouts: $e');
      return [];
    }
  }

  // ========== GET WORKOUT BY ID WITH EXERCISES (FIXED) ==========
  Future<WorkoutModel?> getWorkoutWithExercises(String workoutId) async {
    try {
      print('📦 Fetching workout: $workoutId');

      // Get workout
      final workoutResponse = await _supabase
          .from('workouts')
          .select()
          .eq('workout_id', workoutId)
          .single();

      print('✅ Workout fetched: ${workoutResponse['workout_name']}');

      final workout = WorkoutModel.fromJson(workoutResponse);

      // Get exercises using Supabase's nested join feature
      print('📦 Fetching exercises for workout using nested join...');

      final workoutExercisesResponse = await _supabase
          .from('workout_exercises')
          .select('''
            sets,
            reps,
            duration,
            order_in_workout,
            exercises (
              exercise_id,
              exercise_name,
              description,
              video_url,
              animation_url,
              muscle_group_targeted,
              created_at
            )
          ''')
          .eq('workout_id', workoutId)
          .order('order_in_workout');

      print(
        '✅ Workout exercises response: ${workoutExercisesResponse.length} records found',
      );

      if (workoutExercisesResponse.isEmpty) {
        print('⚠️ No workout exercises found for workout: $workoutId');
        return workout; // Return workout without exercises
      }

      // Parse the joined data
      final exercises = <ExerciseWithDetails>[];
      for (var item in workoutExercisesResponse as List) {
        try {
          // The exercise data is nested under 'exercises' key
          final exerciseData = item['exercises'];

          if (exerciseData == null) {
            print('⚠️ No exercise data found in item: $item');
            continue;
          }

          // Create ExerciseModel from the nested data
          final exercise = ExerciseModel.fromJson(
            exerciseData as Map<String, dynamic>,
          );

          // Create ExerciseWithDetails combining exercise + workout_exercises data
          exercises.add(
            ExerciseWithDetails(
              exercise: exercise,
              sets: item['sets'] as int?,
              reps: item['reps'] as int?,
              duration: item['duration'] as int?,
              orderInWorkout: item['order_in_workout'] as int,
            ),
          );

          print('✅ Added exercise: ${exercise.exerciseName}');
        } catch (e) {
          print('❌ Error parsing exercise item: $e');
          print('Item data: $item');
        }
      }

      print('✅ Successfully parsed ${exercises.length} exercises');

      // Sort by order just to be safe
      exercises.sort((a, b) => a.orderInWorkout.compareTo(b.orderInWorkout));

      return workout.copyWithExercises(exercises);
    } catch (e, stackTrace) {
      print('❌ Error getting workout with exercises: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // ========== GET WORKOUTS BY CATEGORY ==========
  Future<List<WorkoutModel>> getWorkoutsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('workouts')
          .select()
          .eq('category', category)
          .order('workout_name');

      return (response as List)
          .map((json) => WorkoutModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error getting workouts by category: $e');
      return [];
    }
  }

  // ========== SEARCH WORKOUTS ==========
  Future<List<WorkoutModel>> searchWorkouts(String query) async {
    try {
      final response = await _supabase
          .from('workouts')
          .select()
          .or(
            'workout_name.ilike.%$query%,description.ilike.%$query%,category.ilike.%$query%',
          )
          .limit(20);

      return (response as List)
          .map((json) => WorkoutModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error searching workouts: $e');
      return [];
    }
  }

  // ========== LOG WORKOUT COMPLETION ==========
  Future<Map<String, dynamic>> logWorkoutCompletion({
    required String workoutId,
    required int duration, // minutes
    required int caloriesBurned,
  }) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) throw Exception('No user logged in');

      print('💾 Logging workout completion...');

      // Insert workout log
      await _supabase.from('workout_logs').insert({
        'user_id': userId,
        'workout_id': workoutId,
        'actual_duration': duration,
        'calories_burned': caloriesBurned,
        'date_completed': DateTime.now().toIso8601String(),
      });

      print('✅ Workout logged successfully');

      // Award XP
      final xpResult = await _progressService.awardWorkoutXP();

      print('🏆 XP awarded: ${xpResult['xp_added']}');
      print('📊 Total XP: ${xpResult['total_xp']}');
      print('⭐ Level: ${xpResult['current_level']}');

      if (xpResult['leveled_up'] == true) {
        print('🎉 LEVEL UP! Now level ${xpResult['current_level']}');
      }

      return xpResult;
    } catch (e) {
      print('❌ Error logging workout: $e');
      rethrow;
    }
  }

  // ========== GET WORKOUT HISTORY ==========
  Future<List<WorkoutLogModel>> getWorkoutHistory({int limit = 30}) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return [];

      final response = await _supabase
          .from('workout_logs')
          .select('*, workouts(*)')
          .eq('user_id', userId)
          .order('date_completed', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => WorkoutLogModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error getting workout history: $e');
      return [];
    }
  }

  // ========== GET TOTAL WORKOUT COUNT ==========
  Future<int> getTotalWorkoutCount() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return 0;

      final response = await _supabase
          .from('workout_logs')
          .select('log_id')
          .eq('user_id', userId);

      return (response as List).length;
    } catch (e) {
      print('❌ Error getting workout count: $e');
      return 0;
    }
  }

  // ========== GET WORKOUT DURATION BY DAY ==========
  Future<Map<DateTime, int>> getWorkoutDurationByDay(int days) async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return {};

      final startDate = DateTime.now().subtract(Duration(days: days));

      final response = await _supabase
          .from('workout_logs')
          .select('date_completed, actual_duration')
          .eq('user_id', userId)
          .gte('date_completed', startDate.toIso8601String())
          .order('date_completed', ascending: true);

      // Aggregate by day
      final Map<DateTime, int> durationByDay = {};

      for (var log in response as List) {
        final dateCompleted = DateTime.parse(log['date_completed']);
        final dayKey = DateTime(
          dateCompleted.year,
          dateCompleted.month,
          dateCompleted.day,
        );
        final duration = log['actual_duration'] as int? ?? 0;

        durationByDay[dayKey] = (durationByDay[dayKey] ?? 0) + duration;
      }

      print('✅ Fetched workout duration for ${durationByDay.length} days');
      return durationByDay;
    } catch (e) {
      print('❌ Error getting workout duration by day: $e');
      return {};
    }
  }
}
