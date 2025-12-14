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
import 'package:powerhouse/widgets/skeleton_widgets.dart';
import 'package:powerhouse/widgets/challenges/active_challenge_card.dart';
import 'package:powerhouse/widgets/challenges/available_challenge_card.dart';

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
  bool _isSyncing = false;

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

  Future<void> _syncHealthData() async {
    setState(() => _isSyncing = true);
    try {
      final hasPermissions = await _challengeService.requestHealthPermissions();
      if (!hasPermissions) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Health permissions needed to sync data'),
              backgroundColor: context.accentColor,
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => _challengeService.requestHealthPermissions(),
              ),
            ),
          );
        }
        setState(() => _isSyncing = false);
        return;
      }

      int syncedCount = 0;
      for (final userChallenge in _activeChallenges) {
        final unit = userChallenge.challenge?.unit.toLowerCase() ?? '';
        if (['steps', 'calories', 'distance', 'km'].contains(unit)) {
          await _challengeService.syncHealthData(
            userChallenge.challengeId,
            unit,
          );
          syncedCount++;
        }
      }

      await _loadChallengesData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Synced health data for $syncedCount active challenges',
            ),
            backgroundColor: context.primaryColor,
          ),
        );
      }
    } catch (e) {
      print('Sync Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to sync health data'),
            backgroundColor: context.accentColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.surfaceColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header Skeleton
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    SkeletonText(width: 150, height: 32),
                    SkeletonCircle(size: 50),
                  ],
                ),
              ),

              // Tab Selector Skeleton
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 38.0),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.inputBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Content Skeleton
              Expanded(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Active Challenges Section
                        const SkeletonText(width: 180, height: 24),
                        const SizedBox(height: 16),

                        // Active Challenge Cards Skeleton
                        ...List.generate(
                          2,
                          (index) => const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: SkeletonCard(height: 178),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Available Challenges Section
                        const SkeletonText(width: 200, height: 24),
                        const SizedBox(height: 16),

                        // Available Challenge Cards Skeleton
                        ...List.generate(
                          4,
                          (index) => const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: SkeletonCard(height: 120),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
              border: Border.all(color: context.primaryColor, width: 2),
            ),
            child: ClipOval(
              child: _userProfile?.profilePictureUrl != null
                  ? Image.network(
                      _userProfile!.profilePictureUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildProfileFallback();
                      },
                    )
                  : _buildProfileFallback(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileFallback() {
    return Image.asset(
      'assets/images/profile_male.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: context.primaryColor,
          child: Icon(Icons.person, color: Colors.white, size: 30),
        );
      },
    );
  }

  // ==================== TAB SELECTOR ====================
  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 38.0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: context.inputBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: context.borderColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedTab = 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: selectedTab == 0
                        ? context.primaryColor
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
                        color: selectedTab == 0
                            ? Colors.white
                            : context.primaryText,
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
                        ? context.primaryColor
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
                        color: selectedTab == 1
                            ? Colors.white
                            : context.primaryText,
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
            _buildSectionHeader(
              'Active Challenges',
              _isSyncing ? 'Syncing...' : 'Sync Data',
              _isSyncing ? null : _syncHealthData,
            ),

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
    print('ðŸ” Leaderboard users count: ${_leaderboardUsers.length}');

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
                  color: context.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.borderColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.leaderboard,
                      size: 60,
                      color: context.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No users found in leaderboard',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: context.primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to earn XP!',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.secondaryText,
                      ),
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: context.accentColor,
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
        color: context.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 50,
            color: context.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: context.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: context.secondaryText),
          ),
        ],
      ),
    );
  }

  // ==================== ACTIVE CHALLENGE CARD ====================
  Widget _buildActiveChallengeCard(UserChallengeModel userChallenge) {
    if (userChallenge.challenge == null) return const SizedBox.shrink();
    return ActiveChallengeCard(
      userChallenge: userChallenge,
      onTap: () => _onChallengeTap(userChallenge),
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
    return AvailableChallengeCard(
      challenge: challenge,
      onJoin: () => _onJoinChallenge(challenge),
    );
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
              color: context.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.primaryColor.withOpacity(0.3),
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
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.primaryText,
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
                color: (colors[rank] ?? context.primaryColor).withOpacity(0.3),
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.primaryText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        Text(
          '${user.xpPoints} pts',
          style: TextStyle(fontSize: 12, color: context.secondaryText),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: (colors[rank] ?? context.primaryColor).withOpacity(0.3),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            border: Border.all(
              color: (colors[rank] ?? context.primaryColor).withOpacity(0.5),
              width: 2,
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
            ? context.primaryColor.withOpacity(0.1)
            : context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser
              ? context.primaryColor
              : context.borderColor.withOpacity(0.5),
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.primaryColor.withOpacity(0.2),
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
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: context.primaryColor,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      rank.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: context.primaryColor,
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
                color: isCurrentUser
                    ? context.primaryColor
                    : context.primaryText,
              ),
            ),
          ),
          Text(
            '$points pts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.primaryColor,
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
        builder: (context) => Center(
          child: CircularProgressIndicator(color: context.primaryColor),
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
          backgroundColor: context.primaryColor,
        ),
      );

      await _loadChallengesData();
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to join challenge'),
          backgroundColor: context.accentColor,
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
        backgroundColor: context.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: context.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                badge.badgeName,
                style: TextStyle(color: context.primaryText),
              ),
            ),
          ],
        ),
        content: Text(
          badge.description ?? 'Achievement unlocked!',
          style: TextStyle(color: context.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: context.primaryColor)),
          ),
        ],
      ),
    );
  }
}
