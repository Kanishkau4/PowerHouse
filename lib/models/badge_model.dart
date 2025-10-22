class BadgeModel {
  final String badgeId;
  final String badgeName;
  final String? description;
  final String? iconUrl;
  final String? requirementDescription;
  final DateTime createdAt;

  BadgeModel({
    required this.badgeId,
    required this.badgeName,
    this.description,
    this.iconUrl,
    this.requirementDescription,
    required this.createdAt,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      badgeId: json['badge_id'] as String,
      badgeName: json['badge_name'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      requirementDescription: json['requirement_description'] as String?,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'badge_id': badgeId,
      'badge_name': badgeName,
      'description': description,
      'icon_url': iconUrl,
      'requirement_description': requirementDescription,
    };
  }
}