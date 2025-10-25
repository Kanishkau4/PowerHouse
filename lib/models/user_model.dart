class UserModel {
  final String userId;
  final String username;
  final String email;
  final String? profilePictureUrl;
  final int? age;
  final String? gender;
  final double? height; // cm
  final double? currentWeight; // kg
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
    this.age,
    this.gender,
    this.height,
    this.currentWeight,
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
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      height: json['height'] != null 
          ? double.parse(json['height'].toString()) 
          : null,
      currentWeight: json['current_weight'] != null
          ? double.parse(json['current_weight'].toString())
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
      'age': age,
      'gender': gender,
      'height': height,
      'current_weight': currentWeight,
      'fitness_goal': fitnessGoal,
      'activity_level': activityLevel,
      'xp_points': xpPoints,
      'level': level,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // Helper: Get BMI
  double? get bmi {
    if (currentWeight == null || height == null) return null;
    final heightInMeters = height! / 100;
    return currentWeight! / (heightInMeters * heightInMeters);
  }

  // Helper: Get BMI Category
  String? get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return null;
    
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  // Helper: Level progress (0.0 to 1.0)
  double get levelProgress {
    final xpInCurrentLevel = xpPoints % 100;
    return xpInCurrentLevel / 100;
  }

  // Helper: XP needed for next level
  int get xpNeededForNextLevel {
    final xpInCurrentLevel = xpPoints % 100;
    return 100 - xpInCurrentLevel;
  }

  // Copy with
  UserModel copyWith({
    String? userId,
    String? username,
    String? email,
    String? profilePictureUrl,
    int? age,
    String? gender,
    double? height,
    double? currentWeight,
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
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      currentWeight: currentWeight ?? this.currentWeight,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      activityLevel: activityLevel ?? this.activityLevel,
      xpPoints: xpPoints ?? this.xpPoints,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(userId: $userId, username: $username, email: $email, age: $age, gender: $gender)';
  }
}