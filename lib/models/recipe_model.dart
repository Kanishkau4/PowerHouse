class RecipeModel {
  final String recipeId;
  final String recipeName;
  final String? description;
  final int prepTime; // minutes
  final int cookTime; // minutes
  final String difficulty; // Easy, Medium, Hard
  final int servings;
  final int caloriesPerServing;
  final double proteinPerServing;
  final double carbsPerServing;
  final double fatPerServing;
  final List<String> ingredients;
  final List<String> instructions;
  final String? imageUrl;
  final String? videoUrl;
  final bool isSriLankan;
  final String? cuisine;
  final DateTime createdAt;

  RecipeModel({
    required this.recipeId,
    required this.recipeName,
    this.description,
    required this.prepTime,
    required this.cookTime,
    required this.difficulty,
    required this.servings,
    required this.caloriesPerServing,
    required this.proteinPerServing,
    required this.carbsPerServing,
    required this.fatPerServing,
    required this.ingredients,
    required this.instructions,
    this.imageUrl,
    this.videoUrl,
    this.isSriLankan = false,
    this.cuisine,
    required this.createdAt,
  });

  int get totalTime => prepTime + cookTime;

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      recipeId: json['recipe_id'] as String,
      recipeName: json['recipe_name'] as String,
      description: json['description'] as String?,
      prepTime: json['prep_time'] as int,
      cookTime: json['cook_time'] as int,
      difficulty: json['difficulty'] as String,
      servings: json['servings'] as int,
      caloriesPerServing: json['calories_per_serving'] as int,
      proteinPerServing: (json['protein_per_serving'] as num).toDouble(),
      carbsPerServing: (json['carbs_per_serving'] as num).toDouble(),
      fatPerServing: (json['fat_per_serving'] as num).toDouble(),
      ingredients: List<String>.from(json['ingredients'] as List),
      instructions: List<String>.from(json['instructions'] as List),
      imageUrl: json['image_url'] as String?,
      videoUrl: json['video_url'] as String?,
      isSriLankan: json['is_sri_lankan'] as bool? ?? false,
      cuisine: json['cuisine'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipe_id': recipeId,
      'recipe_name': recipeName,
      'description': description,
      'prep_time': prepTime,
      'cook_time': cookTime,
      'difficulty': difficulty,
      'servings': servings,
      'calories_per_serving': caloriesPerServing,
      'protein_per_serving': proteinPerServing,
      'carbs_per_serving': carbsPerServing,
      'fat_per_serving': fatPerServing,
      'ingredients': ingredients,
      'instructions': instructions,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'is_sri_lankan': isSriLankan,
      'cuisine': cuisine,
      'created_at': createdAt.toIso8601String(),
    };
  }
}