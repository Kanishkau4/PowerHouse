import 'package:flutter/material.dart';
import 'package:powerhouse/models/challenge_model.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AvailableChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  final VoidCallback onJoin;

  const AvailableChallengeCard({
    super.key,
    required this.challenge,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onJoin,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Background with Solid Color
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: _getSolidColor(challenge.challengeType),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _getSolidColor(
                      challenge.challengeType,
                    ).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _getChallengeIcon(challenge.unit),
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Challenge Name
                  Text(
                    challenge.challengeName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Challenge Type Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getSolidColor(
                        challenge.challengeType,
                      ).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${challenge.challengeType[0].toUpperCase()}${challenge.challengeType.substring(1)}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getSolidColor(challenge.challengeType),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Goal & Duration Row
                  Row(
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        size: 12,
                        color: context.secondaryText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${challenge.targetValue} ${challenge.unit}',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: context.secondaryText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${challenge.durationDays}d',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Right Side: XP & Join Button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // XP Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        '+${challenge.xpReward}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Join Button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: context.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: context.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Join',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getChallengeIcon(String unit) {
    switch (unit.toLowerCase()) {
      case 'steps':
        return FontAwesomeIcons.shoePrints;
      case 'calories':
        return FontAwesomeIcons.fireFlameCurved;
      case 'km':
      case 'distance':
        return FontAwesomeIcons.route;
      case 'glasses':
        return FontAwesomeIcons.glassWater;
      case 'minutes':
        return FontAwesomeIcons.clock;
      case 'days':
        return FontAwesomeIcons.calendarDays;
      case 'workouts':
        return FontAwesomeIcons.dumbbell;
      default:
        return FontAwesomeIcons.heartPulse;
    }
  }

  Color _getSolidColor(String type) {
    switch (type.toLowerCase()) {
      case 'nutrition':
        return const Color(0xFF4CAF50); // Green
      case 'mindfulness':
        return const Color(0xFF9C27B0); // Purple
      case 'social':
        return const Color(0xFFFF5722); // Deep Orange
      case 'physical':
      default:
        return const Color(0xFF2196F3); // Blue
    }
  }
}
