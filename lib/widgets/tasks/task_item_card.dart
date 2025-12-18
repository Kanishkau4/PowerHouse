import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';

class TaskItemCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onTap;
  final Function(bool) onToggle;
  final bool isOptimistic;

  const TaskItemCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    this.isOptimistic = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task['is_completed'] as bool? ?? false;
    final title = task['task_title'] as String;
    final duration = task['duration'] as int?;
    final calories = task['calories'] as int?;

    // Categorize
    final taskIcon = _getTaskIcon(title);
    final taskColor = _getTaskColor(title);

    // Theme-aware colors
    final cardBg = isCompleted
        ? context.primaryColor.withOpacity(0.05)
        : context.cardBackground;
    final borderColor = isCompleted ? context.primaryColor : Colors.transparent;
    final titleColor = isCompleted
        ? context.secondaryText
        : context.primaryText;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor.withOpacity(isCompleted ? 0.0 : 0.0),
            width: 0,
          ),
          boxShadow: [
            BoxShadow(
              color: context.shadowColor.withOpacity(isCompleted ? 0.0 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Categorization Icon Container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCompleted
                    ? context.secondaryText.withOpacity(0.1)
                    : taskColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                taskIcon,
                color: isCompleted ? context.secondaryText : taskColor,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Task Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  if (!isCompleted &&
                      (duration != null || calories != null)) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (duration != null) ...[
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: context.secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$duration min',
                            style: TextStyle(
                              fontSize: 13,
                              color: context.secondaryText,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (calories != null) ...[
                          const Icon(
                            Icons.local_fire_department,
                            size: 14,
                            color: Color(0xFFFF844B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$calories cal',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFFF844B),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Checkbox
            GestureDetector(
              onTap: () => onToggle(!isCompleted),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? context.primaryColor
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted
                        ? context.primaryColor
                        : context.dividerColor,
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TASK HELPERS ====================
  IconData _getTaskIcon(String title) {
    title = title.toLowerCase();
    if (title.contains('workout') ||
        title.contains('run') ||
        title.contains('gym') ||
        title.contains('exercise')) {
      return FontAwesomeIcons.dumbbell;
    }
    if (title.contains('water') ||
        title.contains('drink') ||
        title.contains('hydrate')) {
      return FontAwesomeIcons.glassWater;
    }
    if (title.contains('eat') ||
        title.contains('meal') ||
        title.contains('nutrition') ||
        title.contains('food') ||
        title.contains('calor')) {
      return FontAwesomeIcons.bowlFood;
    }
    if (title.contains('sleep') ||
        title.contains('bed') ||
        title.contains('rest') ||
        title.contains('meditate')) {
      return FontAwesomeIcons.bed;
    }
    if (title.contains('read') ||
        title.contains('learn') ||
        title.contains('study')) {
      return FontAwesomeIcons.bookOpen;
    }
    return FontAwesomeIcons.circleCheck; // Default
  }

  Color _getTaskColor(String title) {
    title = title.toLowerCase();
    if (title.contains('workout') ||
        title.contains('run') ||
        title.contains('gym') ||
        title.contains('exercise')) {
      return const Color(0xFFF15223); // Orange/Red
    }
    if (title.contains('water') ||
        title.contains('drink') ||
        title.contains('hydrate')) {
      return Colors.blue;
    }
    if (title.contains('eat') ||
        title.contains('meal') ||
        title.contains('nutrition') ||
        title.contains('food')) {
      return const Color(0xFF1DAB87); // Green
    }
    if (title.contains('sleep') ||
        title.contains('bed') ||
        title.contains('rest') ||
        title.contains('meditate')) {
      return Colors.deepPurple;
    }
    return const Color(0xFFFFA000); // Default Yellow/Amber
  }
}
