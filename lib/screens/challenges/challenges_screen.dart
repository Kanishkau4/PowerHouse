import 'package:flutter/material.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({Key? key}) : super(key: key);

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  int selectedTab = 0; // 0 = Challenges, 1 = Leaderboard
  
  // Sample active challenges
  final List<Challenge> activeChallenges = [
    Challenge(
      title: 'Walk 100,000\nSteps in May',
      progress: 0.65,
      current: 65400,
      target: 100000,
      unit: 'steps',
      color: const Color(0xFF1DAB87),
      imageUrl: 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800',
    ),
  ];

  // Sample available challenges (Sri Lankan themed)
  final List<AvailableChallenge> availableChallenges = [
    AvailableChallenge(
      title: 'Aurudu\nMarathon',
      description: 'Full body workout',
      icon: Icons.directions_run,
      color: const Color(0xFF1DAB87),
    ),
    AvailableChallenge(
      title: 'First Kottu\nKiller',
      description: '1000 kcal burn',
      icon: Icons.local_fire_department,
      color: const Color(0xFFFF844B),
    ),
    AvailableChallenge(
      title: 'Wesak\nCalorie Burn',
      description: 'Full body workout',
      icon: Icons.fitness_center,
      color: const Color(0xFF6C63FF),
    ),
  ];

  // Sample achievements
  final List<Achievement> achievements = [
    Achievement(name: 'Cardio King', icon: Icons.favorite, isUnlocked: true),
    Achievement(name: 'Workout\nWarrior', icon: Icons.fitness_center, isUnlocked: true),
    Achievement(name: 'Marathoner', icon: Icons.directions_run, isUnlocked: true),
    Achievement(name: 'First 1000\nCalorie Burn', icon: Icons.local_fire_department, isUnlocked: false),
    Achievement(name: 'Iron Lifter', icon: Icons.fitness_center, isUnlocked: false),
    Achievement(name: 'Gym Goblin', icon: Icons.sports_gymnastics, isUnlocked: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Tab Selector
            _buildTabSelector(),
            
            const SizedBox(height: 24),
            
            // Content
            Expanded(
              child: selectedTab == 0
                  ? _buildChallengesTab()
                  : _buildLeaderboardTab(),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Challenges',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          GestureDetector(
            onTap: () => _onProfileTap(),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF1DAB87),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                'assets/images/profile_male.png', // Path to your image
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to icon if image fails to load
                  return const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  );
                },
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB SELECTOR ====================
  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 38.0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xCCD9D9D9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedTab = 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: selectedTab == 0 
                        ? const Color(0xFF1DAB87) 
                        : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Challenges',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: selectedTab == 0 ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedTab = 1),
                child: Container(
                  decoration: BoxDecoration(
                    color: selectedTab == 1 
                        ? const Color(0xFF1DAB87) 
                        : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Leaderboard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: selectedTab == 1 ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== CHALLENGES TAB ====================
  Widget _buildChallengesTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Challenges Section
            _buildSectionHeader('Active Challenges', 'See all', () {}),
            
            const SizedBox(height: 16),
            
            // Active Challenge Cards
            ...activeChallenges.map((challenge) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildActiveChallengeCard(challenge),
              );
            }).toList(),
            
            const SizedBox(height: 24),
            
            // Available Challenges Section
            _buildSectionHeader('Available Challenges', 'See all', () {}),
            
            const SizedBox(height: 16),
            
            // Available Challenge Cards
            _buildAvailableChallengesGrid(),
            
            const SizedBox(height: 24),
            
            // Achievements Section
            _buildSectionHeader('Achievements', '', null),
            
            const SizedBox(height: 16),
            
            // Achievement Badges
            _buildAchievementsBadges(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ==================== LEADERBOARD TAB ====================
  Widget _buildLeaderboardTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            
            // Top 3 Podium
            _buildPodium(),
            
            const SizedBox(height: 24),
            
            // Leaderboard List
            ...List.generate(10, (index) {
              return _buildLeaderboardItem(
                rank: index + 4,
                name: 'User ${index + 4}',
                points: (1000 - (index * 50)),
                isCurrentUser: index == 3,
              );
            }).toList(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ==================== SECTION HEADER ====================
  Widget _buildSectionHeader(String title, String actionText, VoidCallback? onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        if (actionText.isNotEmpty)
          GestureDetector(
            onTap: onTap,
            child: Text(
              actionText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFFF15223),
              ),
            ),
          ),
      ],
    );
  }

  // ==================== ACTIVE CHALLENGE CARD ====================
  Widget _buildActiveChallengeCard(Challenge challenge) {
    return GestureDetector(
      onTap: () => _onChallengeTap(challenge),
      child: Container(
        height: 178,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Image
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: challenge.color.withOpacity(0.3),
                child: Image.network(
                  challenge.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: challenge.color.withOpacity(0.5),
                    );
                  },
                ),
              ),
            ),
            
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              challenge.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${challenge.current.toStringAsFixed(0)} / ${challenge.target.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Progress Circle
                      _buildProgressCircle(challenge.progress),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Continue Button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: Colors.black.withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Continue Challenge',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                          size: 20,
                        ),
                      ],
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

  // ==================== PROGRESS CIRCLE ====================
  Widget _buildProgressCircle(double progress) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF1DAB87),
              ),
            ),
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== AVAILABLE CHALLENGES GRID ====================
  Widget _buildAvailableChallengesGrid() {
    return Row(
      children: availableChallenges.map((challenge) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _buildAvailableChallengeCard(challenge),
          ),
        );
      }).toList(),
    );
  }

  // ==================== AVAILABLE CHALLENGE CARD ====================
  Widget _buildAvailableChallengeCard(AvailableChallenge challenge) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x72D9D9D9),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            challenge.icon,
            size: 30,
            color: challenge.color,
          ),
          Text(
            challenge.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              height: 1.2,
            ),
          ),
          GestureDetector(
            onTap: () => _onJoinChallenge(challenge),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xE01DAB87),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Text(
                'Join',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ACHIEVEMENTS BADGES ====================
  Widget _buildAchievementsBadges() {
    return Column(
      children: [
        // First Row (Unlocked)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: achievements.sublist(0, 3).map((achievement) {
            return _buildAchievementBadge(achievement);
          }).toList(),
        ),
        const SizedBox(height: 16),
        
        // Second Row (Locked)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: achievements.sublist(3, 6).map((achievement) {
            return _buildAchievementBadge(achievement);
          }).toList(),
        ),
      ],
    );
  }

  // ==================== ACHIEVEMENT BADGE ====================
  // Replace the existing _buildAchievementBadge method with this:
