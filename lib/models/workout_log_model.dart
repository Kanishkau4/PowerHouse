import 'package:powerhouse/models/workout_model.dart';

class WorkoutLogModel {
  final String logId;
  final String userId;
  final String? workoutId;
  final DateTime dateCompleted;
  final int? actualDuration; // minutes
  final int? caloriesBurned;
  final DateTime createdAt;
  
  // Populated from join
  final WorkoutModel? workout;

  WorkoutLogModel({
    required this.logId,
    required this.userId,
    this.workoutId,
    required this.dateCompleted,
    this.actualDuration,
    this.caloriesBurned,
    required this.createdAt,
    this.workout,
  });

  factory WorkoutLogModel.fromJson(Map<String, dynamic> json) {
    return WorkoutLogModel(
      logId: json['log_id'] as String,
      userId: json['user_id'] as String,
      workoutId: json['workout_id'] as String?,
      dateCompleted: DateTime.parse(json['date_completed']),
      actualDuration: json['actual_duration'] as int?,
      caloriesBurned: json['calories_burned'] as int?,
      createdAt: DateTime.parse(json['created_at']),
      workout: json['workouts'] != null
          ? WorkoutModel.fromJson(json['workouts'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'workout_id': workoutId,
      'date_completed': dateCompleted.toIso8601String(),
      'actual_duration': actualDuration,
      'calories_burned': caloriesBurned,
    };
  }
}