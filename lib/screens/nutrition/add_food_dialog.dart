import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:powerhouse/screens/nutrition/barcode_scanner_screen.dart';
import 'package:powerhouse/screens/nutrition/food_detail_screen.dart';
import 'package:powerhouse/screens/nutrition/scanned_food_dialog.dart';
import 'package:powerhouse/services/ai_meal_scanner_service.dart';
import 'package:powerhouse/services/nutrition_service.dart';
import 'package:powerhouse/models/food_item_model.dart';

class AddFoodDialog extends StatefulWidget {
  final String mealType;

  const AddFoodDialog({super.key, required this.mealType});

  @override
  State<AddFoodDialog> createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<AddFoodDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final _nutritionService = NutritionService();

  int _selectedTab = 0;
  List<FoodItemModel> _foods = [];
  List<FoodItemModel> _filteredFoods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });

    _loadFoods();
  }

  Future<void> _loadFoods() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load Sri Lankan foods for Search tab
      final foods = await _nutritionService.getSriLankanFoods();
      setState(() {
        _foods = foods;
        _filteredFoods = foods;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading foods: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterFoods(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFoods = _foods;
      } else {
        _filteredFoods = _foods
            .where(
              (food) =>
                  food.foodName.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 28),
                ),
                const SizedBox(width: 16),
                const Text(
                  "Add Today's Food",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(
                  color: Colors.black.withOpacity(0.5),
                  fontSize: 20,
                ),
                prefixIcon: const Icon(Icons.search, size: 26),
                filled: true,
                fillColor: const Color(0x99D9D9D9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterFoods,
            ),
          ),

          const SizedBox(height: 20),

          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                _buildTab('Search', 0),
                _buildTabDivider(),
                _buildTab('My Foods', 1),
                _buildTabDivider(),
                _buildTab('Recent', 2),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    Icons.camera_alt,
                    'Scan Meal',
                    () => _onScanMeal(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    Icons.qr_code_scanner,
                    'Barcode',
                    () => _onScanBarcode(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Country Selector
          if (_selectedTab == 0) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sri Lankan Foods',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _buildCountryCard(),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Food List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1DAB87)),
                  )
                : _buildFoodList(),
          ),
        ],
      ),
    );
  }

  // ==================== TAB ====================
  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? const Color(0xFF1DAB87) : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          if (isSelected)
            Container(
              width: title.length * 10.0,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF1DAB87),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabDivider() {
    return Container(
      width: 1,
      height: 21,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.black.withOpacity(0.2),
    );
  }

  // ==================== QUICK ACTION ====================
  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1DAB87).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1DAB87)),
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

  // ==================== COUNTRY CARD ====================
  Widget _buildCountryCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0x7FD9D9D9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 75,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/Flag_of_Sri_Lanka.svg/320px-Flag_of_Sri_Lanka.svg.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 22),
          const Text(
            'Our Foods (Sri Lankan\nFoods)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ==================== FOOD LIST ====================
  Widget _buildFoodList() {
    if (_filteredFoods.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isEmpty
              ? 'No foods available'
              : 'No foods found for "${_searchController.text}"',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredFoods.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildFoodItem(_filteredFoods[index]),
        );
      },
    );
  }

  Widget _buildFoodItem(FoodItemModel food) {
    return GestureDetector(
      onTap: () => _onFoodTap(food),
      child: Container(
        height: 75,
        decoration: BoxDecoration(
          color: const Color(0x7FD9D9D9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            // Food Image
            Container(
              width: 65,
              height: 61,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1DAB87).withOpacity(0.2),
              ),
              child: food.imageUrl != null
                  ? ClipOval(
                      child: Image.network(
                        food.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.restaurant,
                            color: Color(0xFF1DAB87),
                            size: 30,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.restaurant,
                      color: Color(0xFF1DAB87),
                      size: 30,
                    ),
            ),
            const SizedBox(width: 26),
            // Food Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    food.foodName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${food.calories} cal | P: ${food.protein.toInt()}g C: ${food.carbs.toInt()}g F: ${food.fat.toInt()}g',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF7E7E7E),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF7E7E7E),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  // ==================== HANDLERS ====================

  void _onScanMeal() async {
    try {
      final aiScanner = AIMealScannerService();

      // Show camera or gallery option
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Scan Meal'),
          content: const Text('Choose image source:'),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
            ),
          ],
        ),
      );

      if (source == null) return;

      // Store the navigator and scaffold messenger before closing dialog
      final navigator = Navigator.of(context);
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      // Close the add food dialog
      if (mounted) Navigator.pop(context);

      // Show loading dialog
      navigator.push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: Colors.black54,
            body: Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF1DAB87)),
                    SizedBox(height: 16),
                    Text(
                      'Analyzing your meal...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          fullscreenDialog: true,
        ),
      );

      // Scan meal
      List<FoodItemModel>? foods;
      try {
        foods = source == ImageSource.camera
            ? await aiScanner.scanMealFromCamera()
            : await aiScanner.scanMealFromGallery();
      } catch (e) {
        print('Error during scanning: $e');
        navigator.pop(); // Close loading
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error scanning: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Close loading
      navigator.pop();

      // If user cancelled, foods will be null - just return
      if (foods == null || foods.isEmpty) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('No food detected. Try again.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      print('✅ Successfully scanned ${foods.length} food item(s)');

      // Show detected foods
      if (foods.length == 1) {
        final result = await navigator.push(
          MaterialPageRoute(
            builder: (context) => ScannedFoodDialog(
              food: foods!.first,
              initialMealType: widget.mealType,
            ),
            fullscreenDialog: true,
          ),
        );

        // Show success message if food was added
        if (result == true) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Food added successfully!'),
              backgroundColor: Color(0xFF1DAB87),
            ),
          );
        }
      } else {
        // Multiple foods detected
        await navigator.push(
          MaterialPageRoute(
            builder: (context) => _MultipleDetectedFoodsScreen(
              foods: foods!, // Already checked for null above
              mealType: widget.mealType,
            ),
            fullscreenDialog: true,
          ),
        );
      }
    } catch (e) {
      print('❌ Error in _onScanMeal: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onScanBarcode() {
    Navigator.pop(context); // Close dialog

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScannerScreen(mealType: widget.mealType),
      ),
    );
  }

  void _onFoodTap(FoodItemModel food) async {
    Navigator.pop(context); // Close dialog
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FoodDetailScreen(food: food, mealType: widget.mealType),
      ),
    );

    // Refresh if food was added
    if (shouldRefresh == true && mounted) {
      _loadFoods();
    }
  }
}

// ==================== MULTIPLE DETECTED FOODS SCREEN ====================
class _MultipleDetectedFoodsScreen extends StatelessWidget {
  final List<FoodItemModel> foods;
  final String mealType;

  const _MultipleDetectedFoodsScreen({
    required this.foods,
    required this.mealType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detected Foods',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: foods.length,
        itemBuilder: (context, index) {
          final food = foods[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScannedFoodDialog(
                      food: food,
                      initialMealType: mealType,
                    ),
                    fullscreenDialog: true,
                  ),
                );

                if (result == true && context.mounted) {
                  Navigator.pop(context, true);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0x7FD9D9D9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    // Food icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1DAB87).withOpacity(0.2),
                      ),
                      child: food.localImagePath != null
                          ? ClipOval(
                              child: Image.file(
                                File(food.localImagePath!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.restaurant,
                              color: Color(0xFF1DAB87),
                              size: 30,
                            ),
                    ),
                    const SizedBox(width: 16),
                    // Food info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food.foodName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${food.calories} cal | P: ${food.protein.toInt()}g C: ${food.carbs.toInt()}g F: ${food.fat.toInt()}g',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF7E7E7E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFF7E7E7E),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
