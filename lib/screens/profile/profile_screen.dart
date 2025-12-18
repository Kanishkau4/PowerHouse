import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:powerhouse/screens/tips/bookmarked_tips_screen.dart';
import 'package:powerhouse/widgets/animated_message.dart';
import 'package:provider/provider.dart';
import 'package:powerhouse/screens/profile/edit_profile_screen.dart';
import 'package:powerhouse/screens/profile/help_support_screen.dart';
import 'package:powerhouse/screens/profile/notifications_screen.dart';
import 'package:powerhouse/services/user_service.dart';
import 'package:powerhouse/services/badge_service.dart';
import 'package:powerhouse/services/weight_history_service.dart';
import 'package:powerhouse/services/workout_service.dart';
import 'package:powerhouse/services/daily_tasks_service.dart';
import 'package:powerhouse/models/user_model.dart';
import 'package:powerhouse/models/user_badge_model.dart';
import 'package:powerhouse/models/weight_history_model.dart';
import 'package:powerhouse/core/config/supabase_config.dart';
import 'package:powerhouse/core/constants/badge_icons.dart';
import 'package:powerhouse/core/theme/theme_provider.dart';
import 'package:powerhouse/widgets/skeleton_widgets.dart';
import 'dart:math' as math;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Services
  final _userService = UserService();
  final _badgeService = BadgeService();
  final _weightHistoryService = WeightHistoryService();
  final _workoutService = WorkoutService();
  final _dailyTasksService = DailyTasksService();

  // User data
  UserModel? _userProfile;
  List<UserBadgeModel> _userBadges = [];
  List<WeightHistoryModel> _weightHistory = [];
  Map<DateTime, int> _workoutDuration = {};
  int _currentStreak = 0;

  // Settings
  String selectedLanguage = 'English';

  // Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load user profile
      final profile = await _userService.getCurrentUserProfile();

      // Load user badges
      final badges = await _badgeService.getUserBadges();

      // Load weight history (last 30 days)
      final weightHistory = await _weightHistoryService.getWeightHistory(30);

      // Load workout duration (last 7 days)
      final workoutDuration = await _workoutService.getWorkoutDurationByDay(7);

      // Check if user logged weight today
      final hasLoggedToday = await _weightHistoryService.hasLoggedWeightToday();

      // Get Current Streak
      final streak = await _dailyTasksService.getCurrentStreak();

      print('✅ Loaded ${badges.length} badges for user');
      print('✅ Loaded ${weightHistory.length} weight entries');
      print('✅ Loaded ${workoutDuration.length} workout days');

      setState(() {
        _userProfile = profile;
        _userBadges = badges;
        _weightHistory = weightHistory;
        _workoutDuration = workoutDuration;
        _currentStreak = streak;
        _isLoading = false;
      });

      // Show weight prompt if not logged today
      if (!hasLoggedToday && mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _showWeightLogDialog();
        });
      }
    } catch (e) {
      print('Error loading profile data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Profile Header Skeleton
                const Center(
                  child: Column(
                    children: [
                      SkeletonCircle(size: 150),
                      SizedBox(height: 16),
                      SkeletonText(width: 150, height: 24),
                      SizedBox(height: 8),
                      SkeletonText(width: 120, height: 16),
                      SizedBox(height: 12),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 60),
                        child: SkeletonContainer(height: 8),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Stats Cards Skeleton
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonText(width: 130, height: 22),
                      const SizedBox(height: 16),
                      Row(
                        children: const [
                          Expanded(child: SkeletonCard(height: 100)),
                          SizedBox(width: 12),
                          Expanded(child: SkeletonCard(height: 100)),
                          SizedBox(width: 12),
                          Expanded(child: SkeletonCard(height: 100)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Weight Progress Chart Skeleton
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonText(width: 150, height: 20),
                      SizedBox(height: 16),
                      SkeletonChart(height: 250),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Workout Time Chart Skeleton
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonText(width: 130, height: 20),
                      SizedBox(height: 16),
                      SkeletonChart(height: 220),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildProfileHeader(isDarkMode),
              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stats Overview',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatsCards(isDarkMode),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Weight Progress Chart
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weight Progress',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildWeightProgressChart(isDarkMode),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Workout Time Chart
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workout Time',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildWorkoutTimeChart(isDarkMode),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildSettingsSection(isDarkMode),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== PROFILE HEADER ====================
  Widget _buildProfileHeader(bool isDarkMode) {
    return Column(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF1DAB87), width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1DAB87).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
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

        const SizedBox(height: 16),

        Text(
          _userProfile?.username ?? 'User',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),

        const SizedBox(height: 8),

        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Level ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white70 : Colors.black,
                ),
              ),
              TextSpan(
                text: '${_userProfile?.level ?? 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1DAB87),
                ),
              ),
              TextSpan(
                text: ' • ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white70 : Colors.black,
                ),
              ),
              TextSpan(
                text: '${_userProfile?.xpPoints ?? 0} XP',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF97316),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey.shade800
                      : const Color(0x9ED9D9D9),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              FractionallySizedBox(
                widthFactor: _userProfile != null
                    ? _userProfile!.levelProgress
                    : 0.0,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1DAB87),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _userProfile != null
              ? 'XP to next level: ${_userProfile!.xpNeededForNextLevel}'
              : 'XP to next level: 100',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF7E7E7E),
          ),
        ),
        SizedBox(height: 12),
        // Sleek Bar-style Streak Badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 8,
          ), // wider, lower height
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(40), // pill shape
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B35).withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6), // smaller circle
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const FaIcon(
                  FontAwesomeIcons.fire,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$_currentStreak Day Streak ⚡',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      color: const Color(0xFF1DAB87),
      child: Center(
        child: Text(
          _userProfile?.username.substring(0, 1).toUpperCase() ?? 'U',
          style: const TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ==================== STATS CARDS ====================
  Widget _buildStatsCards(bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.monitor_weight_outlined,
            label: 'Weight',
            value: _userProfile?.currentWeight != null
                ? _userProfile!.currentWeight!.toStringAsFixed(1)
                : 'N/A',
            unit: 'kg',
            isDarkMode: isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.height,
            label: 'Height',
            value: _userProfile?.height != null
                ? _userProfile!.height!.toStringAsFixed(0)
                : 'N/A',
            unit: 'cm',
            isDarkMode: isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.favorite_outline,
            label: 'BMI',
            value: _userProfile?.bmi != null
                ? _userProfile!.bmi!.toStringAsFixed(1)
                : 'N/A',
            unit: '',
            isDarkMode: isDarkMode,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required bool isDarkMode,
  }) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: const Color(0xFF1DAB87)),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7E7E7E),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 1),
                  child: Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7E7E7E),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== WEIGHT PROGRESS CHART ====================
  Widget _buildWeightProgressChart(bool isDarkMode) {
    if (_weightHistory.isEmpty) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No weight data yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start logging your weight to see progress',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }
    // Prepare data for chart
    final spots = <FlSpot>[];
    final targetSpots = <FlSpot>[];

    for (int i = 0; i < _weightHistory.length; i++) {
      spots.add(FlSpot(i.toDouble(), _weightHistory[i].weight));
      // Target weight line (2kg less than current weight as goal)
      final targetWeight = _userProfile?.currentWeight != null
          ? _userProfile!.currentWeight! -
                2 // Goal: 2kg less than current
          : _weightHistory[i].weight - 2;
      targetSpots.add(FlSpot(i.toDouble(), targetWeight));
    }

    // Calculate min/max including both actual and target weights
    final allWeights = [
      ...spots.map((e) => e.y),
      ...targetSpots.map((e) => e.y),
    ];
    final minWeight = allWeights.reduce(math.min) - 2;
    final maxWeight = allWeights.reduce(math.max) + 2;
    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with current and goal weight
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFF06B6D4), // Cyan
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_weightHistory.last.weight.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF06B6D4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Goal',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFF97316), // Orange
                            width: 2,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${targetSpots.last.y.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF97316),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Chart
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade300.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: math.max(
                        1,
                        (_weightHistory.length / 6).ceil().toDouble(),
                      ),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < _weightHistory.length) {
                          final date = _weightHistory[index].recordedAt;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${date.day}/${date.month}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (spots.length - 1).toDouble(),
                minY: minWeight,
                maxY: maxWeight,
                lineBarsData: [
                  // Actual weight line (solid cyan)
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFF06B6D4), // Cyan
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: const Color(0xFF06B6D4),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF06B6D4).withOpacity(0.3),
                          const Color(0xFF06B6D4).withOpacity(0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Target weight line (dotted orange)
                  LineChartBarData(
                    spots: targetSpots,
                    isCurved: true,
                    color: const Color(0xFFF97316), // Orange
                    barWidth: 2,
                    dashArray: [8, 4],
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== WORKOUT TIME CHART ====================
  Widget _buildWorkoutTimeChart(bool isDarkMode) {
    if (_workoutDuration.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No workout data yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete workouts to see your activity',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }
    // Prepare data for last 7 days
    final now = DateTime.now();
    final barGroups = <BarChartGroupData>[];
    final dayLabels = <String>[];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final duration = _workoutDuration[date] ?? 0;

      barGroups.add(
        BarChartGroupData(
          x: 6 - i,
          barRods: [
            BarChartRodData(
              toY: duration.toDouble(),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1DAB87),
                  const Color(0xFF1DAB87).withOpacity(0.7),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: 24,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );

      // Day labels
      final weekday = [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ][date.weekday - 1];
      dayLabels.add(weekday);
    }
    final maxDuration = _workoutDuration.values.isEmpty
        ? 60.0
        : _workoutDuration.values.reduce(math.max).toDouble();
    final totalMinutes = _workoutDuration.values.fold(
      0,
      (sum, val) => sum + val,
    );
    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Week',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalMinutes min',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1DAB87),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1DAB87).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 16,
                      color: const Color(0xFF1DAB87),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_workoutDuration.values.where((v) => v > 0).length} days',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1DAB87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Bar Chart
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: math.max(60, maxDuration + 10),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} min',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < dayLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              dayLabels[index],
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: 20,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade300.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SETTINGS SECTION ====================
  Widget _buildSettingsSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x26D9D9D9), // Always 15% #D9D9D9, even in dark mode
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Consistent soft shadow
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            title: 'Edit Profile',
            onTap: () => _onEditProfile(),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF979797),
            ),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            title: 'My Achievements / Badges',
            onTap: () => _onAchievements(),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF979797),
            ),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            title: 'Notifications',
            onTap: () => _onNotifications(),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF979797),
            ),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            title: 'Bookmark',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookmarkedTipsScreen(),
                ),
              );
            },
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF979797),
            ),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            title: 'Help & Support',
            onTap: () => _onHelpSupport(),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF979797),
            ),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            title: 'Dark Mode',
            trailing: _buildToggleSwitch(
              value: isDarkMode,
              onChanged: (value) {
                Provider.of<ThemeProvider>(
                  context,
                  listen: false,
                ).toggleTheme();
              },
            ),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            title: 'Language',
            subtitle: '($selectedLanguage)',
            onTap: () => _onLanguageSelect(),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF979797),
            ),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            title: 'Logout',
            onTap: () => _onLogout(),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.red,
            ),
            titleColor: Colors.red,
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  String? _getIconAsset(String title) {
    switch (title) {
      case 'Edit Profile':
        return 'assets/icons/Edit Profile.png';
      case 'My Achievements / Badges':
        return 'assets/icons/Trophy.png';
      case 'Notifications':
        return 'assets/icons/Notification.png';
      case 'Bookmark':
        return 'assets/icons/Bookmark.png';
      case 'Help & Support':
        return 'assets/icons/Help.png';
      case 'Dark Mode':
        return 'assets/icons/Dark mode.png';
      case 'Language':
        return 'assets/icons/Language.png';
      case 'Logout':
        return 'assets/icons/Logout.png';
      default:
        return null;
    }
  }

  Widget _buildSettingsItem({
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color? titleColor,
    required bool isDarkMode,
  }) {
    final iconAsset = _getIconAsset(title);

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          // ✅ NO BACKGROUND CONTAINER — just the icon/image
          SizedBox(
            width: 26,
            height: 26,
            child: iconAsset != null
                ? Image.asset(
                    iconAsset,
                    fit: BoxFit.contain,
                    // Optional: tint icon if it's monochrome
                    color:
                        titleColor ??
                        (isDarkMode ? Colors.white : Colors.black),
                  )
                : const Icon(Icons.help_outline, size: 24, color: Colors.grey),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color:
                          titleColor ??
                          (isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                  if (subtitle != null)
                    TextSpan(
                      text: ' $subtitle',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xCE7E7E7E),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildToggleSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 44,
        height: 25,
        decoration: BoxDecoration(
          color: value ? const Color(0xFF1DAB87) : const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== HANDLERS ====================

  void _onAchievements() {
    print('🎯 Showing ${_userBadges.length} badges');
    _showAchievementsDialog();
  }

  Future<void> _onEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );

    if (result == true) {
      _loadProfileData();
    }
  }

  void _onNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
  }

  void _onHelpSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
    );
  }

  void _onLanguageSelect() {
    _showLanguageDialog();
  }

  void _onLogout() {
    final isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Logout',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handleLogout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF1DAB87)),
        ),
      );

      await SupabaseConfig.client.auth.signOut();

      if (mounted) Navigator.pop(context);

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/welcome',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);

      print('Logout error: $e');
      if (mounted) {
        AnimatedMessage.show(
          context,
          message: 'Failed to logout: ${e.toString()}',
          backgroundColor: Colors.red,
          icon: Icons.error,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  void _showAchievementsDialog() {
    final isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'My Achievements',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_userBadges.length} badges earned',
              style: const TextStyle(fontSize: 14, color: Color(0xFF7E7E7E)),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _userBadges.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.emoji_events_outlined,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No achievements yet!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7E7E7E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Keep working out to earn badges.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7E7E7E),
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 0.8,
                          ),
                      itemCount: _userBadges.length,
                      itemBuilder: (context, index) {
                        return _buildAchievementBadge(_userBadges[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(UserBadgeModel userBadge) {
    final badge = userBadge.badge;
    if (badge == null) return const SizedBox.shrink();

    // Try to get local asset path
    final assetPath = BadgeIcons.getAssetPath(badge.badgeName);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Gold color for badges (same in both modes for visibility)
    const goldColor = Color(0xFFFFD700);

    return GestureDetector(
      onTap: () => _showBadgeDetail(badge),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          // ✅ Optional: subtle background in dark mode for better visibility
          color: isDark
              ? context.cardBackground.withOpacity(0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge icon without background circle
            SizedBox(
              width: 90,
              height: 90,
              child: assetPath != null
                  ? Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.emoji_events,
                          color: goldColor,
                          size: 70,
                        );
                      },
                    )
                  : (badge.iconUrl != null && badge.iconUrl!.isNotEmpty
                        ? Image.network(
                            badge.iconUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.emoji_events,
                                color: goldColor,
                                size: 70,
                              );
                            },
                          )
                        : const Icon(
                            Icons.emoji_events,
                            color: goldColor,
                            size: 70,
                          )),
            ),
            const SizedBox(height: 8),
            Text(
              badge.badgeName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.primaryText,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetail(dynamic badge) {
    final isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF1DAB87),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                badge.badgeName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              badge.description ?? 'Achievement unlocked!',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            if (badge.requirementDescription != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1DAB87).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF1DAB87),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        badge.requirementDescription,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1DAB87),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(
                color: Color(0xFF1DAB87),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Select Language',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English', isDarkMode),
            _buildLanguageOption('Sinhala', isDarkMode),
            _buildLanguageOption('Tamil', isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language, bool isDarkMode) {
    final isSelected = selectedLanguage == language;
    return ListTile(
      title: Text(
        language,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFF1DAB87))
          : null,
      onTap: () {
        setState(() {
          selectedLanguage = language;
        });
        Navigator.pop(context);
      },
    );
  }

  // ==================== WEIGHT LOG DIALOG ====================
  void _showWeightLogDialog() {
    final isDarkMode = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;
    final weightController = TextEditingController(
      text: _userProfile?.currentWeight?.toStringAsFixed(1) ?? '',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1DAB87).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.monitor_weight_outlined,
                color: Color(0xFF1DAB87),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Log Your Weight',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Track your progress by logging your current weight',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autofocus: true,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                labelStyle: TextStyle(color: Colors.grey.shade600),
                suffixText: 'kg',
                suffixStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
                filled: true,
                fillColor: isDarkMode
                    ? Colors.grey.shade800.withOpacity(0.3)
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF1DAB87),
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Skip',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final weight = double.tryParse(weightController.text);
              if (weight != null && weight > 0) {
                try {
                  await _weightHistoryService.addWeightEntry(weight);
                  Navigator.pop(context);
                  _loadProfileData(); // Reload data

                  if (mounted) {
                    AnimatedMessage.show(
                      context,
                      message: 'Weight logged successfully!',
                      backgroundColor: Color(0xFF1DAB87),
                      icon: Icons.check_circle_rounded,
                      duration: const Duration(seconds: 2),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    AnimatedMessage.show(
                      context,
                      message: 'Error: ${e.toString()}',
                      backgroundColor: Colors.red,
                      icon: Icons.error,
                      duration: const Duration(seconds: 2),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1DAB87),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
