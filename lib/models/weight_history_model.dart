class WeightHistoryModel {
  final String id;
  final String userId;
  final double weight;
  final DateTime recordedAt;
  final DateTime createdAt;

  WeightHistoryModel({
    required this.id,
    required this.userId,
    required this.weight,
    required this.recordedAt,
    required this.createdAt,
  });

  factory WeightHistoryModel.fromJson(Map<String, dynamic> json) {
    return WeightHistoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      weight: json['weight'] != null
          ? double.parse(json['weight'].toString())
          : 0.0,
      recordedAt: DateTime.parse(json['recorded_at']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'weight': weight,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'WeightHistoryModel(id: $id, weight: $weight, recordedAt: $recordedAt)';
  }
}
