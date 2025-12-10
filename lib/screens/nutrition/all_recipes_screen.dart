// lib/screens/nutrition/all_recipes_screen.dart

import 'package:flutter/material.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:powerhouse/models/recipe_model.dart';
import 'package:powerhouse/screens/nutrition/recipe_detail_screen.dart';
import 'package:powerhouse/services/nutrition_service.dart';
import 'package:powerhouse/widgets/skeleton_widgets.dart';

class AllRecipesScreen extends StatefulWidget {
  const AllRecipesScreen({super.key});

  @override
  State<AllRecipesScreen> createState() => _AllRecipesScreenState();
}

class _AllRecipesScreenState extends State<AllRecipesScreen>
    with SingleTickerProviderStateMixin {
  final _nutritionService = NutritionService();
  final _searchController = TextEditingController();

  List<RecipeModel> _allRecipes = [];
  List<RecipeModel> _filteredRecipes = [];
  bool _isLoading = true;

  // Filter states
  String _selectedCategory = 'All'; // All, Sri Lankan, Other
  String _selectedDifficulty = 'All'; // All, Easy, Medium, Hard

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadRecipes();
    _searchController.addListener(_filterRecipes);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final recipes = await _nutritionService.getRecipes(limit: 100);
      setState(() {
        _allRecipes = recipes;
        _filteredRecipes = recipes;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      print('❌ Error loading recipes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterRecipes() {
    setState(() {
      _filteredRecipes = _allRecipes.where((recipe) {
        // Search filter
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch =
            recipe.recipeName.toLowerCase().contains(searchQuery) ||
            (recipe.description?.toLowerCase().contains(searchQuery) ?? false);

        // Category filter
        final matchesCategory =
            _selectedCategory == 'All' ||
            (_selectedCategory == 'Sri Lankan' && recipe.isSriLankan) ||
            (_selectedCategory == 'Other' && !recipe.isSriLankan);

        // Difficulty filter
        final matchesDifficulty =
            _selectedDifficulty == 'All' ||
            recipe.difficulty.toLowerCase() ==
                _selectedDifficulty.toLowerCase();

        return matchesSearch && matchesCategory && matchesDifficulty;
      }).toList();
    });
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterRecipes();
  }

  void _onDifficultyChanged(String difficulty) {
    setState(() {
      _selectedDifficulty = difficulty;
    });
    _filterRecipes();
  }

  void _onRecipeTap(RecipeModel recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(recipe: recipe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadRecipes,
          color: context.primaryColor,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header
              _buildHeader(),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildSearchBar(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Filter Chips
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.primaryText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryFilters(),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Difficulty',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.primaryText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDifficultyFilters(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Results Count
              if (!_isLoading)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      '${_filteredRecipes.length} ${_filteredRecipes.length == 1 ? 'Recipe' : 'Recipes'} Found',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.secondaryText,
                      ),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Recipe Grid
              if (_isLoading)
                _buildLoadingSkeleton()
              else if (_filteredRecipes.isEmpty)
                _buildEmptyState()
              else
                _buildRecipeGrid(),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: context.surfaceColor,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.arrow_back, color: context.primaryColor, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              context.primaryColor,
              context.primaryColor.withOpacity(0.8),
            ],
          ).createShader(bounds),
          child: Text(
            'All Recipes',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ==================== SEARCH BAR ====================
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: context.primaryText, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search recipes...',
          hintStyle: TextStyle(color: context.secondaryText, fontSize: 16),
          prefixIcon: Icon(Icons.search, color: context.primaryColor, size: 24),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: context.secondaryText,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  // ==================== CATEGORY FILTERS ====================
  Widget _buildCategoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildFilterChip('All', _selectedCategory == 'All', () {
            _onCategoryChanged('All');
          }),
          const SizedBox(width: 12),
          _buildFilterChip('Sri Lankan', _selectedCategory == 'Sri Lankan', () {
            _onCategoryChanged('Sri Lankan');
          }, emoji: '🇱🇰'),
          const SizedBox(width: 12),
          _buildFilterChip('Other', _selectedCategory == 'Other', () {
            _onCategoryChanged('Other');
          }),
        ],
      ),
    );
  }

  // ==================== DIFFICULTY FILTERS ====================
  Widget _buildDifficultyFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildFilterChip('All', _selectedDifficulty == 'All', () {
            _onDifficultyChanged('All');
          }),
          const SizedBox(width: 12),
          _buildFilterChip('Easy', _selectedDifficulty == 'Easy', () {
            _onDifficultyChanged('Easy');
          }, color: Colors.green),
          const SizedBox(width: 12),
          _buildFilterChip('Medium', _selectedDifficulty == 'Medium', () {
            _onDifficultyChanged('Medium');
          }, color: Colors.orange),
          const SizedBox(width: 12),
          _buildFilterChip('Hard', _selectedDifficulty == 'Hard', () {
            _onDifficultyChanged('Hard');
          }, color: Colors.red),
        ],
      ),
    );
  }

  // ==================== FILTER CHIP ====================
  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap, {
    String? emoji,
    Color? color,
  }) {
    final chipColor = color ?? context.primaryColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withOpacity(0.15)
              : context.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? chipColor
                : context.borderColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: chipColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? chipColor : context.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== RECIPE GRID ====================
  Widget _buildRecipeGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: _buildRecipeCard(_filteredRecipes[index], index),
          );
        }, childCount: _filteredRecipes.length),
      ),
    );
  }

  // ==================== RECIPE CARD ====================
  Widget _buildRecipeCard(RecipeModel recipe, int index) {
    return GestureDetector(
      onTap: () => _onRecipeTap(recipe),
      child: Hero(
        tag: 'recipe_${recipe.recipeId}_$index',
        child: Container(
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: context.borderColor.withOpacity(0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: context.shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      color: context.primaryColor.withOpacity(0.1),
                      child: recipe.imageUrl != null
                          ? Image.network(
                              recipe.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.restaurant_menu,
                                    size: 40,
                                    color: context.primaryColor,
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Icon(
                                Icons.restaurant_menu,
                                size: 40,
                                color: context.primaryColor,
                              ),
                            ),
                    ),
                  ),

                  // Sri Lankan Badge
                  if (recipe.isSriLankan)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Text(
                          '🇱🇰',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),

                  // Difficulty Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(recipe.difficulty),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        recipe.difficulty,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Play Button
                  if (recipe.videoUrl != null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: context.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: context.primaryColor.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),

              // Recipe Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        recipe.recipeName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: context.primaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: context.secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${recipe.totalTime}m',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.secondaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.local_fire_department,
                            size: 12,
                            color: context.secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${recipe.caloriesPerServing}',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.secondaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== LOADING SKELETON ====================
  Widget _buildLoadingSkeleton() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const SkeletonCard(height: 240),
          childCount: 6,
        ),
      ),
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: context.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu,
                size: 60,
                color: context.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Recipes Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: context.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search',
              style: TextStyle(fontSize: 14, color: context.secondaryText),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                _onCategoryChanged('All');
                _onDifficultyChanged('All');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Clear Filters',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HELPER METHODS ====================
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return context.primaryColor;
    }
  }
}
