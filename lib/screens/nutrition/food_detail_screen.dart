// lib/screens/nutrition/food_detail_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;
import 'package:powerhouse/models/food_item_model.dart';
import 'package:powerhouse/services/nutrition_service.dart';
import 'package:powerhouse/screens/achievements/badge_unlock_screen.dart';
import 'package:powerhouse/models/badge_model.dart';
import 'package:powerhouse/widgets/animated_message.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodItemModel food;
  final String mealType;
  final bool isScannedFood; // NEW: Flag to identify scanned foods

  const FoodDetailScreen({
    super.key,
    required this.food,
    required this.mealType,
    this.isScannedFood = false, // Default to false for existing foods
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen>
    with SingleTickerProviderStateMixin {
  final _nutritionService = NutritionService();

  String _selectedServingSize = 'Serving';
  int _quantity = 1;
  bool _isSaving = false;
  late String _selectedMealType;

  final List<String> _servingSizes = ['Serving', 'Spoon', 'Cup', 'Plate'];
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.mealType;
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
      backgroundColor: context.surfaceColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // Header with scanned indicator
                  _buildHeader(),
                  const SizedBox(height: 10),

                  // Food Image
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.primaryColor.withOpacity(0.2),
                      boxShadow: [
                        BoxShadow(
                          color: context.shadowColor,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: _buildFoodImage(),
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

  // ==================== HEADER ====================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.inputBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.borderColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back,
                size: 24,
                color: context.primaryText,
              ),
            ),
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                'Log Food',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: context.primaryText,
                ),
              ),
              // Show AI Scanned badge for scanned foods
              if (widget.isScannedFood)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.primaryColor.withOpacity(0.2),
                        context.primaryColor.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: context.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'AI Scanned',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: context.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 40), // Balance the back button
        ],
      ),
    );
  }

  // ==================== FOOD IMAGE ====================
  Widget _buildFoodImage() {
    // Priority: imageUrl (network) > localImagePath (file) > icon (fallback)
    if (widget.food.imageUrl != null && widget.food.imageUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          widget.food.imageUrl!,
          fit: BoxFit.cover,
          width: 300,
          height: 300,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
                color: context.primaryColor,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('❌ Error loading network image: $error');
            return _buildFallbackIcon();
          },
        ),
      );
    } else if (widget.food.localImagePath != null &&
        widget.food.localImagePath!.isNotEmpty) {
      final file = File(widget.food.localImagePath!);
      if (file.existsSync()) {
        return ClipOval(
          child: Image.file(
            file,
            fit: BoxFit.cover,
            width: 300,
            height: 300,
            errorBuilder: (context, error, stackTrace) {
              print('❌ Error loading local image: $error');
              return _buildFallbackIcon();
            },
          ),
        );
      }
    }

    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.isScannedFood ? Icons.camera_alt : Icons.restaurant,
            size: 80,
            color: context.primaryColor,
          ),
          if (widget.isScannedFood) ...[
            const SizedBox(height: 8),
            Text(
              'Scanned Food',
              style: TextStyle(
                fontSize: 14,
                color: context.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
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
                        backgroundColor: context.cardBackground,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 66,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: context.primaryText,
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
                  child: const Center(
                    child: Icon(
                      Icons.local_fire_department,
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
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: context.primaryText,
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
        color: context.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        border: Border.all(
          color: context.borderColor.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: context.shadowColor,
            blurRadius: 4,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Name
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.food.foodName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: context.primaryText,
                    ),
                  ),
                ),
                if (widget.food.isSriLankan)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('🇱🇰', style: TextStyle(fontSize: 16)),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Serving Description
            Text(
              widget.food.servingSizeDescription ?? 'Per serving',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: context.secondaryText,
              ),
            ),
            const SizedBox(height: 24),

            // Meal Type Selector
            Text(
              'Meal Type',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: context.primaryText,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _mealTypes.map((type) {
                final isSelected = _selectedMealType == type;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMealType = type;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 21,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.primaryColor
                          : context.inputBackground,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected
                            ? context.primaryColor
                            : context.borderColor.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: context.primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : context.primaryText,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Serving Size Selector
            Text(
              'Serving Size',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: context.primaryText,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _servingSizes.map((size) {
                final isSelected = _selectedServingSize == size;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedServingSize = size;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 21,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.primaryColor
                          : context.inputBackground,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected
                            ? context.primaryColor
                            : context.borderColor.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: context.primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      size,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : context.primaryText,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Quantity Selector
            _buildQuantitySelector(),
            const SizedBox(height: 32),

            // Add to Meal Button
            _buildAddButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ==================== QUANTITY SELECTOR ====================
  Widget _buildQuantitySelector() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Decrease Button
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
                color: context.inputBackground,
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.borderColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.remove,
                size: 24,
                color: _quantity > 1
                    ? context.primaryText
                    : context.secondaryText,
              ),
            ),
          ),
          const SizedBox(width: 32),

          // Quantity Display
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: context.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _quantity.toString(),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _selectedServingSize,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 32),

          // Increase Button
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
              decoration: BoxDecoration(
                color: context.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 24, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ADD BUTTON ====================
  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _onAddToMeal,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.primaryColor,
          disabledBackgroundColor: context.primaryColor.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Add to $_selectedMealType',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
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
      print('🔍 Is scanned food: ${widget.isScannedFood}');
      print('🔍 Food ID: ${widget.food.foodId}');
      print('🔍 Image URL: ${widget.food.imageUrl}');
      print('🔍 Local Image Path: ${widget.food.localImagePath}');

      // Save to database
      // KEY FIX: Pass scannedFood parameter for scanned items
      final result = await _nutritionService.logFood(
        foodId: widget.food.foodId,
        mealType: _selectedMealType,
        quantity: _quantity.toDouble(),
        servingUnit: _selectedServingSize,
        scannedFood: widget.isScannedFood
            ? widget.food
            : null, // THIS IS THE KEY FIX!
      );

      print('✅ Food logged successfully');
      print('🏆 XP gained: ${result['xp_added']}');

      // Show success message
      if (mounted) {
        AnimatedMessage.show(
          context,
          message:
              'Added $_quantity x ${widget.food.foodName} (+${result['xp_added']} XP)',
          backgroundColor: context.primaryColor,
          icon: Icons.check_circle_rounded,
        );
      }

      // Check for level up
      if (result['leveled_up'] == true && mounted) {
        await _showLevelUpDialog(result['current_level']);
      }

      // Show badge unlock animations for newly earned badges
      if (result['new_badges'] != null &&
          (result['new_badges'] as List).isNotEmpty) {
        final newBadges = (result['new_badges'] as List)
            .map((badgeData) => BadgeModel.fromJson(badgeData))
            .toList();

        // Wait a bit after level up dialog
        await Future.delayed(const Duration(milliseconds: 500));

        // Show each badge unlock screen
        for (final badge in newBadges) {
          if (mounted) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BadgeUnlockScreen(badge: badge),
              ),
            );
          }
        }
      }

      // Navigate back to nutrition screen with refresh signal
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context, true); // Pass true to signal refresh needed
      }
    } catch (e) {
      print('❌ Error saving food: $e');
      if (mounted) {
        AnimatedMessage.show(
          context,
          message: 'Failed to log food: ${e.toString()}',
          backgroundColor: Colors.red,
          icon: Icons.error_rounded,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ==================== LEVEL UP DIALOG ====================
  Future<void> _showLevelUpDialog(int newLevel) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Stack(
        children: [
          // Dialog content
          Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: context.cardBackground,
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
                  Text(
                    'LEVEL UP!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: context.primaryColor,
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
                      gradient: LinearGradient(
                        colors: [
                          context.primaryColor,
                          context.primaryColor.withOpacity(0.8),
                        ],
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
                  Text(
                    'Keep crushing your goals! 💪',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: context.secondaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Action button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
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

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    // Draw progress arc
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
      -math.pi / 2, // Start from top
      progress * 2 * math.pi, // Progress amount
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(NutritionDonutPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
