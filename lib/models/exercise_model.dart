class ExerciseModel {
  final String exerciseId;
  final String exerciseName;
  final String? description;
  final String? videoUrl;
  final String? animationUrl;
  final String? muscleGroupTargeted;
  final DateTime createdAt;

  ExerciseModel({
    required this.exerciseId,
    required this.exerciseName,
    this.description,
    this.videoUrl,
    this.animationUrl,
    this.muscleGroupTargeted,
    required this.createdAt,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    try {
      return ExerciseModel(
        exerciseId: json['exercise_id'] as String,
        exerciseName: json['exercise_name'] as String,
        description: json['description'] as String?,
        videoUrl: json['video_url'] as String?,
        animationUrl: json['animation_url'] as String?,
        muscleGroupTargeted: json['muscle_group_targeted'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
    } catch (e) {
      print('❌ Error parsing ExerciseModel: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'description': description,
      'video_url': videoUrl,
      'animation_url': animationUrl,
      'muscle_group_targeted': muscleGroupTargeted,
      'created_at': createdAt.toIso8601String(),
    };
  }
}