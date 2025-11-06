import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;
import 'package:powerhouse/models/food_item_model.dart';
import 'package:powerhouse/services/nutrition_service.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodItemModel food;
  final String mealType;

  const FoodDetailScreen({
    super.key,
    required this.food,
    required this.mealType,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen>
    with SingleTickerProviderStateMixin {
  final _nutritionService = NutritionService();
  
  String _selectedServingSize = 'Spoon';
  int _quantity = 1;
  bool _isSaving = false;

  final List<String> _servingSizes = ['Spoon', 'Cup', 'Plate'];

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Calculate nutrition based on quantity
  int get _totalCalories => (widget.food.calories * _quantity).toInt();
  int get _totalProtein => (widget.food.protein * _quantity).toInt();
  int get _totalFat => (widget.food.fat * _quantity).toInt();
  int get _totalCarbs => (widget.food.carbs * _quantity).toInt();

  // Calculate progress (assuming daily targets)
  double get _caloriesProgress => (_totalCalories / 2000).clamp(0.0, 1.0);
  double get _proteinProgress => (_totalProtein / 100).clamp(0.0, 1.0);
  double get _fatProgress => (_totalFat / 50).clamp(0.0, 1.0);
  double get _carbsProgress => (_totalCarbs / 250).clamp(0.0, 1.0);

  IconData _getNutritionIcon(String label) {
    switch (label) {
      case 'Kcal':
        return Icons.local_fire_department;
      case 'Protein':
        return Icons.eco;
      case 'Fat':
        return Icons.water_drop;
      case 'Carbs':
        return Icons.grain;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back, size: 28),
                        ),
                        const Spacer(),
                        const Text(
                          'Log Food',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 28),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Food Image
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1DAB87).withOpacity(0.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: widget.food.imageUrl != null
                        ? ClipOval(
                            child: Image.network(
                              widget.food.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.restaurant,
                                  size: 100,
                                  color: Color(0xFF1DAB87),
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.restaurant,
                            size: 100,
                            color: Color(0xFF1DAB87),
                          ),
                  ),

                  // Nutrition Bars
                  _buildNutritionBars(),

                  const SizedBox(height: 32),

                  // Bottom Sheet
                  _buildBottomSheet(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== NUTRITION BARS ====================
  Widget _buildNutritionBars() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildNutritionBar(
            label: 'Kcal',
            value: _totalCalories.toString(),
            color: const Color(0xFF9786FF),
            progress: _caloriesProgress,
            height: 116,
          ),
          _buildNutritionBar(
            label: 'Protein',
            value: '${_totalProtein}g',
            color: const Color(0xFF20B271),
            progress: _proteinProgress,
            height: 116,
          ),
          _buildNutritionBar(
            label: 'Fat',
            value: '${_totalFat}g',
            color: const Color(0xFF78C9FF),
            progress: _fatProgress,
            height: 116,
          ),
          _buildNutritionBar(
            label: 'Carbs',
            value: '${_totalCarbs}g',
            color: const Color(0xFFFFBC86),
            progress: _carbsProgress,
            height: 116,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionBar({
    required String label,
    required String value,
    required Color color,
    required double progress,
    required double height,
  }) {
    return Column(
      children: [
        Container(
          width: 74,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(35),
              topRight: Radius.circular(35),
            ),
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 13,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(53, 53),
                      painter: NutritionDonutPainter(
                        progress: progress * _animationController.value,
                        color: color,
                        backgroundColor: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 66,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              Positioned(
                top: 21,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _getNutritionIcon(label),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 86,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== BOTTOM SHEET ====================
  Widget _buildBottomSheet() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        border: Border.all(color: Colors.black.withOpacity(0.1), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.food.foodName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              widget.food.servingSizeDescription ?? 'Per serving',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7E7E7E),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Serving Size',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),

            // Serving Size Options
            Wrap(
              spacing: 12,
              children: _servingSizes.map((size) {
                final isSelected = _selectedServingSize == size;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedServingSize = size;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 21,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xE01DAB87)
                          : const Color(0xFFD7D7D7),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      size,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF0B4536)
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Quantity Selector
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_quantity > 1) {
                        setState(() {
                          _quantity--;
                        });
                        _animationController.forward(from: 0);
                      }
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.remove, size: 24),
                    ),
                  ),
                  const SizedBox(width: 32),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1DAB87),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1DAB87).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _quantity.toString(),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _quantity++;
                      });
                      _animationController.forward(from: 0);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1DAB87),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Add to Meal Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _onAddToMeal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DAB87),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Add to ${widget.mealType}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ==================== SAVE TO DATABASE ====================
  Future<void> _onAddToMeal() async {
    setState(() {
      _isSaving = true;
    });

    try {
      print('💾 Logging food to database...');

      // Save to database
      final result = await _nutritionService.logFood(
        foodId: widget.food.foodId,
        mealType: widget.mealType,
        quantity: _quantity.toDouble(),
        servingUnit: _selectedServingSize,
      );

      print('✅ Food logged successfully');
      print('🏆 XP gained: ${result['xp_added']}');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '✅ Added $_quantity x ${widget.food.foodName} (+${result['xp_added']} XP)',
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1DAB87),
          duration: const Duration(seconds: 2),
        ),
      );

      // Check for level up
      if (result['leveled_up'] == true) {
        _showLevelUpDialog(result['current_level']);
      }

      // Navigate back to nutrition screen
      await Future.delayed(const Duration(milliseconds: 500));
      // Pop back to the nutrition screen instead of going to the first route
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('❌ Error saving food: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to log food: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showLevelUpDialog(int newLevel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        children: [
          // Dialog content
          Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Star/Trophy Lottie Animation
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Lottie.asset(
                      'assets/animations/Star.json',
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Title
                  const Text(
                    '🎉 LEVEL UP! 🎉',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1DAB87),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Level info
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1DAB87), Color(0xFF2DD4A3)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'You are now Level $newLevel!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Motivational message
                  const Text(
                    'Keep crushing your goals!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF7E7E7E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Action button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1DAB87),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Awesome!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Confetti Lottie Animation (Full screen overlay)
          Positioned.fill(
            child: IgnorePointer(
              child: Lottie.asset(
                'assets/animations/Confetti.json',
                fit: BoxFit.cover,
                repeat: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== NUTRITION DONUT PAINTER ====================
class NutritionDonutPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  NutritionDonutPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 6.0;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    canvas.drawArc(
      rect,
      -math.pi / 2,
      progress * 2 * math.pi,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(NutritionDonutPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}