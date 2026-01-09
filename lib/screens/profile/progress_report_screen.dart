import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:powerhouse/services/stats_service.dart';
import 'package:powerhouse/services/progress_service.dart';
import 'package:provider/provider.dart';
import 'package:powerhouse/core/theme/theme_provider.dart';
import 'package:intl/intl.dart';

class ProgressReportScreen extends StatefulWidget {
  final String reportType; // 'weekly' or 'monthly'

  const ProgressReportScreen({super.key, required this.reportType});

  @override
  State<ProgressReportScreen> createState() => _ProgressReportScreenState();
}

class _ProgressReportScreenState extends State<ProgressReportScreen> {
  final _statsService = StatsService();
  final _progressService = ProgressService();

  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _totalWorkouts = 0;
  int _totalCalories = 0;
  int _totalFoodLogs = 0;
  int _totalChallenges = 0;
  int _totalXP = 0;
  int _currentLevel = 1;
  double _levelProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
      });

      print('📊 Loading progress data for ${widget.reportType} report...');

      // Fetch all statistics
      final workouts = await _statsService.getTotalWorkoutsCount();
      final calories = await _statsService.getTotalCaloriesBurned();
      final foodLogs = await _statsService.getTotalFoodLogsCount();
      final challenges = await _statsService.getTotalChallengesCompleted();
      final xp = await _statsService.getTotalXpEarned();
      final progressStats = await _progressService.getUserProgressStats();

      print('✅ Progress data loaded successfully');

      if (!mounted) return;

      setState(() {
        _totalWorkouts = workouts;
        _totalCalories = calories;
        _totalFoodLogs = foodLogs;
        _totalChallenges = challenges;
        _totalXP = xp;
        _currentLevel = progressStats['current_level'] ?? 1;
        _levelProgress = progressStats['level_progress'] ?? 0.0;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      print('❌ Error loading progress data: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load progress data. Please try again.';
      });
    }
  }

  String _getDateRange() {
    final now = DateTime.now();
    if (widget.reportType == 'weekly') {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      return '${DateFormat('MMM d').format(startOfWeek)} - ${DateFormat('MMM d, yyyy').format(endOfWeek)}';
    } else {
      final startOfMonth = DateTime(now.year, now.month, 1);
      return DateFormat('MMMM yyyy').format(startOfMonth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.reportType == 'weekly' ? 'Weekly Report' : 'Monthly Report',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1DAB87)),
            )
          : _hasError
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.5)
                          : Colors.black.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.7)
                            : Colors.black.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadProgressData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1DAB87),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadProgressData,
              color: const Color(0xFF1DAB87),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                children: [
                  // Date Range
                  _buildDateRangeCard(isDarkMode),
                  const SizedBox(height: 24),

                  // Summary Stats
                  _buildSummarySection(isDarkMode),
                  const SizedBox(height: 24),

                  // Level Progress
                  _buildLevelProgressCard(isDarkMode),
                  const SizedBox(height: 24),

                  // Activity Breakdown
                  _buildActivityBreakdown(isDarkMode),
                  const SizedBox(height: 24),

                  // Motivational Message
                  _buildMotivationalMessage(isDarkMode),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildDateRangeCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1DAB87), Color(0xFF16896D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1DAB87).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.reportType == 'weekly' ? 'This Week' : 'This Month',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getDateRange(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: FontAwesomeIcons.dumbbell,
                label: 'Workouts',
                value: _totalWorkouts.toString(),
                color: const Color(0xFF1DAB87),
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: FontAwesomeIcons.fire,
                label: 'Calories',
                value: _totalCalories.toString(),
                color: const Color(0xFFFF6B6B),
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: FontAwesomeIcons.utensils,
                label: 'Meals Logged',
                value: _totalFoodLogs.toString(),
                color: const Color(0xFFFFB84D),
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: FontAwesomeIcons.trophy,
                label: 'Challenges',
                value: _totalChallenges.toString(),
                color: const Color(0xFF9B59B6),
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? context.cardBackground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FaIcon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.6)
                  : Colors.black.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgressCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? context.cardBackground : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level Progress',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1DAB87), Color(0xFF16896D)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Level $_currentLevel',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _levelProgress,
              minHeight: 12,
              backgroundColor: isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF1DAB87),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_totalXP XP',
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.7)
                      : Colors.black.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(_levelProgress * 100).toInt()}% to Level ${_currentLevel + 1}',
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.7)
                      : Colors.black.withOpacity(0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBreakdown(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? context.cardBackground : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Breakdown',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(height: 200, child: _buildPieChart(isDarkMode)),
        ],
      ),
    );
  }

  Widget _buildPieChart(bool isDarkMode) {
    final total = _totalWorkouts + _totalFoodLogs + _totalChallenges;
    if (total == 0) {
      return Center(
        child: Text(
          'No activity data yet',
          style: TextStyle(
            color: isDarkMode
                ? Colors.white.withOpacity(0.5)
                : Colors.black.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
      );
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 50,
        sections: [
          PieChartSectionData(
            value: _totalWorkouts.toDouble(),
            title: '${((_totalWorkouts / total) * 100).toInt()}%',
            color: const Color(0xFF1DAB87),
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: _totalFoodLogs.toDouble(),
            title: '${((_totalFoodLogs / total) * 100).toInt()}%',
            color: const Color(0xFFFFB84D),
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: _totalChallenges.toDouble(),
            title: '${((_totalChallenges / total) * 100).toInt()}%',
            color: const Color(0xFF9B59B6),
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalMessage(bool isDarkMode) {
    String message;
    IconData icon;
    Color color;

    if (_totalWorkouts >= 20) {
      message = "Outstanding! You're crushing your fitness goals! 🔥";
      icon = FontAwesomeIcons.fire;
      color = const Color(0xFFFF6B6B);
    } else if (_totalWorkouts >= 10) {
      message = "Great work! Keep up the momentum! 💪";
      icon = FontAwesomeIcons.dumbbell;
      color = const Color(0xFF1DAB87);
    } else if (_totalWorkouts >= 5) {
      message = "Good progress! You're on the right track! ⭐";
      icon = FontAwesomeIcons.star;
      color = const Color(0xFFFFB84D);
    } else {
      message = "Every journey starts with a single step. Keep going! 🚀";
      icon = FontAwesomeIcons.rocket;
      color = const Color(0xFF9B59B6);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
