import 'package:flutter/material.dart';
import 'package:powerhouse/screens/nutrition/food_detail_screen.dart';

class AddFoodDialog extends StatefulWidget {
  final String mealType;

  const AddFoodDialog({
    Key? key,
    required this.mealType,
  }) : super(key: key);

  @override
  State<AddFoodDialog> createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<AddFoodDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  int _selectedTab = 0;
  bool _showSriLankanFoods = true;

  // Sample Sri Lankan food data
  final List<FoodItemData> _sriLankanFoods = [
    FoodItemData(
      name: 'Dhal Curry (Parippu)',
      description: 'Yellow lentil curry',
      calories: 180,
      protein: 12,
      fat: 8,
      carbs: 18,
      imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400',
    ),
    FoodItemData(
      name: 'White Rice (Sudu Bath)',
      description: 'Steamed white rice',
      calories: 400,
      protein: 8,
      fat: 2,
      carbs: 85,
      imageUrl: 'https://images.unsplash.com/photo-1516684732162-798a0062be99?w=400',
    ),
    FoodItemData(
      name: 'Chicken Kottu',
      description: 'Chopped roti with chicken',
      calories: 550,
      protein: 35,
      fat: 20,
      carbs: 65,
      imageUrl: 'https://images.unsplash.com/photo-1567337710282-00832b415979?w=400',
    ),
    FoodItemData(
      name: 'Pol Roti',
      description: 'Coconut flatbread',
      calories: 350,
      protein: 6,
      fat: 15,
      carbs: 48,
      imageUrl: 'https://images.unsplash.com/photo-1574894709920-11b28e7367e3?w=400',
    ),
    FoodItemData(
      name: 'String Hoppers',
      description: 'Rice noodle pancakes',
      calories: 180,
      protein: 4,
      fat: 1,
      carbs: 38,
      imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=400',
    ),
    FoodItemData(
      name: 'Chicken Curry',
      description: 'Spicy chicken curry',
      calories: 280,
      protein: 28,
      fat: 15,
      carbs: 10,
      imageUrl: 'https://images.unsplash.com/photo-1588166524941-3bf61a9c41db?w=400',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
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
          // Handle Bar
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
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
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

          // Quick Actions (Scan & Barcode)
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

          // Country Selector (for Search tab)
          if (_selectedTab == 0) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Country',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCountryCard(),
                  const SizedBox(height: 20),
                  const Text(
                    'Foods',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Food List
          Expanded(
            child: _buildFoodList(),
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
                  'https://images.unsplash.com/photo-1596040033229-a0b55b42eeb3?w=400',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 22),
          const Text(
            'Our Foods (Sri Lankan\nFoods)',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== FOOD LIST ====================
  Widget _buildFoodList() {
    final filteredFoods = _searchController.text.isEmpty
        ? _sriLankanFoods
        : _sriLankanFoods
            .where((food) => food.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredFoods.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildFoodItem(filteredFoods[index]),
        );
      },
    );
  }

  Widget _buildFoodItem(FoodItemData food) {
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
                image: DecorationImage(
                  image: NetworkImage(food.imageUrl),
                  fit: BoxFit.cover,
                ),
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
                    food.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${food.calories} cal',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  void _onScanMeal() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('📸 Scan Meal'),
        content: const Text(
          'AI meal scanning coming soon! Take a photo of your meal and we\'ll identify it automatically.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF1DAB87)),
            ),
          ),
        ],
      ),
    );
  }

  void _onScanBarcode() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('📱 Scan Barcode'),
        content: const Text(
          'Barcode scanning coming soon! Scan product barcodes to get nutritional information.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF1DAB87)),
            ),
          ),
        ],
      ),
    );
  }

  void _onFoodTap(FoodItemData food) {
    Navigator.pop(context); // Close dialog
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodDetailScreen(
          food: food,
          mealType: widget.mealType,
        ),
      ),
    );
  }
}

// ==================== DATA MODEL ====================
class FoodItemData {
  final String name;
  final String description;
  final int calories;
  final int protein;
  final int fat;
  final int carbs;
  final String imageUrl;

  FoodItemData({
    required this.name,
    required this.description,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.imageUrl,
  });
}