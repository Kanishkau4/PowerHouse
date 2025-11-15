import 'package:flutter/material.dart';
import 'package:powerhouse/core/constants/badge_icons.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:powerhouse/services/challenge_service.dart';
import 'package:powerhouse/services/user_service.dart';
import 'package:powerhouse/services/badge_service.dart';
import 'package:powerhouse/models/user_model.dart';
import 'package:powerhouse/models/challenge_model.dart';
import 'package:powerhouse/models/user_challenge_model.dart';
import 'package:powerhouse/models/user_badge_model.dart';
import 'package:powerhouse/models/badge_model.dart';
import 'package:powerhouse/screens/challenges/challenge_detail_screen.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
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
      final activeChallenges = await _challengeService
          .getUserActiveChallenges();

      // Load all available challenges
      final availableChallenges = await _challengeService.getAllChallenges();

      // Load user badges
      final userBadges = await _badgeService.getUserBadges();

      // Load leaderboard users (top 10 by XP)
      final leaderboardUsers = await _userService.getLeaderboardUsers(10);

      // Filter out challenges that user has already joined
      final joinedChallengeIds = activeChallenges
          .map((uc) => uc.challengeId)
          .toSet();
      final filteredAvailableChallenges = availableChallenges
          .where(
            (challenge) => !joinedChallengeIds.contains(challenge.challengeId),
          )
          .toList();

      setState(() {
        _userProfile = profile;
        _activeChallenges = activeChallenges;
        _availableChallenges = filteredAvailableChallenges;
        _userBadges = userBadges;
        _leaderboardUsers = leaderboardUsers;
        _isLoading = false;
      });

      print('Loaded ${leaderboardUsers.length} leaderboard users');
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
      return Scaffold(
        backgroundColor: context.surfaceColor,
        body: Center(
          child: CircularProgressIndicator(color: context.primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.surfaceColor,
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
          Text(
            'Challenges',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: context.primaryText,
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1DAB87), width: 2),
            ),
            child: ClipOval(
              child: _userProfile?.profilePictureUrl != null
                  ? Image.network(
                      _userProfile!.profilePictureUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderAvatar();
                      },
                    )
                  : _buildPlaceholderAvatar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      color: const Color(0xFF1DAB87),
      child: Center(
        child: Text(
          _userProfile?.username.substring(0, 1).toUpperCase() ?? 'U',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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
                        color: selectedTab == 0 ? Colors.white : context.primaryText,
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
                        color: selectedTab == 1 ? Colors.white : context.primaryText,
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
            _buildSectionHeader('Active Challenges', '', null),

            const SizedBox(height: 16),

            // Active Challenge Cards
            if (_activeChallenges.isEmpty)
              _buildEmptyState(
                'No active challenges',
                'Join a challenge to get started!',
              )
            else
              ..._activeChallenges.map((userChallenge) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildActiveChallengeCard(userChallenge),
                );
              }),

            const SizedBox(height: 24),

            // Available Challenges Section
            _buildSectionHeader('Available Challenges', '', null),

            const SizedBox(height: 16),

            // Available Challenge Cards
            if (_availableChallenges.isEmpty)
              _buildEmptyState(
                'No available challenges',
                'Check back later for new challenges!',
              )
            else
              ..._availableChallenges.map((challenge) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildAvailableChallengeCard(challenge),
                );
              }),

            const SizedBox(height: 24),

            // Achievements Section
            if (_userBadges.isNotEmpty) ...[
              _buildSectionHeader('Achievements', '', null),
              const SizedBox(height: 16),
              _buildAchievementsBadges(),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ==================== LEADERBOARD TAB ====================
  Widget _buildLeaderboardTab() {
    print('🔍 Leaderboard users count: ${_leaderboardUsers.length}');

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Debug info
            if (_leaderboardUsers.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.leaderboard,
                      size: 60,
                      color: Color(0xFF1DAB87),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No users found in leaderboard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Be the first to earn XP!',
                      style: TextStyle(fontSize: 14, color: Color(0xFF7E7E7E)),
                    ),
                  ],
                ),
              )
            else ...[
              // Top 3 Podium
              if (_leaderboardUsers.length >= 3)
                _buildPodium(_leaderboardUsers.take(3).toList()),

              const SizedBox(height: 24),

              // Leaderboard List (4th position onwards)
              if (_leaderboardUsers.length > 3)
                ..._leaderboardUsers.skip(3).toList().asMap().entries.map((
                  entry,
                ) {
                  final index = entry.key;
                  final user = entry.value;
                  final isCurrentUser = user.userId == _userProfile?.userId;
                  final rank = index + 4;

                  return _buildLeaderboardItem(
                    rank: rank,
                    name: user.username,
                    points: user.xpPoints,
                    profilePictureUrl: user.profilePictureUrl,
                    isCurrentUser: isCurrentUser,
                  );
                })
              else if (_leaderboardUsers.isNotEmpty &&
                  _leaderboardUsers.length <= 3)
                // If we have 1-3 users, show them in a list too
                ..._leaderboardUsers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final user = entry.value;
                  final isCurrentUser = user.userId == _userProfile?.userId;
                  final rank = index + 1;

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
  Widget _buildSectionHeader(
    String title,
    String actionText,
    VoidCallback? onTap,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: context.primaryText,
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
          const Icon(
            Icons.emoji_events_outlined,
            size: 50,
            color: Color(0xFF1DAB87),
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
            style: const TextStyle(fontSize: 16, color: Color(0xFF7E7E7E)),
          ),
        ],
      ),
    );
  }

  // ==================== ACTIVE CHALLENGE CARD ====================
  Widget _buildActiveChallengeCard(UserChallengeModel userChallenge) {
    final challenge = userChallenge.challenge;
    if (challenge == null) return const SizedBox.shrink();

    final progress = userChallenge.progress;
    final progressPercentage = userChallenge.progressPercentage;

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
                child:
                    challenge.imageUrl != null && challenge.imageUrl!.isNotEmpty
                    ? Image.network(
                        challenge.imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF1DAB87),
                                  const Color(0xFF1DAB87).withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image: $error');
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF1DAB87),
                                  const Color(0xFF1DAB87).withOpacity(0.7),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF1DAB87),
                              const Color(0xFF1DAB87).withOpacity(0.7),
                            ],
                          ),
                        ),
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
                              '$progress / ${challenge.targetValue} ${challenge.unit}',
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
                      _buildProgressCircle(progressPercentage),
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
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: context.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
      case 'km':
      case 'distance':
        return Icons.directions_run;
      default:
        return Icons.emoji_events;
    }
  }

  // ==================== ACHIEVEMENTS BADGES ====================
  Widget _buildAchievementsBadges() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: _userBadges.take(6).map((userBadge) {
        return _buildAchievementBadge(userBadge);
      }).toList(),
    );
  }

  // ==================== ACHIEVEMENT BADGE ====================
  Widget _buildAchievementBadge(UserBadgeModel userBadge) {
    final badge = userBadge.badge;
    if (badge == null) return const SizedBox.shrink();

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
            child: _buildBadgeIcon(badge),
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

  Widget _buildBadgeIcon(BadgeModel badge) {
    // Try local asset first
    final assetPath = BadgeIcons.getAssetPath(badge.badgeName);

    if (assetPath != null) {
      return Padding(
        padding: const EdgeInsets.all(15),
        child: Image.asset(
          assetPath,
          color: Colors.white,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 30,
            );
          },
        ),
      );
    } else if (badge.iconUrl != null && badge.iconUrl!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(15),
        child: Image.network(
          badge.iconUrl!,
          color: Colors.white,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 30,
            );
          },
        ),
      );
    } else {
      return const Icon(Icons.emoji_events, color: Colors.white, size: 30);
    }
  }

  // ==================== PODIUM (TOP 3) ====================
  Widget _buildPodium(List<UserModel> topUsers) {
    // Ensure we have 3 users
    while (topUsers.length < 3) {
      topUsers.add(
        UserModel(
          userId: '',
          username: 'No User',
          email: '',
          xpPoints: 0,
          level: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }

    final first = topUsers[0];
    final second = topUsers.length > 1 ? topUsers[1] : first;
    final third = topUsers.length > 2 ? topUsers[2] : first;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildPodiumPlace(user: second, rank: 2, height: 100),
        const SizedBox(width: 16),
        _buildPodiumPlace(user: first, rank: 1, height: 140),
        const SizedBox(width: 16),
        _buildPodiumPlace(user: third, rank: 3, height: 100),
      ],
    );
  }

  Widget _buildPodiumPlace({
    required UserModel user,
    required int rank,
    required double height,
  }) {
    final colors = {
      1: const Color(0xFFFFD700),
      2: const Color(0xFFC0C0C0),
      3: const Color(0xFFCD7F32),
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
                color: (colors[rank] ?? const Color(0xFF1DAB87)).withOpacity(
                  0.3,
                ),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: user.profilePictureUrl != null
              ? ClipOval(
                  child: Image.network(
                    user.profilePictureUrl!,
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
        SizedBox(
          width: 80,
          child: Text(
            user.username,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        Text(
          '${user.xpPoints} pts',
          style: const TextStyle(fontSize: 12, color: Color(0xFF979797)),
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

  void _onChallengeTap(UserChallengeModel userChallenge) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChallengeDetailScreen(userChallenge: userChallenge),
      ),
    );

    if (result == true) {
      _loadChallengesData();
    }
  }

  void _onJoinChallenge(ChallengeModel challenge) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF1DAB87)),
        ),
      );

      final result = await _challengeService.joinChallenge(
        challenge.challengeId,
      );
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Joined ${challenge.challengeName}! +${result['xp_added']} XP',
          ),
          backgroundColor: const Color(0xFF1DAB87),
        ),
      );

      await _loadChallengesData();
    } catch (e) {
      Navigator.pop(context);
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Color(0xFF1DAB87)),
            const SizedBox(width: 12),
            Expanded(child: Text(badge.badgeName)),
          ],
        ),
        content: Text(badge.description ?? 'Achievement unlocked!'),
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
