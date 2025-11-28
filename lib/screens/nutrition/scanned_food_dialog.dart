import 'dart:io';
import 'package:flutter/material.dart';
import 'package:powerhouse/models/food_item_model.dart';
import 'package:powerhouse/services/nutrition_service.dart';

class ScannedFoodDialog extends StatefulWidget {
  final FoodItemModel food;
  final String initialMealType;

  const ScannedFoodDialog({
    super.key,
    required this.food,
    required this.initialMealType,
  });

  @override
  State<ScannedFoodDialog> createState() => _ScannedFoodDialogState();
}

class _ScannedFoodDialogState extends State<ScannedFoodDialog> {
  final _nutritionService = NutritionService();

  late String _selectedMealType;
  final String _selectedServingSize = 'Serving';
  int _quantity = 1;
  bool _isSaving = false;

  final List<String> _servingSizes = ['Serving', 'Spoon', 'Cup', 'Plate'];
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.initialMealType;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Scanned Food',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scanned Image
                    if (widget.food.localImagePath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(widget.food.localImagePath!),
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Food Name
                    Text(
                      widget.food.foodName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Serving Size Description
                    if (widget.food.servingSizeDescription != null)
                      Text(
                        widget.food.servingSizeDescription!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7E7E7E),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Nutrition Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNutritionItem(
                            '${widget.food.calories}',
                            'Calories',
                            Colors.orange,
                          ),
                          _buildNutritionItem(
                            '${widget.food.protein.toInt()}g',
                            'Protein',
                            Colors.blue,
                          ),
                          _buildNutritionItem(
                            '${widget.food.carbs.toInt()}g',
                            'Carbs',
                            Colors.green,
                          ),
                          _buildNutritionItem(
                            '${widget.food.fat.toInt()}g',
                            'Fat',
                            Colors.red,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Meal Type Selector
                    const Text(
                      'Meal Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _mealTypes.map((type) {
                        final isSelected = _selectedMealType == type;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMealType = type;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF1DAB87)
                                  : const Color(0xFFE0E0E0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Quantity Selector
                    const Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          color: const Color(0xFF1DAB87),
                        ),
                        Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _quantity++),
                          icon: const Icon(Icons.add_circle_outline),
                          color: const Color(0xFF1DAB87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Add Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _onAddToMeal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1DAB87),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Add to $_selectedMealType',
                                style: const TextStyle(
                                  fontSize: 18,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF7E7E7E)),
        ),
      ],
    );
  }

  Future<void> _onAddToMeal() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await _nutritionService.logFood(
        foodId: widget.food.foodId,
        mealType: _selectedMealType,
        quantity: _quantity.toDouble(),
        servingUnit: _selectedServingSize,
        scannedFood: widget.food, // Pass the scanned food data
      );

      if (mounted) {
        Navigator.pop(context, true); // Return true to signal success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added to $_selectedMealType!'),
            backgroundColor: const Color(0xFF1DAB87),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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
}
