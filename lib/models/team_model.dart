class TeamModel {
  final String teamId;
  final String teamName;
  final String? description;
  final String? imageUrl;
  final String createdBy;
  final int memberCount;
  final int totalXp;
  final DateTime createdAt;

  TeamModel({
    required this.teamId,
    required this.teamName,
    this.description,
    this.imageUrl,
    required this.createdBy,
    this.memberCount = 0,
    this.totalXp = 0,
    required this.createdAt,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      teamId: json['team_id'] as String,
      teamName: json['team_name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      createdBy: json['created_by'] as String,
      memberCount: json['member_count'] as int? ?? 0,
      totalXp: json['total_xp'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team_id': teamId,
      'team_name': teamName,
      'description': description,
      'image_url': imageUrl,
      'created_by': createdBy,
      'member_count': memberCount,
      'total_xp': totalXp,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class TeamMemberModel {
  final String teamId;
  final String userId;
  final String role; // 'leader', 'member'
  final DateTime joinedAt;

  // Populated from join
  final String? username;
  final String? profilePictureUrl;
  final int? xpPoints;

  TeamMemberModel({
    required this.teamId,
    required this.userId,
    this.role = 'member',
    required this.joinedAt,
    this.username,
    this.profilePictureUrl,
    this.xpPoints,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      teamId: json['team_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String? ?? 'member',
      joinedAt: DateTime.parse(json['joined_at']),
      username: json['users']?['username'] as String?,
      profilePictureUrl: json['users']?['profile_picture_url'] as String?,
      xpPoints: json['users']?['xp_points'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team_id': teamId,
      'user_id': userId,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}

class TeamChallengeModel {
  final String teamChallengeId;
  final String teamId;
  final String challengeId;
  final int teamProgress;
  final String status; // 'In-Progress', 'Completed'
  final DateTime startedAt;
  final DateTime? completedAt;

  TeamChallengeModel({
    required this.teamChallengeId,
    required this.teamId,
    required this.challengeId,
    this.teamProgress = 0,
    this.status = 'In-Progress',
    required this.startedAt,
    this.completedAt,
  });

  factory TeamChallengeModel.fromJson(Map<String, dynamic> json) {
    return TeamChallengeModel(
      teamChallengeId: json['team_challenge_id'] as String,
      teamId: json['team_id'] as String,
      challengeId: json['challenge_id'] as String,
      teamProgress: json['team_progress'] as int? ?? 0,
      status: json['status'] as String? ?? 'In-Progress',
      startedAt: DateTime.parse(json['started_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team_challenge_id': teamChallengeId,
      'team_id': teamId,
      'challenge_id': challengeId,
      'team_progress': teamProgress,
      'status': status,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}
