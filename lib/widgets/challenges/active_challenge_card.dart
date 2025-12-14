import 'package:flutter/material.dart';
import 'package:powerhouse/models/user_challenge_model.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';

class ActiveChallengeCard extends StatelessWidget {
  final UserChallengeModel userChallenge;
  final VoidCallback onTap;

  const ActiveChallengeCard({
    Key? key,
    required this.userChallenge,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final primaryColor = theme.primaryColor;
    final secondaryText = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    // Safely calculate progress
    final int targetValue = userChallenge.challenge?.targetValue ?? 0;
    final double rawProgress =
        targetValue > 0 ? (userChallenge.progress / targetValue) : 0.0;
    final double progress = rawProgress.clamp(0.0, 1.0);
    final int progressPercent = (progress * 100).toInt();

    final challenge = userChallenge.challenge;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image Header
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: challenge?.imageUrl != null
                      ? Image.network(
                          challenge!.imageUrl!,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage(challenge);
                          },
                        )
                      : _buildPlaceholderImage(challenge),
                ),

                // Overlay Gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),

                // Progress Badge Overlay (Top Right)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getProgressColor(progress).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          progress >= 1.0
                              ? Icons.check_circle
                              : Icons.trending_up,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$progressPercent%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // XP Reward Badge (Top Left)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt, color: Colors.yellow, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '+${challenge?.xpReward ?? 0} XP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Title Overlay
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge?.challengeName ?? 'Challenge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${challenge?.challengeType.substring(0, 1).toUpperCase()}${challenge?.challengeType.substring(1) ?? ''} Challenge',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Bottom Progress Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Progress Info Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left: Progress Stats
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getChallengeIcon(challenge?.unit ?? ''),
                                  size: 14,
                                  color: secondaryText,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${userChallenge.progress} / $targetValue ${challenge?.unit ?? ''}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: secondaryText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: secondaryText,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getDaysRemaining(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: secondaryText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Right: Circular Progress
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 55,
                            height: 55,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 5,
                              backgroundColor: primaryColor.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getProgressColor(progress),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$progressPercent%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _getProgressColor(progress),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Linear Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: primaryColor.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(progress),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDaysRemaining() {
    if (userChallenge.endDate == null) {
      return '${userChallenge.challenge?.durationDays ?? 0} Days';
    }

    final now = DateTime.now();
    final end = userChallenge.endDate!;
    final remaining = end.difference(now).inDays;

    if (remaining <= 0) {
      return 'Ended';
    } else if (remaining == 1) {
      return '1 Day Left';
    } else {
      return '$remaining Days Left';
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) {
      return const Color(0xFF4CAF50); // Green - Complete
    } else if (progress >= 0.7) {
      return const Color(0xFF8BC34A); // Light Green - Almost there
    } else if (progress >= 0.4) {
      return const Color(0xFFFFC107); // Yellow/Amber - Halfway
    } else {
      return const Color(0xFF2196F3); // Blue - Just started
    }
  }

  Widget _buildPlaceholderImage(dynamic challenge) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: _getChallengeGradient(challenge?.challengeType ?? 'physical'),
      ),
      child: Center(
        child: Icon(
          _getChallengeIcon(challenge?.unit ?? ''),
          size: 50,
          color: Colors.white,
        ),
      ),
    );
  }

  IconData _getChallengeIcon(String unit) {
    switch (unit.toLowerCase()) {
      case 'steps':
        return Icons.directions_walk;
      case 'calories':
        return Icons.local_fire_department;
      case 'km':
      case 'distance':
        return Icons.map;
      case 'glasses':
        return Icons.local_drink;
      case 'minutes':
        return Icons.timer;
      case 'days':
        return Icons.calendar_today;
      default:
        return Icons.fitness_center;
    }
  }

  LinearGradient _getChallengeGradient(String type) {
    switch (type.toLowerCase()) {
      case 'nutrition':
        return const LinearGradient(
          colors: [Color(0xFF00C6FB), Color(0xFF005BEA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'mindfulness':
        return const LinearGradient(
          colors: [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'social':
        return const LinearGradient(
          colors: [Color(0xFFfa709a), Color(0xFFfee140)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'physical':
      default:
        return const LinearGradient(
          colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}