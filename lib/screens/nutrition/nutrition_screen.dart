// lib/screens/nutrition/nutrition_screen.dart

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

import 'package:powerhouse/widgets/animated_message.dart';
import 'package:powerhouse/widgets/skeleton_widgets.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final _nutritionService = NutritionService();
  UserModel? _userProfile;

  DateTime selectedDate = DateTime.now();

  // Daily targets (these could come from user settings)
  int targetCalories = 2000;
  int targetCarbs = 250;
  int targetFat = 50;
  int targetProtein = 100;

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
      print('📊 Snack items: ${mealsByType['Snack']!.length}');
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
        // Update targets based on user profile if available
        if (profile != null) {
          _updateNutritionTargets(profile);
        }
      });
    } catch (e) {
      print('❌ Error loading user profile: $e');
    }
  }

  void _updateNutritionTargets(UserModel profile) {
    // You can customize targets based on user's fitness goal
    switch (profile.fitnessGoal?.toLowerCase()) {
      case 'lose weight':
        targetCalories = 1800;
        targetCarbs = 200;
        targetFat = 45;
        targetProtein = 120;
        break;
      case 'build muscle':
        targetCalories = 2500;
        targetCarbs = 300;
        targetFat = 60;
        targetProtein = 150;
        break;
      case 'maintain':
      default:
        targetCalories = 2000;
        targetCarbs = 250;
        targetFat = 50;
        targetProtein = 100;
    }
  }

  // Calculate percentages
  double get calorieProgress =>
      (consumedCalories / targetCalories).clamp(0.0, 1.0);
  double get carbsProgress => (consumedCarbs / targetCarbs).clamp(0.0, 1.0);
  double get fatProgress => (consumedFat / targetFat).clamp(0.0, 1.0);
  double get proteinProgress =>
      (consumedProtein / targetProtein).clamp(0.0, 1.0);

  // Check if date is today
  bool get _isToday =>
      DateFormat('yyyy-MM-dd').format(selectedDate) ==
      DateFormat('yyyy-MM-dd').format(DateTime.now());

  // Get remaining calories
  int get _remainingCalories =>
      (targetCalories - consumedCalories).clamp(0, targetCalories);

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

                      if (_isLoading) ...[
                        // Calorie Chart Skeleton
                        const Center(child: SkeletonCircle(size: 220)),
                        const SizedBox(height: 24),

                        // Macros Breakdown Skeleton
                        Row(
                          children: const [
                            Expanded(child: SkeletonMacroCard()),
                            SizedBox(width: 12),
                            Expanded(child: SkeletonMacroCard()),
                            SizedBox(width: 12),
                            Expanded(child: SkeletonMacroCard()),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Meals Section Header Skeleton
                        const SkeletonText(width: 150, height: 20),
                        const SizedBox(height: 16),

                        // Meal Cards Skeleton
                        ...List.generate(
                          4,
                          (index) => const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: SkeletonCard(height: 120),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Recipe Section Header Skeleton
                        const SkeletonText(width: 180, height: 20),
                        const SizedBox(height: 16),

                        // Recipe Cards Skeleton
                        ...List.generate(
                          3,
                          (index) => const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: SkeletonCard(height: 100),
                          ),
                        ),
                      ] else ...[
                        // Calorie Donut Chart
                        _buildCalorieChart(),
                        const SizedBox(height: 24),

                        // Macros Breakdown
                        _buildMacrosBreakdown(),
                        const SizedBox(height: 32),

                        // Today's Meals Section
                        _buildSectionTitle(
                          _isToday ? "Today's Meals" : "Meals",
                          '',
                        ),
                        const SizedBox(height: 16),

                        // Meal Cards (ORIGINAL DESIGN)
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutrition',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: context.primaryText,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _onProfileTap(),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1DAB87), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1DAB87).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: _userProfile?.profilePictureUrl != null
                  ? Image.network(
                      _userProfile!.profilePictureUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildProfileFallback();
                      },
                    )
                  : _buildProfileFallback(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileFallback() {
    return Image.asset(
      'assets/images/profile_male.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFF1DAB87),
          child: const Icon(Icons.person, color: Colors.white, size: 30),
        );
      },
    );
  }

  // ==================== DATE SELECTOR ====================
  Widget _buildDateSelector() {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    String getDateLabel(DateTime date) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      if (dateOnly == todayDate) return 'Today';
      if (dateOnly == todayDate.subtract(const Duration(days: 1))) {
        return 'Yesterday';
      }
      if (dateOnly == todayDate.add(const Duration(days: 1))) return 'Tomorrow';
      return DateFormat('MMM dd').format(date);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.cardBackground, // ✅
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.shadowColor, // ✅
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Day
          GestureDetector(
            onTap: () => _changeDate(-1),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.borderColor.withOpacity(0.3), // ✅
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.chevron_left,
                color: context.secondaryText, // ✅
                size: 24,
              ),
            ),
          ),
          // Current Date
          GestureDetector(
            onTap: () => _showDatePicker(),
            child: Column(
              children: [
                Text(
                  getDateLabel(selectedDate),
                  style: TextStyle(
                    color: context.primaryColor, // ✅
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  DateFormat('EEEE, MMM dd').format(selectedDate),
                  style: TextStyle(
                    color: context.secondaryText, // ✅
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Next Day
          GestureDetector(
            onTap: () => _changeDate(1),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.borderColor.withOpacity(0.3), // ✅
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.chevron_right,
                color: context.secondaryText, // ✅
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 7)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1DAB87),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _loadData();
    }
  }

  // ==================== CALORIE DONUT CHART ====================
  Widget _buildCalorieChart() {
    final progress = calorieProgress;
    final isOverTarget = consumedCalories > targetCalories;

    return Center(
      child: SizedBox(
        width: 220,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // PieChart for the main ring
            PieChart(
              PieChartData(
                startDegreeOffset: -90,
                sectionsSpace: 0,
                centerSpaceRadius: 80,
                sections: [
                  PieChartSectionData(
                    value: consumedCalories.toDouble().clamp(
                      0,
                      targetCalories.toDouble(),
                    ),
                    color: isOverTarget
                        ? Colors.orange
                        : const Color(0xFF1DAB87),
                    radius: 20,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: (targetCalories - consumedCalories).toDouble().clamp(
                      0,
                      targetCalories.toDouble(),
                    ),
                    color: const Color(0xFFC8E6DD),
                    radius: 20,
                    showTitle: false,
                  ),
                ],
              ),
            ),

            // Donut Chart with custom painter for dot indicator
            CustomPaint(
              size: const Size(220, 220),
              painter: _DonutChartPainter(progress.clamp(0.0, 1.0)),
            ),

            // Center Text
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  consumedCalories.toString(),
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: isOverTarget ? Colors.orange : context.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '🔥 / $targetCalories kcal',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF7E7E7E),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isOverTarget
                        ? Colors.orange.withOpacity(0.1)
                        : const Color(0xFF1DAB87).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isOverTarget
                        ? '+${consumedCalories - targetCalories} over'
                        : '$_remainingCalories left',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isOverTarget
                          ? Colors.orange
                          : const Color(0xFF1DAB87),
                    ),
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
    final isOver = consumed > target;

    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: context.primaryText.withOpacity(0.8)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.primaryText.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: context.cardBackground, // ✅ background adapts
              borderRadius: BorderRadius.circular(20),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: isOver ? Colors.orange : progressColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$consumed / $target$unit',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isOver ? Colors.orange.shade700 : context.primaryText,
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF15223).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                actionText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF15223),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ==================== MEAL CARD (ORIGINAL DESIGN) ====================
  Widget _buildMealCard(String mealType) {
    final mealItems = mealsByType[mealType] ?? [];
    final mealCalories = mealItems.fold<int>(
      0,
      (sum, item) => sum + (item['calories'] as int),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.borderColor.withOpacity(0.15), // ✅
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.shadowColor,
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.primaryText,
                ),
              ),
              if (mealItems.isNotEmpty)
                Text(
                  '$mealCalories kcal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.primaryColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (mealItems.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No items added',
                  style: TextStyle(fontSize: 14, color: context.secondaryText),
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
          GestureDetector(
            onTap: () => _onAddFoodToMeal(mealType),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, color: context.primaryColor, size: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  'Add item',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.primaryColor,
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

  // ==================== FOOD ITEM (ORIGINAL DESIGN) ====================
  Widget _buildFoodItem(Map<String, dynamic> item) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: context.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: item['image_url'] != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item['image_url'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.restaurant,
                        color: context.primaryColor,
                        size: 24,
                      );
                    },
                  ),
                )
              : Icon(Icons.restaurant, color: context.primaryColor, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['food_name'],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: context.primaryText,
                ),
              ),
              Text(
                '${item['quantity']} ${item['serving_unit']} • ${item['calories']} kcal',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: context.secondaryText,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.delete_outline,
            size: 20,
            color: Colors.red,
          ), // keep red for delete
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
                      ),
                      child: const Text('🇱🇰', style: TextStyle(fontSize: 16)),
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
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: context.primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildRecipeTag(
                        Icons.access_time,
                        '${recipe.totalTime} min',
                      ),
                      const SizedBox(width: 12),
                      _buildRecipeTag(
                        Icons.local_fire_department,
                        '${recipe.caloriesPerServing} kcal',
                      ),
                      const SizedBox(width: 12),
                      _buildRecipeTag(Icons.fitness_center, recipe.difficulty),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeTag(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: context.secondaryText),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: context.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildNoRecipesMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(Icons.restaurant_menu, size: 60, color: context.dividerColor),
            const SizedBox(height: 16),
            Text(
              'No recipes available',
              style: TextStyle(fontSize: 16, color: context.primaryText),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for delicious recipes!',
              style: TextStyle(fontSize: 12, color: context.secondaryText),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ADD BUTTON (FAB) ====================
  Widget _buildAddButton() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1DAB87).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _onAddFood(),
        backgroundColor: const Color(0xFF1DAB87),
        icon: const Icon(Icons.add, size: 24, color: Colors.white),
        label: const Text(
          'Add Food',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ==================== HANDLERS ====================
  void _onProfileTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    ).then((_) {
      _loadData();
    });
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
        AnimatedMessage.show(
          context,
          message: 'Food item removed',
          backgroundColor: const Color(0xFF1DAB87),
          icon: Icons.check_circle_rounded,
        );
        _loadData();
      } catch (e) {
        AnimatedMessage.show(
          context,
          message: 'Error: ${e.toString()}',
          backgroundColor: Colors.red,
          icon: Icons.error_rounded,
        );
      }
    }
  }

  void _onSeeAllRecipes() {
    AnimatedMessage.show(
      context,
      message: 'Recipes screen coming soon!',
      backgroundColor: const Color(0xFF1DAB87),
      icon: Icons.info_rounded,
    );
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
    final radius = 90.0;

    final angle = -90 + (360 * progress);
    final radians = angle * (pi / 180);

    final dotX = center.dx + radius * cos(radians);
    final dotY = center.dy + radius * sin(radians);

    // Draw outer glow
    final glowPaint = Paint()
      ..color = const Color(0xFF1DAB87).withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(dotX, dotY), 14, glowPaint);

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
