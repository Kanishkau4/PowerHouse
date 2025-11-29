// lib/screens/nutrition/recipe_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart'; // ✅ ADD THIS
import 'package:powerhouse/models/recipe_model.dart';
import 'package:url_launcher/url_launcher.dart';

class RecipeDetailScreen extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceColor, // ✅
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Recipe Image
                  recipe.imageUrl != null
                      ? Image.network(
                          recipe.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: context.primaryColor.withOpacity(0.2),
                              child: Icon(
                                Icons.restaurant_menu,
                                size: 100,
                                color: context.primaryColor,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: context.primaryColor.withOpacity(0.2),
                          child: Icon(
                            Icons.restaurant_menu,
                            size: 100,
                            color: context.primaryColor,
                          ),
                        ),
                  // Gradient Overlay (unchanged — semantic)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (recipe.videoUrl != null)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.play_circle_fill, color: Colors.white),
                  ),
                  onPressed: () => _launchVideo(recipe.videoUrl!),
                ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.recipeName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: context.primaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (recipe.description != null)
                    Text(
                      recipe.description!,
                      style: TextStyle(
                        fontSize: 16,
                        color: context.secondaryText,
                      ),
                    ),
                  const SizedBox(height: 24),
                  _buildInfoRow(context),
                  const SizedBox(height: 32),
                  _buildNutritionInfo(context),
                  const SizedBox(height: 32),
                  Text(
                    'Ingredients',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: context.primaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...recipe.ingredients.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(
                              color: context.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: context.primaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
                  Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: context.primaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...recipe.instructions.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: context.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: context.primaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context) {
    return Row(
      children: [
        _buildInfoItem(context, Icons.schedule, '${recipe.totalTime} min'),
        const SizedBox(width: 20),
        _buildInfoItem(
          context,
          Icons.restaurant,
          '${recipe.servings} servings',
        ),
        const SizedBox(width: 20),
        _buildInfoItem(
          context,
          Icons.trending_up,
          recipe.difficulty,
          color: _getDifficultyColor(recipe.difficulty),
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String text, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? context.primaryColor),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color ?? context.primaryText, // ✅ adaptive
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.primaryColor.withOpacity(0.1), // ✅
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nutrition (per serving)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutritionItem(
                context,
                'Calories',
                '${recipe.caloriesPerServing}',
                'kcal',
                Icons.local_fire_department,
              ),
              _buildNutritionItem(
                context,
                'Protein',
                '${recipe.proteinPerServing.toInt()}',
                'g',
                Icons.eco,
              ),
              _buildNutritionItem(
                context,
                'Carbs',
                '${recipe.carbsPerServing.toInt()}',
                'g',
                Icons.grain,
              ),
              _buildNutritionItem(
                context,
                'Fat',
                '${recipe.fatPerServing.toInt()}',
                'g',
                Icons.water_drop,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionItem(
    BuildContext context,
    String label,
    String value,
    String unit,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24, color: context.primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: context.primaryText,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 12,
            color: context.secondaryText, // ✅
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.primaryText,
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(String difficulty) {
    // Keep these as-is — they’re semantic (not theme-dependent)
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return const Color(0xFF1DAB87);
    }
  }

  Future<void> _launchVideo(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
