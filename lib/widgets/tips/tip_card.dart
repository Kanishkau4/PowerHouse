import 'package:flutter/material.dart';
import 'package:powerhouse/models/models.dart';
import 'package:powerhouse/screens/tips/tip_detail_screen.dart';

class TipCard extends StatelessWidget {
  final TipModel tip;
  final bool showBookmark;

  const TipCard({super.key, required this.tip, this.showBookmark = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TipDetailScreen(tip: tip)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section (if available)
            if (tip.hasImage)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  tip.imageUrl!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderImage();
                  },
                ),
              )
            else
              _buildPlaceholderImage(),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    tip.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Summary
                  if (tip.summary != null)
                    Text(
                      tip.summary!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7E7E7E),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 12),

                  // Bottom Row: Category, Reading Time, Views
                  Row(
                    children: [
                      // Category Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getCategoryColor(),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _getCategoryDisplayName(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getCategoryColor(),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Reading Time
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tip.readingTimeText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const Spacer(),

                      // View Count
                      if (tip.viewCount > 0) ...[
                        Icon(
                          Icons.visibility,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatViewCount(tip.viewCount),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _getCategoryColor().withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Center(
        child: Icon(_getCategoryIcon(), size: 50, color: _getCategoryColor()),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (tip.category) {
      case 'exercise':
        return const Color(0xFF1DAB87);
      case 'nutrition':
        return const Color(0xFFF97316);
      case 'wisdom':
        return const Color(0xFFFFB800);
      case 'myth':
        return const Color(0xFFE11D48);
      case 'recovery':
        return const Color(0xFF8B5CF6);
      case 'lifestyle':
        return const Color(0xFF06B6D4);
      default:
        return const Color(0xFF1DAB87);
    }
  }

  IconData _getCategoryIcon() {
    switch (tip.category) {
      case 'exercise':
        return Icons.fitness_center;
      case 'nutrition':
        return Icons.restaurant;
      case 'wisdom':
        return Icons.lightbulb;
      case 'myth':
        return Icons.fact_check;
      case 'recovery':
        return Icons.spa;
      case 'lifestyle':
        return Icons.self_improvement;
      default:
        return Icons.tips_and_updates;
    }
  }

  String _getCategoryDisplayName() {
    switch (tip.category) {
      case 'exercise':
        return 'Exercise';
      case 'nutrition':
        return 'Nutrition';
      case 'wisdom':
        return 'Wisdom';
      case 'myth':
        return 'Myth Busting';
      case 'recovery':
        return 'Recovery';
      case 'lifestyle':
        return 'Lifestyle';
      default:
        return tip.category;
    }
  }

  String _formatViewCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
