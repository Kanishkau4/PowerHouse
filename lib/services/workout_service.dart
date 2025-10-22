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

  // ========== GET WORKOUT BY ID WITH EXERCISES ==========
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

      // Get exercises for this workout using a more robust approach
      print('📦 Fetching exercises for workout...');
      
      // First get the workout_exercises records with exercise details
      final workoutExercisesResponse = await _supabase
          .from('workout_exercises')
          .select('''
            sets,
            reps,
            duration,
            order_in_workout,
            exercise_id
          ''')
          .eq('workout_id', workoutId)
          .order('order_in_workout');

      print('✅ Workout exercises response: ${workoutExercisesResponse.length} records found');

      if (workoutExercisesResponse.isEmpty) {
        print('⚠️ No workout exercises found for workout: $workoutId');
        return workout; // Return workout without exercises
      }

      // Extract unique exercise IDs
      final exerciseIds = (workoutExercisesResponse as List)
          .map((item) => item['exercise_id'] as String)
          .toSet()
          .toList();

      print('📦 Fetching exercise details for ${exerciseIds.length} unique exercises...');
      
      // Get the actual exercise details
      final exercisesResponse = await _supabase
          .from('exercises')
          .select()
          .inFilter('exercise_id', exerciseIds);

      print('✅ Exercises details response: ${exercisesResponse.length} exercises found');

      // Create a map for quick lookup of exercise details
      final exerciseMap = <String, ExerciseModel>{};
      for (var exerciseData in exercisesResponse as List) {
        final exercise = ExerciseModel.fromJson(exerciseData as Map<String, dynamic>);
        exerciseMap[exercise.exerciseId] = exercise;
      }

      // Combine workout_exercises data with exercise details
      final exercises = <ExerciseWithDetails>[];
      for (var workoutExercise in workoutExercisesResponse) {
        final exerciseId = workoutExercise['exercise_id'] as String;
        final exercise = exerciseMap[exerciseId];
        
        if (exercise != null) {
          exercises.add(ExerciseWithDetails(
            exercise: exercise,
            sets: workoutExercise['sets'] as int?,
            reps: workoutExercise['reps'] as int?,
            duration: workoutExercise['duration'] as int?,
            orderInWorkout: workoutExercise['order_in_workout'] as int,
          ));
        } else {
          print('⚠️ Exercise data not found for exercise_id: $exerciseId');
        }
      }

      print('✅ Successfully combined ${exercises.length} exercises');

      // Sort exercises by order_in_workout to ensure correct sequence
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
          .or('workout_name.ilike.%$query%,description.ilike.%$query%,category.ilike.%$query%')
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

  // ========== GET TOTAL WORKOUT COUNT (FIXED) ==========
  Future<int> getTotalWorkoutCount() async {
    try {
      final userId = SupabaseConfig.currentUserId;
      if (userId == null) return 0;

      // Modern way to count in Supabase
      final response = await _supabase
          .from('workout_logs')
          .select('log_id')
          .eq('user_id', userId);

      // Simply return the length of the response
      return (response as List).length;
    } catch (e) {
      print('❌ Error getting workout count: $e');
      return 0;
    }
  }
}