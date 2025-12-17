import 'package:flutter/material.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:powerhouse/models/models.dart';
import 'package:powerhouse/screens/tips/tips_library_screen.dart';
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
      backgroundColor: context.surfaceColor, // ✅ DARK MODE
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(),

            // Content
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: context.primaryColor, // ✅ DARK MODE
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                color: context.cardBackground, // ✅ DARK MODE
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.shadowColor, // ✅ DARK MODE
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: isDark
                    ? Border.all(
                        color: context.borderColor.withOpacity(0.3),
                        width: 1,
                      )
                    : null,
              ),
              child: Icon(
                Icons.arrow_back,
                color: context.primaryText, // ✅ DARK MODE
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Text(
              'Bookmarked Tips',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: context.primaryText, // ✅ DARK MODE
              ),
            ),
          ),

          // Bookmark Count Badge
          if (_bookmarkedTips.isNotEmpty && !_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.primaryColor.withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_bookmarkedTips.length}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.primaryColor, // ✅ DARK MODE
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_bookmarkedTips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty State Icon Container
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDark
                    ? context.primaryColor.withOpacity(0.1) // ✅ DARK MODE
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmark_border,
                size: 60,
                color: isDark
                    ? context.primaryColor.withOpacity(0.5) // ✅ DARK MODE
                    : Colors.grey.shade400,
              ),
            ),

            const SizedBox(height: 24),

            // Empty State Title
            Text(
              'No bookmarked tips yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: context.primaryText, // ✅ DARK MODE
              ),
            ),

            const SizedBox(height: 8),

            // Empty State Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Bookmark tips to save them for later!\nThey will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.secondaryText, // ✅ DARK MODE
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Browse Tips Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TipsLibraryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.explore_outlined),
              label: const Text('Browse Tips'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor, // ✅ DARK MODE
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: context.primaryColor, // ✅ DARK MODE
      backgroundColor: context.cardBackground, // ✅ DARK MODE
      child: Column(
        children: [
          // Optional: Info Banner
          _buildInfoBanner(),

          // Tips List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _bookmarkedTips.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Dismissible(
                    key: Key(_bookmarkedTips[index].id),
                    direction: DismissDirection.endToStart,
                    background: _buildDismissBackground(),
                    confirmDismiss: (direction) async {
                      return await _showRemoveConfirmation(
                        _bookmarkedTips[index],
                      );
                    },
                    onDismissed: (direction) {
                      _removeBookmark(_bookmarkedTips[index]);
                    },
                    child: TipCard(tip: _bookmarkedTips[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? context.primaryColor.withOpacity(0.1) // ✅ DARK MODE
            : const Color(0xFFE8F5F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.primaryColor.withOpacity(0.3), // ✅ DARK MODE
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.swipe_left_outlined,
            size: 20,
            color: context.primaryColor, // ✅ DARK MODE
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Swipe left to remove bookmark',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? context
                          .primaryColor // ✅ DARK MODE
                    : const Color(0xFF1DAB87),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_remove, color: Colors.white, size: 28),
          SizedBox(height: 4),
          Text(
            'Remove',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showRemoveConfirmation(TipModel tip) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardBackground, // ✅ DARK MODE
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Remove Bookmark?',
          style: TextStyle(
            color: context.primaryText, // ✅ DARK MODE
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to remove "${tip.title}" from your bookmarks?',
          style: TextStyle(
            color: context.secondaryText, // ✅ DARK MODE
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: context.secondaryText, // ✅ DARK MODE
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _removeBookmark(TipModel tip) async {
    try {
      await _tipsService.toggleBookmark(tip.id);
      setState(() {
        _bookmarkedTips.removeWhere((t) => t.id == tip.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Bookmark removed'),
            backgroundColor: context.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () async {
                await _tipsService.toggleBookmark(tip.id);
                _loadBookmarkedTips();
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('Error removing bookmark: $e');
    }
  }
}
