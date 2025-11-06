import 'package:flutter/material.dart';
import 'package:powerhouse/services/challenge_service.dart';
import 'package:powerhouse/services/user_service.dart';
import 'package:powerhouse/services/badge_service.dart';
import 'package:powerhouse/models/user_model.dart';
import 'package:powerhouse/models/challenge_model.dart';
import 'package:powerhouse/models/user_challenge_model.dart';
import 'package:powerhouse/models/user_badge_model.dart';
import 'package:powerhouse/models/badge_model.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen>
    with SingleTickerProviderStateMixin {
  int selectedTab = 0; // 0 = Challenges, 1 = Leaderboard
  
  // Services
  final _challengeService = ChallengeService();
  final _userService = UserService();
  final _badgeService = BadgeService();
  
  // Data
  UserModel? _userProfile;
  List<UserChallengeModel> _activeChallenges = [];
  List<ChallengeModel> _availableChallenges = [];
  List<UserBadgeModel> _userBadges = [];
  List<UserModel> _leaderboardUsers = [];
  
  // Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChallengesData();
  }

  Future<void> _loadChallengesData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load user profile
      final profile = await _userService.getCurrentUserProfile();
      
      // Load user's active challenges
      final activeChallenges = await _challengeService.getUserActiveChallenges();
      
      // Load all available challenges
      final availableChallenges = await _challengeService.getAllChallenges();
      
      // Load user badges
      final userBadges = await _badgeService.getUserBadges();
      
      // Load leaderboard users (top 10 by XP)
      final leaderboardUsers = await _userService.getLeaderboardUsers(10);
      
      // Filter out challenges that user has already joined
      final joinedChallengeIds = activeChallenges.map((uc) => uc.challengeId).toSet();
      final filteredAvailableChallenges = availableChallenges
          .where((challenge) => !joinedChallengeIds.contains(challenge.challengeId))
          .toList();
      
      setState(() {
        _userProfile = profile;
        _activeChallenges = activeChallenges;
        _availableChallenges = filteredAvailableChallenges;
        _userBadges = userBadges;
        _leaderboardUsers = leaderboardUsers;
        _isLoading = false;
      });
      
      // Debug print to see what we loaded
      print('Loaded ${leaderboardUsers.length} leaderboard users');
      for (var user in leaderboardUsers) {
        print('User: ${user.username}, XP: ${user.xpPoints}');
      }
    } catch (e) {
      print('Error loading challenges data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF1DAB87),
          ),
        ),
      );
    }
    
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
                child: _userProfile?.profilePictureUrl != null
                    ? Image.network(
                        _userProfile!.profilePictureUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF1DAB87),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        'assets/images/profile_male.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF1DAB87),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            ),
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
            if (_activeChallenges.isEmpty)
              _buildEmptyState('No active challenges', 'Join a challenge to get started!')
            else
              ..._activeChallenges.map((userChallenge) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildActiveChallengeCard(userChallenge),
                );
              }),
            
            const SizedBox(height: 24),
            
            // Available Challenges Section
            _buildSectionHeader('Available Challenges', 'See all', () {}),
            
            const SizedBox(height: 16),
            
            // Available Challenge Cards
            if (_availableChallenges.isEmpty)
              _buildEmptyState('No available challenges', 'Check back later for new challenges!')
            else
              ..._availableChallenges.map((challenge) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildAvailableChallengeCard(challenge),
                );
              }),
            
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
            
            // Display message if no users
            if (_leaderboardUsers.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'No users found in leaderboard',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF7E7E7E),
                    ),
                  ),
                ),
              )
            else ...[
              // Top 3 Podium
              _buildPodium(_leaderboardUsers.take(3).toList()),
              
              const SizedBox(height: 24),
              
              // Leaderboard List
              ..._leaderboardUsers.skip(3).map((user) {
                final isCurrentUser = user.userId == _userProfile?.userId;
                final rank = _leaderboardUsers.indexOf(user) + 1;
                return _buildLeaderboardItem(
                  rank: rank,
                  name: user.username,
                  points: user.xpPoints,
                  profilePictureUrl: user.profilePictureUrl,
                  isCurrentUser: isCurrentUser,
                );
              }),
            ],
            
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

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1DAB87).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 50,
            color: const Color(0xFF1DAB87),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF7E7E7E),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ACTIVE CHALLENGE CARD ====================
  Widget _buildActiveChallengeCard(UserChallengeModel userChallenge) {
    final challenge = userChallenge.challenge;
    if (challenge == null) return const SizedBox.shrink();
    
    final progress = userChallenge.progressPercentage;
    
    return GestureDetector(
      onTap: () => _onChallengeTap(userChallenge),
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
                color: const Color(0xFF1DAB87).withOpacity(0.3),
                child: challenge.imageUrl != null
                    ? Image.network(
                        challenge.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF1DAB87).withOpacity(0.5),
                          );
                        },
                      )
                    : Container(
                        color: const Color(0xFF1DAB87).withOpacity(0.5),
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
                              challenge.challengeName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${userChallenge.progress} / ${challenge.targetValue} ${challenge.unit}',
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
                      _buildProgressCircle(progress),
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

  // ==================== AVAILABLE CHALLENGE CARD ====================
  Widget _buildAvailableChallengeCard(ChallengeModel challenge) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x72D9D9D9),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF1DAB87).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getChallengeIcon(challenge.unit),
              size: 25,
              color: const Color(0xFF1DAB87),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Text
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.challengeName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${challenge.targetValue} ${challenge.unit} in ${challenge.durationDays} days',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7E7E7E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '+${challenge.xpReward} XP',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF97316),
                  ),
                ),
              ],
            ),
          ),
          
          // Join Button
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

  // ==================== GET CHALLENGE ICON ====================
  IconData _getChallengeIcon(String unit) {
    switch (unit.toLowerCase()) {
      case 'steps':
        return Icons.directions_walk;
      case 'calories':
        return Icons.local_fire_department;
      case 'workouts':
        return Icons.fitness_center;
      default:
        return Icons.emoji_events;
    }
  }

  // ==================== ACHIEVEMENTS BADGES ====================
  Widget _buildAchievementsBadges() {
    return Column(
      children: [
        // First Row
        if (_userBadges.length >= 3)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _userBadges.take(3).map((userBadge) {
              return _buildAchievementBadge(userBadge);
            }).toList(),
          ),
        if (_userBadges.length >= 3) const SizedBox(height: 16),
        
        // Second Row
        if (_userBadges.length >= 6)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _userBadges.skip(3).take(3).map((userBadge) {
              return _buildAchievementBadge(userBadge);
            }).toList(),
          ),
      ],
    );
  }

  // ==================== ACHIEVEMENT BADGE ====================
  Widget _buildAchievementBadge(UserBadgeModel userBadge) {
    final badge = userBadge.badge;
    if (badge == null) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF1DAB87),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1DAB87).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.emoji_events,
          color: Colors.white,
          size: 30,
        ),
      );
    }
    
    return GestureDetector(
      onTap: () => _onBadgeTap(userBadge),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1DAB87),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1DAB87).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: badge.iconUrl != null
                ? ClipOval(
                    child: Image.network(
                      badge.iconUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 30,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 30,
                  ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              badge.badgeName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PODIUM (TOP 3) ====================
  Widget _buildPodium(List<UserModel> topUsers) {
    // Ensure we have exactly 3 users, pad with empty if needed
    while (topUsers.length < 3) {
      topUsers.add(UserModel(
        userId: '',
        username: 'No User',
        email: '',
        xpPoints: 0,
        level: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
    
    // Sort to ensure correct order by XP (highest first)
    topUsers.sort((a, b) => b.xpPoints.compareTo(a.xpPoints));
    
    // Take only the top 3
    if (topUsers.length > 3) {
      topUsers = topUsers.take(3).toList();
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd place (left)
        _buildPodiumPlace(
          user: topUsers.length > 1 ? topUsers[1] : null,
          rank: 2,
          height: 100,
        ),
        const SizedBox(width: 16),
        // 1st place (center, tallest)
        _buildPodiumPlace(
          user: topUsers.isNotEmpty ? topUsers[0] : null,
          rank: 1,
          height: 140,
        ),
        const SizedBox(width: 16),
        // 3rd place (right)
        _buildPodiumPlace(
          user: topUsers.length > 2 ? topUsers[2] : null,
          rank: 3,
          height: 100,
        ),
      ],
    );
  }

  Widget _buildPodiumPlace({
    UserModel? user,
    required int rank,
    required double height,
  }) {
    final colors = {
      1: const Color(0xFFFFD700), // Gold
      2: const Color(0xFFC0C0C0), // Silver
      3: const Color(0xFFCD7F32), // Bronze
    };

    final displayName = user?.username ?? 'No User';
    final points = user?.xpPoints ?? 0;
    final profilePictureUrl = user?.profilePictureUrl;

    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: colors[rank] ?? const Color(0xFF1DAB87),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: (colors[rank] ?? const Color(0xFF1DAB87)).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: profilePictureUrl != null
              ? ClipOval(
                  child: Image.network(
                    profilePictureUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          rank.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Center(
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
          displayName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
            color: (colors[rank] ?? const Color(0xFF1DAB87)).withOpacity(0.3),
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
    String? profilePictureUrl,
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
            child: profilePictureUrl != null
                ? ClipOval(
                    child: Image.network(
                      profilePictureUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            rank.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1DAB87),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
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
                color: isCurrentUser ? const Color(0xFF1DAB87) : Colors.black,
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

  void _onChallengeTap(UserChallengeModel userChallenge) {
    print('Challenge tapped: ${userChallenge.challenge?.challengeName}');
    // Navigate to challenge detail
  }

  void _onJoinChallenge(ChallengeModel challenge) async {
    print('Join challenge: ${challenge.challengeName}');
    
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF1DAB87)),
        ),
      );
      
      // Join the challenge
      final result = await _challengeService.joinChallenge(challenge.challengeId);
      
      // Close loading
      Navigator.pop(context);
      
      // Show success message with XP
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Joined ${challenge.challengeName}! +${result['xp_added']} XP'),
          backgroundColor: const Color(0xFF1DAB87),
          duration: const Duration(seconds: 3),
        ),
      );
      
      // Refresh data
      await _loadChallengesData();
    } catch (e) {
      // Close loading
      Navigator.pop(context);
      
      print('Error joining challenge: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to join challenge'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onBadgeTap(UserBadgeModel userBadge) {
    final badge = userBadge.badge;
    if (badge == null) return;
    
    print('Badge tapped: ${badge.badgeName}');
    // Show badge detail
    _showBadgeDialog(badge);
  }

  void _showBadgeDialog(BadgeModel badge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            badge.iconUrl != null
                ? ClipOval(
                    child: Image.network(
                      badge.iconUrl!,
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.emoji_events,
                          color: const Color(0xFF1DAB87),
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.emoji_events,
                    color: const Color(0xFF1DAB87),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(badge.badgeName),
            ),
          ],
        ),
        content: Text(
          badge.description ?? 'Congratulations! You unlocked this achievement!',
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