import 'package:flutter/material.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:powerhouse/models/user_challenge_model.dart';
import 'package:powerhouse/models/challenge_model.dart';
import 'package:powerhouse/services/challenge_service.dart';
import 'package:powerhouse/services/health_service.dart';
import 'package:powerhouse/core/config/supabase_config.dart';
import 'dart:async';

class ChallengeDetailScreen extends StatefulWidget {
  final UserChallengeModel userChallenge;

  const ChallengeDetailScreen({super.key, required this.userChallenge});

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  final _challengeService = ChallengeService();
  final _healthService = HealthService();

  late UserChallengeModel _userChallenge;
  final bool _isLoading = false;
  bool _isSyncing = false;
  bool _hasHealthPermission = false;
  List<Map<String, dynamic>> _leaderboard = [];
  Timer? _autoSyncTimer;

  @override
  void initState() {
    super.initState();
    _userChallenge = widget.userChallenge;
    _checkHealthPermissions();
    _loadLeaderboard();
    _startAutoSync();
  }

  @override
  void dispose() {
    _autoSyncTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkHealthPermissions() async {
    if (_isHealthTrackableChallenge()) {
      final granted = await _healthService.requestPermissions();
      setState(() {
        _hasHealthPermission = granted;
      });

      if (granted) {
        _syncHealthData();
      }
    }
  }

  bool _isHealthTrackableChallenge() {
    final unit = _userChallenge.challenge?.unit.toLowerCase() ?? '';
    return unit == 'steps' ||
        unit == 'calories' ||
        unit == 'km' ||
        unit == 'distance';
  }

  void _startAutoSync() {
    if (_isHealthTrackableChallenge() && _hasHealthPermission) {
      // Auto-sync every 5 minutes
      _autoSyncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
        _syncHealthData();
      });
    }
  }

  Future<void> _syncHealthData() async {
    if (!_hasHealthPermission || _isSyncing) return;

    setState(() {
      _isSyncing = true;
    });

    try {
      final result = await _challengeService.syncHealthData(
        _userChallenge.challengeId,
        _userChallenge.challenge?.unit ?? '',
      );

      // Refresh challenge data
      final updated = await _challengeService.getUserChallenge(
        _userChallenge.challengeId,
      );
      if (updated != null) {
        setState(() {
          _userChallenge = updated;
        });
      }

      if (result['completed'] == true) {
        _showCompletionDialog(result['xp_reward']);
      }
    } catch (e) {
      print('Error syncing: $e');
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<void> _loadLeaderboard() async {
    try {
      print('📊 Loading leaderboard in UI...');
      final leaderboard = await _challengeService.getGlobalLeaderboard();
      print('📊 Received ${leaderboard.length} users in UI');
      print('📊 Leaderboard data: $leaderboard');
      setState(() {
        _leaderboard = leaderboard;
      });
      print('📊 State updated with ${_leaderboard.length} users');
    } catch (e) {
      print('Error loading leaderboard: $e');
    }
  }

  void _showCompletionDialog(int xpReward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🎉 Challenge Completed!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Congratulations! You completed the challenge!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1DAB87).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+$xpReward XP',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFF97316),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true); // Return to challenges screen
            },
            child: const Text(
              'Awesome!',
              style: TextStyle(
                color: Color(0xFF1DAB87),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final challenge = _userChallenge.challenge;
    if (challenge == null) {
      return Scaffold(
        backgroundColor: context.surfaceColor,
        appBar: AppBar(
          backgroundColor: context.surfaceColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.primaryText),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text('Challenge not found')),
      );
    }

    final progress = _userChallenge.progress;
    final target = challenge.targetValue;
    final progressPercentage = _userChallenge.progressPercentage;
    final daysLeft = _userChallenge.daysRemaining;

    return Scaffold(
      backgroundColor: context.surfaceColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          _buildSliverAppBar(challenge),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Challenge Info
                  Text(
                    challenge.challengeName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: context.primaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (challenge.description != null)
                    Text(
                      challenge.description!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF7E7E7E),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Progress Stats
                  _buildProgressStats(
                    progress,
                    target,
                    challenge.unit,
                    daysLeft!,
                  ),

                  const SizedBox(height: 24),

                  // Progress Bar
                  _buildProgressBar(progressPercentage, progress, target),

                  const SizedBox(height: 32),

                  // Sync Button (for health-trackable challenges)
                  if (_isHealthTrackableChallenge()) _buildSyncButton(),

                  const SizedBox(height: 24),

                  // Leaderboard
                  _buildLeaderboardSection(),

                  const SizedBox(height: 24),

                  // Tips Section
                  _buildTipsSection(challenge.unit),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ChallengeModel challenge) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: const Color(0xFF1DAB87),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            if (challenge.imageUrl != null)
              Image.network(
                challenge.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: const Color(0xFF1DAB87));
                },
              )
            else
              Container(
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

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStats(
    int progress,
    int target,
    String unit,
    int daysLeft,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1DAB87).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              label: 'Progress',
              value: '$progress',
              unit: unit,
              icon: Icons.trending_up,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: const Color(0xFF1DAB87).withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              label: 'Target',
              value: '$target',
              unit: unit,
              icon: Icons.flag,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: const Color(0xFF1DAB87).withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              label: 'Days Left',
              value: '$daysLeft',
              unit: 'days',
              icon: Icons.calendar_today,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF1DAB87), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF7E7E7E),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF7E7E7E)),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double percentage, int progress, int target) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overall Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.primaryText,
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1DAB87),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0x9ED9D9D9),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1DAB87), Color(0xFF15c497)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1DAB87).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$progress completed',
              style: const TextStyle(fontSize: 12, color: Color(0xFF7E7E7E)),
            ),
            Text(
              '${target - progress} remaining',
              style: const TextStyle(fontSize: 12, color: Color(0xFF7E7E7E)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSyncButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isSyncing ? null : _syncHealthData,
        icon: _isSyncing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.sync, size: 24),
        label: Text(
          _isSyncing ? 'Syncing...' : 'Sync Health Data',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1DAB87),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardSection() {
    final currentUserId = SupabaseConfig.currentUserId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Leaderboard',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: context.primaryText,
          ),
        ),
        const SizedBox(height: 16),
        if (_leaderboard.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'No participants yet',
                style: TextStyle(fontSize: 14, color: Color(0xFF7E7E7E)),
              ),
            ),
          )
        else
          ..._leaderboard.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            final userId = data['user_id'] as String?;
            final isCurrentUser = userId == currentUserId;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? const Color(0xFF1DAB87).withOpacity(0.2)
                    : index < 3
                    ? const Color(0xFF1DAB87).withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCurrentUser
                      ? const Color(0xFF1DAB87)
                      : index < 3
                      ? const Color(0xFF1DAB87)
                      : const Color(0xFFE0E0E0),
                  width: isCurrentUser || index < 3 ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Rank
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCurrentUser
                          ? const Color(0xFF1DAB87)
                          : index < 3
                          ? const Color(0xFF1DAB87)
                          : const Color(0xFFE0E0E0),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isCurrentUser || index < 3
                              ? Colors.white
                              : context.primaryText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Name
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            data['username'] ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isCurrentUser
                                  ? const Color(0xFF1DAB87)
                                  : Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCurrentUser) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1DAB87),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'YOU',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // XP Points
                  Text(
                    '${data['xp_points']} XP',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1DAB87),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildTipsSection(String unit) {
    final tips = _getTips(unit.toLowerCase());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tips to Complete',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        ...tips.map((tip) => _buildTipItem(tip)),
      ],
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2),
            decoration: const BoxDecoration(
              color: Color(0xFF1DAB87),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF444444),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getTips(String unit) {
    switch (unit) {
      case 'steps':
        return [
          'Take the stairs instead of elevator',
          'Park your vehicle farther from your destination',
          'Walk during phone calls',
          'Set hourly reminders to move',
          'Join walking groups or buddy up',
        ];
      case 'calories':
        return [
          'Combine cardio and strength training',
          'High-intensity interval training (HIIT) burns more',
          'Stay consistent with your workout schedule',
          'Track your food intake',
          'Stay hydrated throughout the day',
        ];
      case 'km':
      case 'distance':
        return [
          'Plan your routes in advance',
          'Mix walking, jogging, and running',
          'Explore new areas to stay motivated',
          'Use a fitness tracker for accuracy',
          'Join virtual marathons',
        ];
      case 'workouts':
        return [
          'Schedule workouts in your calendar',
          'Start with shorter sessions if needed',
          'Mix different workout types',
          'Find a workout buddy for accountability',
          'Rest and recovery are important too',
        ];
      default:
        return [
          'Stay consistent',
          'Track your progress daily',
          'Stay motivated',
          'Join community challenges',
          'Celebrate small wins',
        ];
    }
  }
}
