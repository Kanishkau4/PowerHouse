class ChallengeProgressModel {
  final String progressId;
  final String userId;
  final String challengeId;
  final int dailyProgress;
  final DateTime progressDate;

  ChallengeProgressModel({
    required this.progressId,
    required this.userId,
    required this.challengeId,
    required this.dailyProgress,
    required this.progressDate,
  });

  factory ChallengeProgressModel.fromJson(Map<String, dynamic> json) {
    return ChallengeProgressModel(
      progressId: json['progress_id'] as String,
      userId: json['user_id'] as String,
      challengeId: json['challenge_id'] as String,
      dailyProgress: json['daily_progress'] as int,
      progressDate: DateTime.parse(json['progress_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'challenge_id': challengeId,
      'daily_progress': dailyProgress,
      'progress_date': progressDate.toIso8601String().split('T')[0],
    };
  }
}