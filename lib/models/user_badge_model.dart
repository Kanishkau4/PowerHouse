import 'package:powerhouse/models/badge_model.dart';

class UserBadgeModel {
  final String userId;
  final String badgeId;
  final DateTime dateEarned;
  
  // Populated from join
  final BadgeModel? badge;

  UserBadgeModel({
    required this.userId,
    required this.badgeId,
    required this.dateEarned,
    this.badge,
  });

  factory UserBadgeModel.fromJson(Map<String, dynamic> json) {
    return UserBadgeModel(
      userId: json['user_id'] as String,
      badgeId: json['badge_id'] as String,
      dateEarned: DateTime.parse(json['date_earned']),
      badge: json['badges'] != null
          ? BadgeModel.fromJson(json['badges'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'badge_id': badgeId,
      'date_earned': dateEarned.toIso8601String(),
    };
  }
}