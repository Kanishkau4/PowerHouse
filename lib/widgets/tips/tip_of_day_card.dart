import 'package:flutter/material.dart';
import 'package:powerhouse/models/models.dart';
import 'package:powerhouse/screens/tips/tip_detail_screen.dart';

class TipOfDayCard extends StatefulWidget {
  final TipModel? tip;
  final bool isLoading;
  final VoidCallback? onSeeAllTapped;

  const TipOfDayCard({
    super.key,
    this.tip,
    this.isLoading = false,
    this.onSeeAllTapped,
  });

  @override
  State<TipOfDayCard> createState() => _TipOfDayCardState();
}

class _TipOfDayCardState extends State<TipOfDayCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconRotation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _navigateToDetail() {
    if (widget.tip != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TipDetailScreen(tip: widget.tip!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingCard();
    }

    if (widget.tip == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _isExpanded ? _navigateToDetail : _toggleExpanded,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6366F1).withOpacity(0.8),
              const Color(0xFF8B5CF6).withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.lightbulb, color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Tip of the Day',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                // Expand/Collapse or See All
                if (!_isExpanded && widget.onSeeAllTapped != null)
                  GestureDetector(
                    onTap: widget.onSeeAllTapped,
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  )
                else
                  RotationTransition(
                    turns: _iconRotation,
                    child: GestureDetector(
                      onTap: _toggleExpanded,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Tip Title
            Text(
              widget.tip!.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
              ),
              maxLines: _isExpanded ? null : 1,
              overflow: _isExpanded ? null : TextOverflow.ellipsis,
            ),

            // Expandable Content
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _isExpanded
                  ? _buildExpandedContent()
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        // Tip Summary
        if (widget.tip!.summary != null)
          Text(
            widget.tip!.summary!,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

        const SizedBox(height: 16),

        // Bottom Row: Category and Reading Time
        Row(
          children: [
            // Category Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _getCategoryDisplayName(widget.tip!.category),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Reading Time
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  widget.tip!.readingTimeText,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),

            const Spacer(),

            // Arrow Icon
            const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      height: 90,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.3),
            const Color(0xFF8B5CF6).withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'exercise':
        return 'Exercise Tips';
      case 'nutrition':
        return 'Nutrition';
      case 'wisdom':
        return 'Daily Wisdom';
      case 'myth':
        return 'Myth Busting';
      case 'recovery':
        return 'Recovery';
      case 'lifestyle':
        return 'Lifestyle';
      default:
        return category;
    }
  }
}
