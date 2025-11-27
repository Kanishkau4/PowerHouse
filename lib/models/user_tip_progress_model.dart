class UserTipProgressModel {
  final String id;
  final String userId;
  final String tipId;
  final bool isRead;
  final bool isLiked;
  final bool isBookmarked;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserTipProgressModel({
    required this.id,
    required this.userId,
    required this.tipId,
    this.isRead = false,
    this.isLiked = false,
    this.isBookmarked = false,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // From JSON (Supabase response)
  factory UserTipProgressModel.fromJson(Map<String, dynamic> json) {
    return UserTipProgressModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      tipId: json['tip_id'] as String,
      isRead: json['is_read'] as bool? ?? false,
      isLiked: json['is_liked'] as bool? ?? false,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'tip_id': tipId,
      'is_read': isRead,
      'is_liked': isLiked,
      'is_bookmarked': isBookmarked,
      'read_at': readAt?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // Copy with
  UserTipProgressModel copyWith({
    String? id,
    String? userId,
    String? tipId,
    bool? isRead,
    bool? isLiked,
    bool? isBookmarked,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserTipProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tipId: tipId ?? this.tipId,
      isRead: isRead ?? this.isRead,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserTipProgressModel(tipId: $tipId, isRead: $isRead, isLiked: $isLiked, isBookmarked: $isBookmarked)';
  }
}
