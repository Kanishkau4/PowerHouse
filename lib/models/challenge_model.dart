class ChallengeModel {
  final String challengeId;
  final String challengeName;
  final String? description;
  final int targetValue;
  final String unit; // 'steps', 'calories', 'workouts'
  final int durationDays;
  final int xpReward;
  final String? imageUrl;
  final String
  challengeType; // 'physical', 'nutrition', 'mindfulness', 'social'
  final Map<String, dynamic> metaData;
  final DateTime createdAt;

  ChallengeModel({
    required this.challengeId,
    required this.challengeName,
    this.description,
    required this.targetValue,
    required this.unit,
    required this.durationDays,
    this.xpReward = 0,
    this.imageUrl,
    this.challengeType = 'physical',
    this.metaData = const {},
    required this.createdAt,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      challengeId: json['challenge_id'] as String,
      challengeName: json['challenge_name'] as String,
      description: json['description'] as String?,
      targetValue: json['target_value'] as int,
      unit: json['unit'] as String,
      durationDays: json['duration_days'] as int,
      xpReward: json['xp_reward'] as int? ?? 0,
      imageUrl: json['image_url'] as String?,
      challengeType: json['challenge_type'] as String? ?? 'physical',
      metaData: json['meta_data'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'challenge_id': challengeId,
      'challenge_name': challengeName,
      'description': description,
      'target_value': targetValue,
      'unit': unit,
      'duration_days': durationDays,
      'xp_reward': xpReward,
      'image_url': imageUrl,
      'challenge_type': challengeType,
      'meta_data': metaData,
    };
  }
}
