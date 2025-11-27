class TipModel {
  final String tipId;
  final String title;
  final String category;
  final String content;
  final String? summary;
  final String? imageUrl;
  final String? videoUrl;
  final String? difficultyLevel;
  final int readingTime;
  final bool isFeatured;
  final int viewCount;
  final int likeCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  TipModel({
    required this.tipId,
    required this.title,
    required this.category,
    required this.content,
    this.summary,
    this.imageUrl,
    this.videoUrl,
    this.difficultyLevel,
    this.readingTime = 3,
    this.isFeatured = false,
    this.viewCount = 0,
    this.likeCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // From JSON (Supabase response)
  factory TipModel.fromJson(Map<String, dynamic> json) {
    return TipModel(
      tipId: json['tip_id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      content: json['content'] as String,
      summary: json['summary'] as String?,
      imageUrl: json['image_url'] as String?,
      videoUrl: json['video_url'] as String?,
      difficultyLevel: json['difficulty_level'] as String?,
      readingTime: json['reading_time'] as int? ?? 3,
      isFeatured: json['is_featured'] as bool? ?? false,
      viewCount: json['view_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'tip_id': tipId,
      'title': title,
      'category': category,
      'content': content,
      'summary': summary,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'difficulty_level': difficultyLevel,
      'reading_time': readingTime,
      'is_featured': isFeatured,
      'view_count': viewCount,
      'like_count': likeCount,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // Helper: Get reading time text
  String get readingTimeText {
    if (readingTime == 1) return '1 min read';
    return '$readingTime min read';
  }

  // Helper: Get difficulty badge color
  String get difficultyColor {
    switch (difficultyLevel?.toLowerCase()) {
      case 'beginner':
        return '#4CAF50'; // Green
      case 'intermediate':
        return '#FF9800'; // Orange
      case 'advanced':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Gray
    }
  }

  // Helper: Has media content
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  bool get hasMedia => hasImage || hasVideo;

  // Copy with
  TipModel copyWith({
    String? tipId,
    String? title,
    String? category,
    String? content,
    String? summary,
    String? imageUrl,
    String? videoUrl,
    String? difficultyLevel,
    int? readingTime,
    bool? isFeatured,
    int? viewCount,
    int? likeCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TipModel(
      tipId: tipId ?? this.tipId,
      title: title ?? this.title,
      category: category ?? this.category,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      readingTime: readingTime ?? this.readingTime,
      isFeatured: isFeatured ?? this.isFeatured,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TipModel(tipId: $tipId, title: $title, category: $category)';
  }
}
