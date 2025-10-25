import 'package:flutter/material.dart';

class GoalConstants {
  // Goal IDs (what's stored in database)
  static const String loseWeight = 'lose_weight';
  static const String gainMuscle = 'gain_muscle';
  static const String gainEndurance = 'gain_endurance';
  static const String tryApp = 'try_app';

  // Goal Display Names
  static const Map<String, String> goalDisplayNames = {
    loseWeight: 'I wanna lose weight',
    gainMuscle: 'I wanna get bulks',
    gainEndurance: 'I wanna gain endurance',
    tryApp: 'Just trying out the app! 👍',
  };

  // Simple Display Names (for dropdowns)
  static const Map<String, String> goalSimpleNames = {
    loseWeight: 'Lose Weight',
    gainMuscle: 'Build Muscle',
    gainEndurance: 'Gain Endurance',
    tryApp: 'Try App',
  };

  // Get all goal IDs
  static List<String> get allGoalIds => [
        loseWeight,
        gainMuscle,
        gainEndurance,
        tryApp,
      ];

  // Get display name from ID
  static String getDisplayName(String? goalId) {
    if (goalId == null) return '';
    return goalDisplayNames[goalId] ?? goalSimpleNames[goalId] ?? goalId;
  }

  // Get simple name from ID
  static String getSimpleName(String? goalId) {
    if (goalId == null) return '';
    return goalSimpleNames[goalId] ?? goalId;
  }

  // Get ID from display name (reverse lookup)
  static String? getIdFromDisplayName(String? displayName) {
    if (displayName == null) return null;
    
    // Check full display names
    for (var entry in goalDisplayNames.entries) {
      if (entry.value.toLowerCase() == displayName.toLowerCase()) {
        return entry.key;
      }
    }
    
    // Check simple names
    for (var entry in goalSimpleNames.entries) {
      if (entry.value.toLowerCase() == displayName.toLowerCase()) {
        return entry.key;
      }
    }
    
    return null;
  }

  // Goal colors (for UI)
  static const Map<String, Color> goalColors = {
    loseWeight: Color(0xFFFF6B6B),
    gainMuscle: Color(0xFF4ECDC4),
    gainEndurance: Color(0xFFFFE66D),
    tryApp: Color(0xFFB19CD9),
  };

  // Goal icons
  static const Map<String, IconData> goalIcons = {
    loseWeight: Icons.trending_down,
    gainMuscle: Icons.fitness_center,
    gainEndurance: Icons.directions_run,
    tryApp: Icons.explore,
  };

  // Get color for goal
  static Color getColor(String? goalId) {
    if (goalId == null) return Colors.grey;
    return goalColors[goalId] ?? Colors.grey;
  }

  // Get icon for goal
  static IconData getIcon(String? goalId) {
    if (goalId == null) return Icons.flag;
    return goalIcons[goalId] ?? Icons.flag;
  }
}