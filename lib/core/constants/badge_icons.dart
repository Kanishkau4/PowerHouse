class BadgeIcons {
  // Map badge names to local asset paths
  static const Map<String, String> assetPaths = {
    'Cardio King': 'assets/icons/cardio_king.png',
    'Workout Warrior': 'assets/icons/workout_warrior.png',
    'Marathoner': 'assets/icons/marathoner.png',
    'First 1000 Calorie Burn': 'assets/icons/calorie_burn.png',
    'Iron Lifter': 'assets/icons/iron_lifter.png',
    'Gym Goblin': 'assets/icons/gym_goblin.png',
    'First 5 Levels': 'assets/icons/level_5.png',
    'Level 10 Warrior': 'assets/icons/level_10.png',
    'Level 20 Champion': 'assets/icons/level_20.png',
    'First 1000 XP': 'assets/icons/1000_xp.png',
    '5000 XP Master': 'assets/icons/5000_xp.png',
  };

  // Get local asset path for a badge
  static String? getAssetPath(String badgeName) {
    return assetPaths[badgeName];
  }

  // Check if badge has a local icon
  static bool hasLocalIcon(String badgeName) {
    return assetPaths.containsKey(badgeName);
  }
}