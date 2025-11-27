import 'package:flutter/material.dart';
import 'package:powerhouse/models/models.dart';

class CategoryChip extends StatelessWidget {
  final TipCategoryModel? category;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isAllCategory;

  const CategoryChip({
    super.key,
    this.category,
    required this.isSelected,
    required this.onTap,
    this.isAllCategory = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = isAllCategory
        ? 'All'
        : (category?.displayName ?? 'Unknown');
    final color = isAllCategory
        ? const Color(0xFF1DAB87)
        : (category?.color ?? const Color(0xFF1DAB87));
    final icon = isAllCategory
        ? Icons.grid_view
        : (category?.icon ?? Icons.tips_and_updates);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              displayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
