import 'package:powerhouse/models/challenge_model.dart';

class UserChallengeModel {
  final String userId;
  final String challengeId;
  final int progress;
  final String status; // 'In-Progress', 'Completed', 'Failed'
  final DateTime startedAt;
  final DateTime? completedAt;
  
  // Populated from join
  final ChallengeModel? challenge;

  UserChallengeModel({
    required this.userId,
    required this.challengeId,
    this.progress = 0,
    this.status = 'In-Progress',
    required this.startedAt,
    this.completedAt,
    this.challenge,
  });

  factory UserChallengeModel.fromJson(Map<String, dynamic> json) {
    return UserChallengeModel(
      userId: json['user_id'] as String,
      challengeId: json['challenge_id'] as String,
      progress: json['progress'] as int? ?? 0,
      status: json['status'] as String? ?? 'In-Progress',
      startedAt: DateTime.parse(json['started_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      challenge: json['challenges'] != null
          ? ChallengeModel.fromJson(json['challenges'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'challenge_id': challengeId,
      'progress': progress,
      'status': status,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  // Helper: Progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (challenge == null) return 0.0;
    return (progress / challenge!.targetValue).clamp(0.0, 1.0);
  }

  // Helper: Is completed
  bool get isCompleted => status == 'Completed';

  // Helper: Is in progress
  bool get isInProgress => status == 'In-Progress';

  // Helper: Days remaining
  int? get daysRemaining {
    if (challenge == null) return null;
    final endDate = startedAt.add(Duration(days: challenge!.durationDays));
    final remaining = endDate.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  get endDate => null;
}