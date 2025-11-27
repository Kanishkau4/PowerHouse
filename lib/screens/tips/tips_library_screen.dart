import 'package:flutter/material.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:powerhouse/models/models.dart';
import 'package:powerhouse/services/tips_service.dart';
import 'package:powerhouse/widgets/tips/category_chip.dart';
import 'package:powerhouse/widgets/tips/tip_card.dart';

class TipsLibraryScreen extends StatefulWidget {
  const TipsLibraryScreen({super.key});

  @override
  State<TipsLibraryScreen> createState() => _TipsLibraryScreenState();
}

class _TipsLibraryScreenState extends State<TipsLibraryScreen> {
  final _tipsService = TipsService();

  List<TipCategoryModel> _categories = [];
  List<TipModel> _allTips = [];
  List<TipModel> _filteredTips = [];

  String? _selectedCategory; // null means "All"
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final categories = await _tipsService.getCategories();
      final tips = await _tipsService.getAllTips();

      setState(() {
        _categories = categories;
        _allTips = tips;
        _filteredTips = tips;
      });
    } catch (e) {
      print('Error loading tips library data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterByCategory(String? category) {
    setState(() {
      _selectedCategory = category;

      if (category == null) {
        // Show all tips
        _filteredTips = _allTips;
      } else {
        // Filter by category
        _filteredTips = _allTips
            .where((tip) => tip.category == category)
            .toList();
      }
    });
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(),

            // Category Filter Chips
            if (!_isLoading) _buildCategoryFilters(),

            // Tips List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1DAB87),
                      ),
                    )
                  : _buildTipsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.surfaceColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back, color: context.primaryText),
            ),
          ),

          const SizedBox(width: 16),

          // Title
          Text(
            'Tips Library',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: context.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          // "All" Chip
          CategoryChip(
            isAllCategory: true,
            isSelected: _selectedCategory == null,
            onTap: () => _filterByCategory(null),
          ),

          const SizedBox(width: 8),

          // Category Chips
          ..._categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CategoryChip(
                category: category,
                isSelected: _selectedCategory == category.name,
                onTap: () => _filterByCategory(category.name),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTipsList() {
    if (_filteredTips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tips_and_updates_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No tips available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new content!',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: const Color(0xFF1DAB87),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: _filteredTips.length,
        itemBuilder: (context, index) {
          return TipCard(tip: _filteredTips[index]);
        },
      ),
    );
  }
}
