class FoodItemModel {
  final String foodId;
  final String foodName;
  final String? servingSizeDescription;
  final int calories;
  final double protein; // grams
  final double carbs; // grams
  final double fat; // grams
  final bool isSriLankan;
  final String? imageUrl;
  final String? localImagePath; // Path to locally scanned image
  final DateTime createdAt;

  FoodItemModel({
    required this.foodId,
    required this.foodName,
    this.servingSizeDescription,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.isSriLankan = false,
    this.imageUrl,
    this.localImagePath,
    required this.createdAt,
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      foodId: json['food_id'] as String,
      foodName: json['food_name'] as String,
      servingSizeDescription: json['serving_size_description'] as String?,
      calories: json['calories'] as int,
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      isSriLankan: json['is_sri_lankan'] as bool? ?? false,
      imageUrl: json['image_url'] as String?,
      localImagePath: json['local_image_path'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food_id': foodId,
      'food_name': foodName,
      'serving_size_description': servingSizeDescription,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'is_sri_lankan': isSriLankan,
      'image_url': imageUrl,
      'local_image_path': localImagePath,
    };
  }

  // Helper methods
  double get totalMacros => protein + carbs + fat;
  double get proteinPercentage => (protein * 4 / calories) * 100;
  double get carbsPercentage => (carbs * 4 / calories) * 100;
  double get fatPercentage => (fat * 9 / calories) * 100;
}
