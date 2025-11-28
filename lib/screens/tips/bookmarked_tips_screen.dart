import 'package:flutter/material.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:powerhouse/models/models.dart';
import 'package:powerhouse/services/tips_service.dart';
import 'package:powerhouse/widgets/tips/tip_card.dart';

class BookmarkedTipsScreen extends StatefulWidget {
  const BookmarkedTipsScreen({super.key});
  @override
  State<BookmarkedTipsScreen> createState() => _BookmarkedTipsScreenState();
}

class _BookmarkedTipsScreenState extends State<BookmarkedTipsScreen> {
  final _tipsService = TipsService();
  List<TipModel> _bookmarkedTips = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadBookmarkedTips();
  }

  Future<void> _loadBookmarkedTips() async {
    setState(() => _isLoading = true);

    try {
      final tips = await _tipsService.getBookmarkedTips();
      setState(() {
        _bookmarkedTips = tips;
      });
    } catch (e) {
      print('Error loading bookmarked tips: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    await _loadBookmarkedTips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceColor,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(),
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1DAB87),
                      ),
                    )
                  : _buildContent(),
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
          Text(
            'Bookmarked Tips',
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

  Widget _buildContent() {
    if (_bookmarkedTips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No bookmarked tips yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bookmark tips to save them for later!',
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
        itemCount: _bookmarkedTips.length,
        itemBuilder: (context, index) {
          return TipCard(tip: _bookmarkedTips[index]);
        },
      ),
    );
  }
}
