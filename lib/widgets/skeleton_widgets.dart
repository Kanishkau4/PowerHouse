import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';

/// Reusable skeleton loading widgets with shimmer animation
/// Used across the app to show loading states that match actual content layout

// ==================== SKELETON CONTAINER ====================
/// Basic animated shimmer container with customizable dimensions
class SkeletonContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const SkeletonContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.skeletonBaseColor,
      highlightColor: context.skeletonHighlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

// ==================== SKELETON CIRCLE ====================
/// Circular skeleton for profile pictures and progress indicators
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, this.size = 50.0});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.skeletonBaseColor,
      highlightColor: context.skeletonHighlightColor,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: context.cardBackground,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ==================== SKELETON TEXT ====================
/// Text line skeleton with customizable width
class SkeletonText extends StatelessWidget {
  final double width;
  final double height;

  const SkeletonText({super.key, this.width = 100.0, this.height = 16.0});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.skeletonBaseColor,
      highlightColor: context.skeletonHighlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

// ==================== SKELETON CARD ====================
/// Card-shaped skeleton for workout cards, challenge cards, etc.
class SkeletonCard extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonCard({
    super.key,
    this.width = double.infinity,
    this.height = 200.0,
    this.borderRadius = 25.0,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.skeletonBaseColor,
      highlightColor: context.skeletonHighlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

// ==================== SKELETON LIST TILE ====================
/// List item skeleton for daily tasks, meal items, leaderboard entries
class SkeletonListTile extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;

  const SkeletonListTile({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = true,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.skeletonBaseColor,
      highlightColor: context.skeletonHighlightColor,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            if (hasLeading) ...[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: context.cardBackground,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: context.cardBackground,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 150,
                    height: 12,
                    decoration: BoxDecoration(
                      color: context.cardBackground,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            if (hasTrailing) ...[
              const SizedBox(width: 16),
              Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: context.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==================== SKELETON WORKOUT CARD ====================
/// Skeleton for workout cards in home screen
class SkeletonWorkoutCard extends StatelessWidget {
  const SkeletonWorkoutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.skeletonBaseColor,
      highlightColor: context.skeletonHighlightColor,
      child: Container(
        width: 285,
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Container(
              width: 285,
              height: 128,
              decoration: BoxDecoration(
                color: context.cardBackground,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
            ),
            // Content section
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 200,
                    height: 20,
                    decoration: BoxDecoration(
                      color: context.cardBackground,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 150,
                    height: 14,
                    decoration: BoxDecoration(
                      color: context.cardBackground,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 28,
                        decoration: BoxDecoration(
                          color: context.cardBackground,
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 80,
                        height: 28,
                        decoration: BoxDecoration(
                          color: context.cardBackground,
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
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
}

// ==================== SKELETON PLAN CARD ====================
/// Skeleton for the "My Plan" card on home screen
class SkeletonPlanCard extends StatelessWidget {
  const SkeletonPlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.skeletonBaseColor,
      highlightColor: context.skeletonHighlightColor,
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }
}

// ==================== SKELETON MACRO CARD ====================
/// Skeleton for macro cards in nutrition screen
class SkeletonMacroCard extends StatelessWidget {
  const SkeletonMacroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.skeletonBaseColor,
      highlightColor: context.skeletonHighlightColor,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

// ==================== SKELETON CHART ====================
/// Skeleton for charts (weight progress, workout time)
class SkeletonChart extends StatelessWidget {
  final double height;

  const SkeletonChart({super.key, this.height = 250.0});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.skeletonBaseColor,
      highlightColor: context.skeletonHighlightColor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
