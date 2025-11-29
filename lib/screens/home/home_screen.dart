import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Add this import
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:powerhouse/screens/workouts/workout_detail_screen.dart';
import 'package:powerhouse/services/user_service.dart';
import 'package:powerhouse/services/workout_service.dart';
import 'package:powerhouse/services/daily_tasks_service.dart';
import 'package:powerhouse/services/progress_service.dart';
import 'package:powerhouse/services/tips_service.dart';
import 'package:powerhouse/screens/tips/tips_library_screen.dart';
import 'package:powerhouse/widgets/animated_message.dart';
import 'package:powerhouse/widgets/tips/tip_of_day_card.dart';
import 'package:powerhouse/widgets/skeleton_widgets.dart';
import 'package:powerhouse/models/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Services
  final _userService = UserService();
  final _workoutService = WorkoutService();
  final _dailyTasksService = DailyTasksService();
  final _progressService = ProgressService();
  final _tipsService = TipsService();
  // User data
  String userName = 'User';
  String? profilePictureUrl;

  // Daily progress
  int completedTasks = 0;
  int totalTasks = 0;

  // Workouts
  List<Map<String, dynamic>> workouts = [];

  // Daily tasks
  List<Map<String, dynamic>> dailyTasks = [];

  // Loading state
  bool _isLoading = true;

  // Tip of the day
  TipModel? tipOfTheDay;
  bool _isTipLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  // ========== LOAD ALL HOME SCREEN DATA ==========
  Future<void> _loadHomeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load user profile
      await _loadUserProfile();

      // Load daily tasks
      await _loadDailyTasks();

      // Load recommended workouts
      await _loadWorkouts();

      // Award daily login XP (once per day)
      await _awardDailyLoginXP();

      // Load tip of the day
      await _loadTipOfTheDay();
    } catch (e) {
      print('Error loading home data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ========== LOAD TIP OF THE DAY ==========
  Future<void> _loadTipOfTheDay() async {
    setState(() => _isTipLoading = true);

    try {
      final tip = await _tipsService.getTipOfTheDay();
      setState(() {
        tipOfTheDay = tip;
      });
    } catch (e) {
      print('Error loading tip of the day: $e');
    } finally {
      setState(() => _isTipLoading = false);
    }
  }

  // ========== LOAD USER PROFILE ==========
  Future<void> _loadUserProfile() async {
    try {
      final profile = await _userService.getCurrentUserProfile();

      if (profile != null) {
        setState(() {
          userName = profile.username;
          profilePictureUrl = profile.profilePictureUrl;
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  // ========== LOAD DAILY TASKS ==========
  Future<void> _loadDailyTasks() async {
    try {
      final tasks = await _dailyTasksService.getTodayTasks();
      final stats = await _dailyTasksService.getTaskStats();

      setState(() {
        dailyTasks = tasks;
        completedTasks = stats['completed'] ?? 0;
        totalTasks = stats['total'] ?? 0;
      });
    } catch (e) {
      print('Error loading daily tasks: $e');
    }
  }

  // ========== LOAD WORKOUTS ==========
  Future<void> _loadWorkouts() async {
    try {
      final workoutList = await _workoutService.getAllWorkouts();

      setState(() {
        workouts = workoutList
            .take(5)
            .map(
              (w) => {
                'workout_id': w.workoutId,
                'title': w.workoutName,
                'subtitle': w.description ?? 'Full body workout',
                'duration': '${w.estimatedDuration ?? 30} min',
                'calories': '${w.estimatedCaloriesBurned ?? 120} cal',
                'color': const Color(0xFF1DAB87),
                'image_url': w.imageUrl,
              },
            )
            .toList();
      });
    } catch (e) {
      print('Error loading workouts: $e');
    }
  }

  // ========== AWARD DAILY LOGIN XP ==========
  Future<void> _awardDailyLoginXP() async {
    try {
      // TODO: Check if already awarded today using shared_preferences
      // For now, we'll skip to avoid duplicate XP
    } catch (e) {
      print('Error awarding login XP: $e');
    }
  }

  // ========== REFRESH DATA ==========
  Future<void> _refreshData() async {
    await _loadHomeData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.surfaceColor,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Header Skeleton
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonText(width: 80, height: 14),
                            SizedBox(height: 4),
                            SkeletonText(width: 150, height: 26),
                          ],
                        ),
                      ),
                      SkeletonCircle(size: 50),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Plan Card Skeleton
                  const SkeletonPlanCard(),

                  const SizedBox(height: 30),

                  // Tip of the Day Skeleton
                  const SkeletonCard(height: 120),

                  const SizedBox(height: 30),

                  // Section Header Skeleton
                  const SkeletonText(width: 180, height: 22),

                  const SizedBox(height: 16),

                  // Workouts Horizontal List Skeleton
                  SizedBox(
                    height: 280,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        return const SkeletonWorkoutCard();
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Daily Task Section Header Skeleton
                  const SkeletonText(width: 120, height: 22),

                  const SizedBox(height: 16),

                  // Daily Tasks Skeleton
                  ...List.generate(
                    4,
                    (index) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: SkeletonListTile(),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.surfaceColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: context.primaryText,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Header Section
                  _buildHeader(),

                  const SizedBox(height: 30),

                  // My Plan Card
                  _buildPlanCard(),

                  const SizedBox(height: 30),
                  // Tip of the Day Card
                  TipOfDayCard(
                    tip: tipOfTheDay,
                    isLoading: _isTipLoading,
                    onSeeAllTapped: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TipsLibraryScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),

                  // Start New Goal Section Header
                  _buildSectionHeader(
                    'Start New Goal',
                    'See all',
                    () => _onSeeAllWorkouts(),
                  ),

                  const SizedBox(height: 16),

                  // Workouts Horizontal List
                  _buildWorkoutsList(),

                  const SizedBox(height: 30),

                  // Daily Task Section Header
                  _buildSectionHeader('Daily Task', '', null),

                  const SizedBox(height: 16),

                  // Daily Tasks List
                  ...dailyTasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildTaskItem(context, task),
                    ),
                  ),

                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Greeting and Name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: TextStyle(
                  fontSize: 14,
                  color: context.secondaryText,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: context.primaryText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Profile Picture
        GestureDetector(
          onTap: () => _onProfileTap(),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1DAB87), width: 2),
            ),
            child: ClipOval(
              child: profilePictureUrl != null
                  ? Image.network(
                      profilePictureUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildProfileFallback();
                      },
                    )
                  : _buildProfileFallback(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileFallback() {
    return Image.asset(
      'assets/images/profile_male.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFF1DAB87),
          child: const Icon(Icons.person, color: Colors.white, size: 30),
        );
      },
    );
  }

  // ==================== MY PLAN CARD ====================
  Widget _buildPlanCard() {
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    final progressPercent = '${(progress * 100).toInt()}%';

    return GestureDetector(
      onTap: () => _onPlanCardTap(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1DAB87), Color(0xFF2DD4A3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: context.cardBackground.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Text Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Plan\nFor Today',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$completedTasks/$totalTasks Complete',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Progress Indicator
            _buildCircularProgress(progress, progressPercent),
          ],
        ),
      ),
    );
  }

  // ==================== CIRCULAR PROGRESS ====================
  Widget _buildCircularProgress(double progress, String text) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),
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
            text,
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
            fontSize: 22,
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
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF15223),
              ),
            ),
          ),
      ],
    );
  }

  // ==================== WORKOUTS LIST ====================
  Widget _buildWorkoutsList() {
    if (workouts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'No workouts available',
            style: TextStyle(color: Color(0xFF7E7E7E)),
          ),
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: workouts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return _buildWorkoutCard(workouts[index]);
        },
      ),
    );
  }

  // ==================== WORKOUT CARD ====================
  Widget _buildWorkoutCard(Map<String, dynamic> workout) {
    return GestureDetector(
      onTap: () => _onWorkoutTap(workout),
      child: Container(
        width: 285,
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                Container(
                  width: 285,
                  height: 128,
                  decoration: BoxDecoration(
                    color: (workout['color'] as Color).withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: workout['image_url'] != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
                          ),
                          child: Image.network(
                            workout['image_url'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.fitness_center,
                                  size: 50,
                                  color: workout['color'],
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.fitness_center,
                            size: 50,
                            color: workout['color'],
                          ),
                        ),
                ),

                // Play Button
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: workout['color'],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (workout['color'] as Color).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout['title'],
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: context.primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    workout['subtitle'],
                    style: TextStyle(
                      fontSize: 15,
                      color: context.secondaryText,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.access_time,
                        workout['duration'],
                        workout['color'],
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.local_fire_department,
                        workout['calories'],
                        const Color(0xFFFF844B),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== INFO CHIP ====================
  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: color,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TASK ITEM ====================
  Widget _buildTaskItem(BuildContext context, Map<String, dynamic> task) {
    final isCompleted = task['is_completed'] as bool? ?? false;
    final taskId = task['task_id'] as String;
    final title = task['task_title'] as String;
    final duration = task['duration'] as int?;
    final calories = task['calories'] as int?;

    // Theme-aware colors
    final cardBg = isCompleted
        ? context.primaryColor.withOpacity(0.1)
        : context.cardBackground;
    final borderColor = isCompleted
        ? context.primaryColor
        : context.borderColor;
    final titleColor = isCompleted
        ? context.secondaryText
        : context.primaryText;
    final checkboxBorderColor = isCompleted
        ? context.primaryColor
        : context.dividerColor;

    return GestureDetector(
      onTap: () => _onTaskTap(task),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isCompleted ? 2 : 1),
          boxShadow: [
            BoxShadow(
              color: context.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: () => _toggleTaskCompletion(taskId, isCompleted),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? context.primaryColor
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: checkboxBorderColor, width: 2),
                ),
                child: isCompleted
                    ? Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
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
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  if (duration != null || calories != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (duration != null) ...[
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: context.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$duration min',
                            style: TextStyle(
                              fontSize: 13,
                              color: context.primaryColor,
                            ),
                          ),
                          if (calories != null) const SizedBox(width: 12),
                        ],
                        if (calories != null) ...[
                          Icon(
                            Icons.local_fire_department,
                            size: 14,
                            color: context.accentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$calories cal',
                            style: TextStyle(
                              fontSize: 13,
                              color: context.accentColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // XP Badge
            if (!isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 12, color: context.accentColor),
                    const SizedBox(width: 2),
                    Text(
                      '+5',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.accentColor,
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

  // ==================== TOGGLE TASK COMPLETION ====================
  Future<void> _toggleTaskCompletion(String taskId, bool currentStatus) async {
    try {
      if (currentStatus) {
        // Uncomplete task
        await _dailyTasksService.uncompleteTask(taskId);
      } else {
        // Complete task
        final result = await _dailyTasksService.completeTask(taskId);

        // Show XP gain
        AnimatedMessage.show(
          context,
          message: '+${result['xp_added']} XP earned!',
          backgroundColor: const Color(0xFF1DAB87),
          icon: Icons.star,
          duration: const Duration(seconds: 2),
        );

        // Check for level up
        if (result['leveled_up'] == true) {
          _showLevelUpDialog(result['current_level']);
        }
      }

      // Refresh tasks
      await _loadDailyTasks();
    } catch (e) {
      print('Error toggling task: $e');
      AnimatedMessage.show(
        context,
        message: 'Failed to update task',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
    }
  }

  // ==================== SHOW LEVEL UP DIALOG (WITH LOTTIE ANIMATIONS) ====================
  void _showLevelUpDialog(int newLevel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        children: [
          // Dialog content
          Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: context.cardBackground,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Star/Trophy Lottie Animation
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Lottie.asset(
                      'assets/animations/Star.json',
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  const Text(
                    'LEVEL UP!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1DAB87),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Level info
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1DAB87), Color(0xFF2DD4A3)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'You are now Level $newLevel!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Motivational message
                  const Text(
                    'Keep crushing your goals!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF7E7E7E),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Action button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1DAB87),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Awesome!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confetti Lottie Animation (Full screen overlay)
          Positioned.fill(
            child: IgnorePointer(
              child: Lottie.asset(
                'assets/animations/Confetti.json',
                fit: BoxFit.cover,
                repeat: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TASK TAP HANDLER ====================
  void _onTaskTap(Map<String, dynamic> task) {
    print('Task tapped: ${task['task_title']}');
    // Handle task tap - could show task details or edit screen
  }

  // ==================== HELPER METHODS ====================

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Hello Good Morning! 👋';
    if (hour < 17) return 'Hello Good Afternoon! 👋';
    return 'Hello Good Evening! 👋';
  }

  // ==================== NAVIGATION METHODS ====================

  void _onProfileTap() {
    print('Profile tapped');
    // Navigate to profile screen (already handled by bottom nav)
  }

  void _onPlanCardTap() {
    print('Plan card tapped');
    // Could show detailed view of all tasks
  }

  void _onSeeAllWorkouts() {
    print('See all workouts tapped');
    // Navigate to workouts tab
    // You could use a TabController or Navigator
  }

  void _onWorkoutTap(Map<String, dynamic> workout) async {
    print('Workout tapped: ${workout['title']}');

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF1DAB87)),
      ),
    );

    try {
      // Fetch full workout details from database
      final workoutId = workout['workout_id'] as String;
      final fullWorkout = await _workoutService.getWorkoutWithExercises(
        workoutId,
      );

      Navigator.pop(context); // Close loading

      if (fullWorkout != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutDetailScreen(workout: fullWorkout),
          ),
        );
      } else {
        AnimatedMessage.show(
          context,
          message: 'Failed to load workout details',
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading
      print('Error loading workout: $e');
      AnimatedMessage.show(
        context,
        message: 'Failed to load workout details',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
    }
  }
}
