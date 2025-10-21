import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:powerhouse/screens/nutrition/add_food_dialog.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({Key? key}) : super(key: key);

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  DateTime selectedDate = DateTime.now();

  // Daily targets
  final int targetCalories = 2000;
  final int targetCarbs = 500;
  final int targetFat = 50;
  final int targetProtein = 100;

  // Current consumed
  int consumedCalories = 1250;
  int consumedCarbs = 300;
  int consumedFat = 12;
  int consumedProtein = 76;

  // Calculate percentages
  double get calorieProgress => consumedCalories / targetCalories;
  double get carbsProgress => consumedCarbs / targetCarbs;
  double get fatProgress => consumedFat / targetFat;
  double get proteinProgress => consumedProtein / targetProtein;

  // Sample meal data
  final List<Meal> meals = [
    Meal(
      type: 'Breakfast',
      items: [
        FoodItem(name: 'Bread', amount: '1/2 Slice (1)', calories: 100),
      ],
    ),
    Meal(
      type: 'Lunch',
      items: [
        FoodItem(name: 'Rice', amount: '200g (1)', calories: 260),
        FoodItem(name: 'Dhal', amount: '1/2 cup (1)', calories: 120),
        FoodItem(name: 'Fish Curry', amount: '1 piece', calories: 180),
      ],
    ),
    Meal(
      type: 'Dinner',
      items: [
        FoodItem(name: 'Pol Roti', amount: 'piece (1)', calories: 150),
        FoodItem(name: 'Sambol', amount: '2 tbsp', calories: 80),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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
                    ...meals.map((meal) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildMealCard(meal),
                    )).toList(),
                    
                    const SizedBox(height: 16),
                    
                    // Recipe of the Day Section
                    _buildSectionTitle('Recipe of the Day', 'See all'),
                    
                    const SizedBox(height: 16),
                    
                    // Recipe Card
                    _buildRecipeCard(),
                    
                    const SizedBox(height: 100), // Space for FAB
                  ],
                ),
              ),
            ),
            
            // Floating Action Button (Add Food)
            Positioned(
              bottom: 20,
              right: 20,
              child: _buildAddButton(),
            ),
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
        const Text(
          'Nutrition',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        GestureDetector(
          onTap: () => _onProfileTap(),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF1DAB87),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/profile_male.png', // Path to your image
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to icon if image fails to load
                  return const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
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
        const Text(
          'Today',
          style: TextStyle(
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
    return Center(
      child: SizedBox(
        width: 200,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Donut Chart
            PieChart(
              PieChartData(
                startDegreeOffset: -90,
                sectionsSpace: 0,
                centerSpaceRadius: 70,
                sections: [
                  PieChartSectionData(
                    value: consumedCalories.toDouble(),
                    color: const Color(0xFF1DAB87),
                    radius: 20,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: (targetCalories - consumedCalories).toDouble(),
                    color: const Color(0xFFE0E0E0),
                    radius: 20,
                    showTitle: false,
                  ),
                ],
              ),
            ),
            
            // Center Text
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  consumedCalories.toString(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '🔥/$targetCalories kcal',
                  style: const TextStyle(
                    fontSize: 15,
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
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
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
  Widget _buildMealCard(Meal meal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0x21979797),
        ),
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
          Text(
            meal.type,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          
          // Food Items
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: meal.items.map((item) {
              return _buildFoodItem(item);
            }).toList(),
          ),
          
          // Add More Button
          if (meal.items.length < 4)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: GestureDetector(
                onTap: () => _onAddFoodToMeal(meal.type),
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
            ),
        ],
      ),
    );
  }

  // ==================== FOOD ITEM ====================
  Widget _buildFoodItem(FoodItem item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF1DAB87).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.restaurant,
            color: Color(0xFF1DAB87),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Text(
              item.amount,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7E7E7E),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== RECIPE CARD ====================
  Widget _buildRecipeCard() {
    return GestureDetector(
      onTap: () => _onRecipeTap(),
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0x21979797),
          ),
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
                    child: Image.network(
                      'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800',
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
                    ),
                  ),
                ),
                
                // Play Button
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
                  const Text(
                    'Chicken Fried Rice',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '🕒 20 min  🔥 350 kcal  💪 Easy',
                    style: TextStyle(
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

  // ==================== ADD BUTTON (FAB) ====================
  Widget _buildAddButton() {
    return FloatingActionButton(
      onPressed: () => _onAddFood(),
      backgroundColor: const Color(0xFF1DAB87),
      child: const Icon(
        Icons.add,
        size: 32,
        color: Colors.white,
      ),
    );
  }

  // ==================== HANDLERS ====================
  
  void _onProfileTap() {
    print('Profile tapped');
  }

  void _changeDate(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
    });
    print('Date changed to: ${DateFormat('yyyy-MM-dd').format(selectedDate)}');
  }

  void _onAddFood() {
  print('Add food tapped');
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const AddFoodDialog(
      mealType: 'Breakfast', // Or dynamically pass the meal type
    ),
  );
}

// Update _onAddFoodToMeal method:
void _onAddFoodToMeal(String mealType) {
  print('Add food to $mealType');
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AddFoodDialog(
      mealType: mealType,
    ),
  );
}

  void _onSeeAllRecipes() {
    print('See all recipes');
    // Navigate to recipes screen
  }

  void _onRecipeTap() {
    print('Recipe tapped');
    // Navigate to recipe detail
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1DAB87).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF1DAB87),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF1DAB87), size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1DAB87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFoodItem(String name, String calories) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1DAB87).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.restaurant,
              color: Color(0xFF1DAB87),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  calories,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7E7E7E),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.add_circle,
            color: Color(0xFF1DAB87),
          ),
        ],
      ),
    );
  }
}

// ==================== DATA MODELS ====================

class Meal {
  final String type;
  final List<FoodItem> items;

  Meal({
    required this.type,
    required this.items,
  });
}

class FoodItem {
  final String name;
  final String amount;
  final int calories;

  FoodItem({
    required this.name,
    required this.amount,
    required this.calories,
  });
}