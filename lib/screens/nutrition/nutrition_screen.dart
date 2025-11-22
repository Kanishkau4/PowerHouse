import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:intl/intl.dart';
import 'package:powerhouse/screens/nutrition/add_food_dialog.dart';
import 'package:powerhouse/screens/nutrition/recipe_detail_screen.dart';
import 'package:powerhouse/screens/profile/profile_screen.dart';
import 'package:powerhouse/services/nutrition_service.dart';
import 'package:powerhouse/models/recipe_model.dart';
import 'package:powerhouse/models/user_model.dart';
import 'package:powerhouse/services/user_service.dart';
import 'dart:math';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final _nutritionService = NutritionService();
  UserModel? _userProfile;

  DateTime selectedDate = DateTime.now();

  // Daily targets
  final int targetCalories = 2000;
  final int targetCarbs = 250;
  final int targetFat = 50;
  final int targetProtein = 100;

  // Current consumed (will be fetched from database)
  int consumedCalories = 0;
  int consumedCarbs = 0;
  int consumedFat = 0;
  int consumedProtein = 0;

  // Meal logs grouped by meal type
  Map<String, List<Map<String, dynamic>>> mealsByType = {
    'Breakfast': [],
    'Lunch': [],
    'Dinner': [],
    'Snack': [],
  };

  // Recipes
  List<RecipeModel> recipes = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.wait([_loadFoodLogs(), _loadRecipes(), _loadUserProfile()]);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadFoodLogs() async {
    try {
      print(
        '📦 Loading food logs for ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
      );

      // Get food logs for selected date
      final logs = await _nutritionService.getFoodLogsByDate(selectedDate);

      print('✅ Loaded ${logs.length} food logs');

      // Reset consumed values
      consumedCalories = 0;
      consumedCarbs = 0;
      consumedFat = 0;
      consumedProtein = 0;

      // Reset meals
      mealsByType = {'Breakfast': [], 'Lunch': [], 'Dinner': [], 'Snack': []};

      // Group logs by meal type and calculate totals
      for (var log in logs) {
        final mealType = log['meal_type'] as String;
        final quantity = (log['quantity'] as num).toDouble();
        final food = log['foods'];

        if (food != null) {
          // Calculate nutrition for this log
          final logCalories = ((food['calories'] as int) * quantity).round();
          final logProtein = ((food['protein'] as num).toDouble() * quantity);
          final logCarbs = ((food['carbs'] as num).toDouble() * quantity);
          final logFat = ((food['fat'] as num).toDouble() * quantity);

          // Add to totals
          consumedCalories += logCalories;
          consumedProtein += logProtein.round();
          consumedCarbs += logCarbs.round();
          consumedFat += logFat.round();

          // Add to meal type group
          if (mealsByType.containsKey(mealType)) {
            mealsByType[mealType]!.add({
              'log_id': log['log_id'],
              'food_name': food['food_name'],
              'quantity': quantity,
              'serving_unit': log['serving_unit'],
              'calories': logCalories,
              'image_url': food['image_url'],
            });
          }
        }
      }

      print('📊 Total calories: $consumedCalories');
      print('📊 Breakfast items: ${mealsByType['Breakfast']!.length}');
      print('📊 Lunch items: ${mealsByType['Lunch']!.length}');
      print('📊 Dinner items: ${mealsByType['Dinner']!.length}');
    } catch (e) {
      print('❌ Error loading food logs: $e');
    }
  }

  Future<void> _loadRecipes() async {
    try {
      print('📦 Loading recipes...');
      final loadedRecipes = await _nutritionService.getSriLankanRecipes(
        limit: 5,
      );

      setState(() {
        recipes = loadedRecipes;
      });

      print('✅ Loaded ${recipes.length} recipes');
    } catch (e) {
      print('❌ Error loading recipes: $e');
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await UserService().getCurrentUserProfile();
      setState(() {
        _userProfile = profile;
      });
    } catch (e) {
      print('❌ Error loading user profile: $e');
      // Optionally set a default or leave as null
    }
  }

  // Calculate percentages
  double get calorieProgress =>
      (consumedCalories / targetCalories).clamp(0.0, 1.0);
  double get carbsProgress => (consumedCarbs / targetCarbs).clamp(0.0, 1.0);
  double get fatProgress => (consumedFat / targetFat).clamp(0.0, 1.0);
  double get proteinProgress =>
      (consumedProtein / targetProtein).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceColor,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFF1DAB87),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Header
                      _buildHeader(),

                      const SizedBox(height: 16),

                      // Date Selector
                      _buildDateSelector(),

                      const SizedBox(height: 24),

                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFF1DAB87),
                            ),
                          ),
                        )
                      else ...[
                        // Calorie Donut Chart
                        _buildCalorieChart(),

                        const SizedBox(height: 24),

                        // Macros Breakdown
                        _buildMacrosBreakdown(),

                        const SizedBox(height: 32),

                        // Today's Meals Section
                        _buildSectionTitle('Today\'s Meals', ''),

                        const SizedBox(height: 16),

                        // Meal Cards
                        ...['Breakfast', 'Lunch', 'Dinner', 'Snack'].map((
                          mealType,
                        ) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildMealCard(mealType),
                          );
                        }),

                        const SizedBox(height: 16),

                        // Recipe of the Day Section
                        _buildSectionTitle('Recipe of the Day', 'See all'),

                        const SizedBox(height: 16),

                        // Recipe Cards
                        if (recipes.isEmpty)
                          _buildNoRecipesMessage()
                        else
                          ...recipes.take(3).map((recipe) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildRecipeCard(recipe),
                            );
                          }),
                      ],

                      const SizedBox(height: 100), // Space for FAB
                    ],
                  ),
                ),
              ),
            ),

            // Floating Action Button (Add Food)
            Positioned(bottom: 20, right: 20, child: _buildAddButton()),
          ],
        ),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Nutrition',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: context.primaryText,
          ),
        ),
        GestureDetector(
          onTap: () => _onProfileTap(),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1DAB87), width: 2),
            ),
            child: ClipOval(
              child: _userProfile?.profilePictureUrl != null
                  ? Image.network(
                      _userProfile!.profilePictureUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF1DAB87),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      'assets/images/profile_male.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF1DAB87),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== DATE SELECTOR ====================
  Widget _buildDateSelector() {
    final isToday =
        DateFormat('yyyy-MM-dd').format(selectedDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => _changeDate(-1),
          child: const Text(
            '<  Yesterday  |  ',
            style: TextStyle(
              color: Color(0xFF7E7E7E),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          isToday ? 'Today' : DateFormat('MMM dd').format(selectedDate),
          style: const TextStyle(
            color: Color(0xFF1DAB87),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        GestureDetector(
          onTap: () => _changeDate(1),
          child: const Text(
            '  |  Tomorrow  >',
            style: TextStyle(
              color: Color(0xFF7E7E7E),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== CALORIE DONUT CHART ====================
  Widget _buildCalorieChart() {
    final progress = calorieProgress;

    return Center(
      child: SizedBox(
        width: 200,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // PieChart for the main ring
            PieChart(
              PieChartData(
                startDegreeOffset: -90,
                sectionsSpace: 0,
                centerSpaceRadius: 75,
                sections: [
                  PieChartSectionData(
                    value: consumedCalories.toDouble(),
                    color: const Color(0xFF1DAB87),
                    radius: 18,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: (targetCalories - consumedCalories).toDouble().clamp(
                      0,
                      targetCalories.toDouble(),
                    ),
                    color: const Color(0xFFC8E6DD),
                    radius: 18,
                    showTitle: false,
                  ),
                ],
              ),
            ),

            // Donut Chart with custom painter for dot indicator
            CustomPaint(
              size: const Size(200, 200),
              painter: _DonutChartPainter(progress),
            ),

            // Center Text
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  consumedCalories.toString(),
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: context.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '🔥/$targetCalories kcal',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF7E7E7E),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== MACROS BREAKDOWN ====================
  Widget _buildMacrosBreakdown() {
    return Row(
      children: [
        Expanded(
          child: _buildMacroCard(
            'Carbs',
            consumedCarbs,
            targetCarbs,
            'g',
            const Color(0xFFFFBC86),
            const Color(0xFFFE8017),
            Icons.bakery_dining,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMacroCard(
            'Fat',
            consumedFat,
            targetFat,
            'g',
            const Color(0xFF78C9FF),
            const Color(0xFF26A5FC),
            Icons.water_drop,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMacroCard(
            'Protein',
            consumedProtein,
            targetProtein,
            'g',
            const Color(0xFF21B371),
            const Color(0xFF1D9B63),
            Icons.egg,
          ),
        ),
      ],
    );
  }

  // ==================== MACRO CARD ====================
  Widget _buildMacroCard(
    String name,
    int consumed,
    int target,
    String unit,
    Color bgColor,
    Color progressColor,
    IconData icon,
  ) {
    final progress = (consumed / target).clamp(0.0, 1.0);

    return Container(
      height: 96,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.black),
              const SizedBox(width: 6),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Progress Bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$consumed$unit',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7E7E7E),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SECTION TITLE ====================
  Widget _buildSectionTitle(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: context.primaryText,
          ),
        ),
        if (actionText.isNotEmpty)
          GestureDetector(
            onTap: () => _onSeeAllRecipes(),
            child: Text(
              actionText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF15223),
              ),
            ),
          ),
      ],
    );
  }

  // ==================== MEAL CARD ====================
  Widget _buildMealCard(String mealType) {
    final mealItems = mealsByType[mealType] ?? [];
    final mealCalories = mealItems.fold<int>(
      0,
      (sum, item) => sum + (item['calories'] as int),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x21979797)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mealType,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              if (mealItems.isNotEmpty)
                Text(
                  '$mealCalories kcal',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1DAB87),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Food Items
          if (mealItems.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No items added',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ),
            )
          else
            Column(
              children: mealItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildFoodItem(item),
                );
              }).toList(),
            ),

          // Add More Button
          GestureDetector(
            onTap: () => _onAddFoodToMeal(mealType),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1DAB87).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF1DAB87),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Add item',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1DAB87),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== FOOD ITEM ====================
  Widget _buildFoodItem(Map<String, dynamic> item) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF1DAB87).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: item['image_url'] != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item['image_url'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.restaurant,
                        color: Color(0xFF1DAB87),
                        size: 24,
                      );
                    },
                  ),
                )
              : const Icon(
                  Icons.restaurant,
                  color: Color(0xFF1DAB87),
                  size: 24,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['food_name'],
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '${item['quantity']} ${item['serving_unit']} • ${item['calories']} kcal',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7E7E7E),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
          onPressed: () => _onDeleteFoodItem(item['log_id']),
        ),
      ],
    );
  }

  // ==================== RECIPE CARD ====================
  Widget _buildRecipeCard(RecipeModel recipe) {
    return GestureDetector(
      onTap: () => _onRecipeTap(recipe),
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x21979797)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
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
                    height: 120,
                    width: double.infinity,
                    color: const Color(0xFF1DAB87).withOpacity(0.3),
                    child: recipe.imageUrl != null
                        ? Image.network(
                            recipe.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.restaurant_menu,
                                  size: 50,
                                  color: Color(0xFF1DAB87),
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(
                              Icons.restaurant_menu,
                              size: 50,
                              color: Color(0xFF1DAB87),
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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1DAB87),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1DAB87).withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),

            // Recipe Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.recipeName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '🕒 ${recipe.totalTime} min  🔥 ${recipe.caloriesPerServing} kcal  💪 ${recipe.difficulty}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF7E7E7E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoRecipesMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(Icons.restaurant_menu, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No recipes available',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ADD BUTTON (FAB) ====================
  Widget _buildAddButton() {
    return FloatingActionButton(
      onPressed: () => _onAddFood(),
      backgroundColor: const Color(0xFF1DAB87),
      child: const Icon(Icons.add, size: 32, color: Colors.white),
    );
  }

  // ==================== HANDLERS ====================

  void _onProfileTap() {
    print('Profile tapped');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  void _changeDate(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
    });
    _loadData();
  }

  void _onAddFood() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddFoodDialog(mealType: 'Breakfast'),
    ).then((_) {
      // Refresh data when dialog closes
      _loadData();
    });
  }

  void _onAddFoodToMeal(String mealType) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddFoodDialog(mealType: mealType),
    );

    // Refresh data when dialog closes
    if (mounted) {
      _loadData();
    }
  }

  Future<void> _onDeleteFoodItem(String logId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Food'),
        content: const Text('Are you sure you want to remove this food item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _nutritionService.deleteFoodLog(logId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Food item removed'),
            backgroundColor: Color(0xFF1DAB87),
          ),
        );
        _loadData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onSeeAllRecipes() {
    print('See all recipes');
    // TODO: Navigate to recipes list screen
  }

  void _onRecipeTap(RecipeModel recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(recipe: recipe),
      ),
    );
  }
}

// ==================== CUSTOM PAINTER FOR DONUT CHART INDICATOR ====================
class _DonutChartPainter extends CustomPainter {
  final double progress;

  _DonutChartPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 84.0; // Radius to the middle of the ring (75 + 18/2 = 84)

    // Calculate the angle for the progress (starting from top, going clockwise)
    final angle = -90 + (360 * progress); // -90 to start from top
    final radians = angle * (pi / 180);

    // Calculate position of the dot
    final dotX = center.dx + radius * cos(radians);
    final dotY = center.dy + radius * sin(radians);

    // Draw the circular indicator dot
    final paint = Paint()
      ..color = const Color(0xFF1DAB87)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(dotX, dotY), 10, paint);

    // Draw white border around the dot
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(Offset(dotX, dotY), 10, borderPaint);
  }

  @override
  bool shouldRepaint(_DonutChartPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
