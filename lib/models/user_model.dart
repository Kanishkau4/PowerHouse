class UserModel {
  final String userId;
  final String username;
  final String email;
  final String? profilePictureUrl;
  final DateTime? dateOfBirth;
  final double? height; // cm
  final double? currentWeight; // kg
  final double? goalWeight; // kg
  final String? fitnessGoal;
  final String? activityLevel;
  final int xpPoints;
  final int level;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.userId,
    required this.username,
    required this.email,
    this.profilePictureUrl,
    this.dateOfBirth,
    this.height,
    this.currentWeight,
    this.goalWeight,
    this.fitnessGoal,
    this.activityLevel,
    this.xpPoints = 0,
    this.level = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  // From JSON (Supabase response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      profilePictureUrl: json['profile_picture_url'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      height: json['height'] != null 
          ? double.parse(json['height'].toString()) 
          : null,
      currentWeight: json['current_weight'] != null
          ? double.parse(json['current_weight'].toString())
          : null,
      goalWeight: json['goal_weight'] != null
          ? double.parse(json['goal_weight'].toString())
          : null,
      fitnessGoal: json['fitness_goal'] as String?,
      activityLevel: json['activity_level'] as String?,
      xpPoints: json['xp_points'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // To JSON (for updates)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'profile_picture_url': profilePictureUrl,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'height': height,
      'current_weight': currentWeight,
      'goal_weight': goalWeight,
      'fitness_goal': fitnessGoal,
      'activity_level': activityLevel,
      'xp_points': xpPoints,
      'level': level,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // Helper: Get age from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  // Helper: Get BMI
  double? get bmi {
    if (currentWeight == null || height == null) return null;
    final heightInMeters = height! / 100;
    return currentWeight! / (heightInMeters * heightInMeters);
  }

  // Helper: Level progress (0.0 to 1.0)
  double get levelProgress {
    final xpForNextLevel = level * 100;
    final xpInCurrentLevel = xpPoints % 100;
    return xpInCurrentLevel / xpForNextLevel;
  }

  // Copy with
  UserModel copyWith({
    String? userId,
    String? username,
    String? email,
    String? profilePictureUrl,
    DateTime? dateOfBirth,
    double? height,
    double? currentWeight,
    double? goalWeight,
    String? fitnessGoal,
    String? activityLevel,
    int? xpPoints,
    int? level,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      height: height ?? this.height,
      currentWeight: currentWeight ?? this.currentWeight,
      goalWeight: goalWeight ?? this.goalWeight,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      activityLevel: activityLevel ?? this.activityLevel,
      xpPoints: xpPoints ?? this.xpPoints,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}