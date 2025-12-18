import 'package:flutter/material.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';

class PlanStatsWidget extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;
  final int remainingMinutes;
  final int totalCalories;

  const PlanStatsWidget({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
    required this.remainingMinutes,
    required this.totalCalories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            icon: Icons.check_circle_outline,
            value: '$completedTasks/$totalTasks',
            label: 'Tasks',
            color: const Color(0xFF1DAB87),
          ),
          Container(height: 40, width: 1, color: context.dividerColor),
          _buildStatItem(
            context,
            icon: Icons.access_time,
            value: '${remainingMinutes}m',
            label: 'Left',
            color: const Color(0xFFA0A0A0), // Neutral/Grey for time
          ),
          Container(height: 40, width: 1, color: context.dividerColor),
          _buildStatItem(
            context,
            icon: Icons.local_fire_department,
            value: '$totalCalories',
            label: 'Kcal',
            color: const Color(0xFFFF844B),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: context.primaryText,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: context.secondaryText,
          ),
        ),
      ],
    );
  }
}