Widget _buildAchievementBadge(Achievement achievement) {
  // Define image paths for each achievement
  final badgeImages = {
    'Cardio King': 'assets/icons/cardio_king.png',
    'Workout\nWarrior': 'assets/icons/workout_warrior.png',
    'Marathoner': 'assets/icons/marathoner.png',
    'First 1000\nCalorie Burn': 'assets/icons/calorie_burn.png',
    'Iron Lifter': 'assets/icons/iron_lifter.png',
    'Gym Goblin': 'assets/icons/gym_goblin.png',
  };

  return GestureDetector(
    onTap: () => _onBadgeTap(achievement),
    child: Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: achievement.isUnlocked
                ? const Color.fromARGB(255, 255, 255, 255)
                : const Color(0xFFD9D9D9),
            shape: BoxShape.circle,
            boxShadow: achievement.isUnlocked
                ? [
                    BoxShadow(
                      color: const Color.fromARGB(255, 92, 100, 98).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: achievement.isUnlocked
              ? ClipOval(
                  child: Image.asset(
                    badgeImages[achievement.name.replaceAll('\n', ' ')] ?? 
                    badgeImages[achievement.name] ?? 
                    'assets/images/fitness_model.png', // Fallback image
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to icon if image fails to load
                      return Icon(
                        achievement.icon,
                        color: achievement.isUnlocked ? Colors.white : Colors.grey,
                        size: 30,
                      );
                    },
                  ),
                )
              : Icon(
                  achievement.icon,
                  color: Colors.grey,
                  size: 30,
                ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            achievement.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: achievement.isUnlocked
                  ? Colors.black
                  : const Color(0xFF979797),
              height: 1.2,
            ),
          ),
        ),
      ],
    ),
  );
}

  // ==================== PODIUM (TOP 3) ====================
  Widget _buildPodium() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildPodiumPlace(2, 'User 2', 1200, 100),
        const SizedBox(width: 16),
        _buildPodiumPlace(1, 'User 1', 1500, 140),
        const SizedBox(width: 16),
        _buildPodiumPlace(3, 'User 3', 1000, 100),
      ],
    );
  }

  Widget _buildPodiumPlace(int rank, String name, int points, double height) {
    final colors = {
      1: const Color(0xFFFFD700), // Gold
      2: const Color(0xFFC0C0C0), // Silver
      3: const Color(0xFFCD7F32), // Bronze
    };

    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: colors[rank],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: colors[rank]!.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              rank.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '$points pts',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF979797),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: colors[rank]!.withOpacity(0.3),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== LEADERBOARD ITEM ====================
  Widget _buildLeaderboardItem({
    required int rank,
    required String name,
    required int points,
    bool isCurrentUser = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? const Color(0xFF1DAB87).withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser 
              ? const Color(0xFF1DAB87)
              : const Color(0xFFE0E0E0),
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1DAB87).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1DAB87),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isCurrentUser ? FontWeight.w800 : FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            '$points pts',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1DAB87),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HANDLERS ====================
  
  void _onProfileTap() {
    print('Profile tapped');
  }

  void _onChallengeTap(Challenge challenge) {
    print('Challenge tapped: ${challenge.title}');
    // Navigate to challenge detail
  }

  void _onJoinChallenge(AvailableChallenge challenge) {
    print('Join challenge: ${challenge.title}');
    // Show join confirmation dialog
    _showJoinDialog(challenge);
  }

  void _onBadgeTap(Achievement achievement) {
    print('Badge tapped: ${achievement.name}');
    // Show badge detail
    _showBadgeDialog(achievement);
  }

  void _showJoinDialog(AvailableChallenge challenge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(challenge.title.replaceAll('\n', ' ')),
        content: Text('Do you want to join this challenge?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Joined ${challenge.title.replaceAll('\n', ' ')}!'),
                  backgroundColor: const Color(0xFF1DAB87),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1DAB87),
            ),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  void _showBadgeDialog(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              achievement.icon,
              color: achievement.isUnlocked 
                  ? const Color(0xFF1DAB87) 
                  : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(achievement.name.replaceAll('\n', ' ')),
            ),
          ],
        ),
        content: Text(
          achievement.isUnlocked
              ? 'Congratulations! You unlocked this achievement!'
              : 'Keep going! This badge is still locked.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF1DAB87)),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== DATA MODELS ====================

class Challenge {
  final String title;
  final double progress;
  final double current;
  final double target;
  final String unit;
  final Color color;
  final String imageUrl;

  Challenge({
    required this.title,
    required this.progress,
    required this.current,
    required this.target,
    required this.unit,
    required this.color,
    required this.imageUrl,
  });
}

class AvailableChallenge {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  AvailableChallenge({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class Achievement {
  final String name;
  final IconData icon;
  final bool isUnlocked;

  Achievement({
    required this.name,
    required this.icon,
    required this.isUnlocked,
  });
}