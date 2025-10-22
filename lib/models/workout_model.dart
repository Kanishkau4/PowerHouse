import 'package:flutter/material.dart';
import 'package:powerhouse/models/exercise_model.dart';

class WorkoutModel {
  final String workoutId;
  final String workoutName;
  final String? description;
  final String? difficulty;
  final String? category;
  final int? estimatedDuration;
  final int? estimatedCaloriesBurned;
  final String? imageUrl;
  final DateTime createdAt;

  // Populated from join (workout_exercises)
  final List<ExerciseWithDetails>? exercises;

  WorkoutModel({
    required this.workoutId,
    required this.workoutName,
    this.description,
    this.difficulty,
    this.category,
    this.estimatedDuration,
    this.estimatedCaloriesBurned,
    this.imageUrl,
    required this.createdAt,
    this.exercises,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      workoutId: json['workout_id'] as String,
      workoutName: json['workout_name'] as String,
      description: json['description'] as String?,
      difficulty: json['difficulty'] as String?,
      category: json['category'] as String?,
      estimatedDuration: json['estimated_duration'] as int?,
      estimatedCaloriesBurned: json['estimated_calories_burned'] as int?,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      exercises: null, // Will be populated separately
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workout_id': workoutId,
      'workout_name': workoutName,
      'description': description,
      'difficulty': difficulty,
      'category': category,
      'estimated_duration': estimatedDuration,
      'estimated_calories_burned': estimatedCaloriesBurned,
      'image_url': imageUrl,
    };
  }

  // Helper: Get difficulty color
  Color get difficultyColor {
    switch (difficulty?.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF1DAB87);
      case 'intermediate':
        return const Color(0xFFF97316);
      case 'advanced':
        return const Color(0xFFFF6B6B);
      default:
        return const Color(0xFF979797);
    }
  }

  // Copy with exercises
  WorkoutModel copyWithExercises(List<ExerciseWithDetails> exercises) {
    return WorkoutModel(
      workoutId: workoutId,
      workoutName: workoutName,
      description: description,
      difficulty: difficulty,
      category: category,
      estimatedDuration: estimatedDuration,
      estimatedCaloriesBurned: estimatedCaloriesBurned,
      imageUrl: imageUrl,
      createdAt: createdAt,
      exercises: exercises,
    );
  }
}

// Exercise with workout details (sets, reps, duration, order)
class ExerciseWithDetails {
  final ExerciseModel exercise;
  final int? sets;
  final int? reps;
  final int? duration; // seconds
  final int orderInWorkout;

  ExerciseWithDetails({
    required this.exercise,
    this.sets,
    this.reps,
    this.duration,
    required this.orderInWorkout,
  });

  // Helper: Get duration as MM:SS
  String get durationFormatted {
    if (duration == null) return '00:00';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}