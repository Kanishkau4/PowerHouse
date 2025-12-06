// lib/screens/nutrition/add_food_dialog.dart

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:powerhouse/models/food_item_model.dart';
import 'package:powerhouse/services/nutrition_service.dart';
import 'package:powerhouse/services/ai_meal_scanner_service.dart';
import 'package:powerhouse/screens/nutrition/food_detail_screen.dart';
import 'package:powerhouse/widgets/animated_message.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';

class AddFoodDialog extends StatefulWidget {
  final String mealType;

  const AddFoodDialog({super.key, required this.mealType});

  @override
  State<AddFoodDialog> createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<AddFoodDialog>
    with SingleTickerProviderStateMixin {
  final _nutritionService = NutritionService();
  final _aiScannerService = AIMealScannerService();
  final _searchController = TextEditingController();

  late TabController _tabController;

  List<FoodItemModel> _sriLankanFoods = [];
  List<FoodItemModel> _otherFoods = [];
  List<FoodItemModel> _searchResults = [];

  bool _isLoading = true;
  bool _isSearching = false;
  bool _isScanning = false;
  bool _showBarcodeScanner = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFoods();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFoods() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _nutritionService.getSriLankanFoods(),
        _nutritionService.getNonSriLankanFoods(),
      ]);

      setState(() {
        _sriLankanFoods = results[0];
        _otherFoods = results[1];
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading foods: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchFoods(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await _nutritionService.searchFoods(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      print('❌ Error searching foods: $e');
      setState(() => _isSearching = false);
    }
  }

  Future<void> _scanMeal({required bool fromCamera}) async {
    setState(() => _isScanning = true);

    try {
      final foods = fromCamera
          ? await _aiScannerService.scanMealFromCamera()
          : await _aiScannerService.scanMealFromGallery();

      if (foods != null && foods.isNotEmpty && mounted) {
        Navigator.pop(context); // Close dialog

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailScreen(
              food: foods.first,
              mealType: widget.mealType,
              isScannedFood: true,
            ),
          ),
        );
      }
    } catch (e) {
      AnimatedMessage.show(
        context,
        message: 'Error scanning meal: ${e.toString()}',
        backgroundColor: Colors.red,
        icon: Icons.error_rounded,
      );
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isNotEmpty) {
      final String? barcode = barcodes.first.rawValue;

      if (barcode != null) {
        setState(() => _showBarcodeScanner = false);
        _searchFoodByBarcode(barcode);
      }
    }
  }

  Future<void> _searchFoodByBarcode(String barcode) async {
    print('🔍 Searching for barcode: $barcode');

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 12),
            Text('Searching for barcode: $barcode'),
          ],
        ),
        backgroundColor: context.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );

    // TODO: Implement barcode search in your database or API
    // For now, show a message that barcode was detected
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Barcode detected: $barcode\nProduct search coming soon!',
          ),
          backgroundColor: context.accentColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showBarcodeScanner) {
      return _buildBarcodeScanner();
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add to ${widget.mealType}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: context.primaryText,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: context.primaryText),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: _searchFoods,
              style: TextStyle(color: context.primaryText),
              decoration: InputDecoration(
                hintText: 'Search foods...',
                hintStyle: TextStyle(color: context.secondaryText),
                prefixIcon: Icon(Icons.search, color: context.primaryColor),
                filled: true,
                fillColor: context.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: context.borderColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: context.primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Scan Buttons Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // AI Scan Camera
                Expanded(
                  child: _buildScanButton(
                    icon: Icons.camera_alt,
                    label: 'AI Scan',
                    color: context.primaryColor,
                    onTap: () => _scanMeal(fromCamera: true),
                  ),
                ),
                const SizedBox(width: 8),

                // Gallery
                Expanded(
                  child: _buildScanButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    color: context.primaryColor,
                    onTap: () => _scanMeal(fromCamera: false),
                  ),
                ),
                const SizedBox(width: 8),

                // Barcode Scanner
                Expanded(
                  child: _buildScanButton(
                    icon: Icons.qr_code_scanner,
                    label: 'Barcode',
                    color: context.accentColor,
                    onTap: () {
                      setState(() => _showBarcodeScanner = true);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: context.inputBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.borderColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: context.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: context.secondaryText,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/sri_lanka_flag.png',
                        width: 20,
                        height: 20,
                        errorBuilder: (_, __, ___) => const Text('🇱🇰'),
                      ),
                      const SizedBox(width: 8),
                      const Text('Sri Lankan'),
                    ],
                  ),
                ),
                const Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, size: 20),
                      SizedBox(width: 8),
                      Text('My Foods'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Content
          Expanded(
            child: _isScanning
                ? _buildScanningIndicator()
                : _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: context.primaryColor,
                    ),
                  )
                : _searchController.text.isNotEmpty
                ? _buildSearchResults()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildFoodList(_sriLankanFoods),
                      _buildFoodList(_otherFoods),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isScanning ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarcodeScanner() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.black, // Keep black for camera preview
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scan Barcode',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => _showBarcodeScanner = false);
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),

          // Scanner
          Expanded(
            child: Stack(
              children: [
                MobileScanner(onDetect: _onBarcodeDetected),

                // Scan overlay
                Center(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      border: Border.all(color: context.primaryColor, width: 3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 60,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Position barcode within frame',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom hint
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
            child: const Text(
              'Scan product barcode to quickly add food',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: context.primaryColor),
          const SizedBox(height: 24),
          Text(
            '🤖 AI is analyzing your meal...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: context.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a few seconds',
            style: TextStyle(fontSize: 14, color: context.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return Center(
        child: CircularProgressIndicator(color: context.primaryColor),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: context.secondaryText.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No foods found',
              style: TextStyle(fontSize: 16, color: context.secondaryText),
            ),
            const SizedBox(height: 8),
            Text(
              'Try scanning your meal with AI instead!',
              style: TextStyle(
                fontSize: 12,
                color: context.secondaryText.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return _buildFoodList(_searchResults);
  }

  Widget _buildFoodList(List<FoodItemModel> foods) {
    if (foods.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 60,
              color: context.secondaryText.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No foods available',
              style: TextStyle(fontSize: 16, color: context.secondaryText),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: foods.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: context.dividerColor),
      itemBuilder: (context, index) {
        final food = foods[index];
        return _buildFoodTile(food);
      },
    );
  }

  Widget _buildFoodTile(FoodItemModel food) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: context.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: food.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  food.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.restaurant, color: context.primaryColor),
                ),
              )
            : Icon(Icons.restaurant, color: context.primaryColor),
      ),
      title: Text(
        food.foodName,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: context.primaryText,
        ),
      ),
      subtitle: Text(
        '${food.calories} kcal • P: ${food.protein.toInt()}g • C: ${food.carbs.toInt()}g • F: ${food.fat.toInt()}g',
        style: TextStyle(fontSize: 12, color: context.secondaryText),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.add, color: context.primaryColor, size: 20),
      ),
      onTap: () {
        Navigator.pop(context); // Close dialog
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailScreen(
              food: food,
              mealType: widget.mealType,
              isScannedFood: false,
            ),
          ),
        );
      },
    );
  }
}
