import 'package:flutter/material.dart';
import 'package:powerhouse/screens/workouts/workout_detail_screen.dart';
import 'package:powerhouse/services/user_service.dart';
import 'package:powerhouse/services/workout_service.dart';
import 'package:powerhouse/services/daily_tasks_service.dart';
import 'package:powerhouse/services/progress_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Services
  final _userService = UserService();
  final _workoutService = WorkoutService();
  final _dailyTasksService = DailyTasksService();
  final _progressService = ProgressService();

  // User data
  String userName = 'User';
  int userLevel = 1;
  int userXP = 0;
  double levelProgress = 0.0;
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
    } catch (e) {
      print('Error loading home data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ========== LOAD USER PROFILE ==========
  Future<void> _loadUserProfile() async {
    try {
      final profile = await _userService.getCurrentUserProfile();

      if (profile != null) {
        final progressStats = await _progressService.getUserProgressStats();

        setState(() {
          userName = profile.username;
          userLevel = profile.level;
          userXP = profile.xpPoints;
          profilePictureUrl = profile.profilePictureUrl;
          levelProgress = progressStats['level_progress'] ?? 0.0;
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
            .map((w) => {
                  'workout_id': w.workoutId,
                  'title': w.workoutName,
                  'subtitle': w.description ?? 'Full body workout',
                  'duration': '${w.estimatedDuration ?? 30} min',
                  'calories': '${w.estimatedCaloriesBurned ?? 120} cal',
                  'color': const Color(0xFF1DAB87),
                  'image_url': w.imageUrl,
                })
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
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: const Color(0xFF1DAB87),
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
                  ...dailyTasks.map((task) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildTaskItem(task),
                      )),

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
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7E7E7E),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Level indicator
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Color(0xFFF97316),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Level $userLevel',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1DAB87),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$userXP XP',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7E7E7E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
              border: Border.all(
                color: const Color(0xFF1DAB87),
                width: 2,
              ),
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
        child: const Icon(
          Icons.person,
          color: Colors.white,
          size: 30,
        ),
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
              color: const Color(0xFF1DAB87).withOpacity(0.3),
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
  Widget _buildSectionHeader(String title, String actionText, VoidCallback? onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
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
          color: Colors.white,
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
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    workout['subtitle'],
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF979797),
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
  Widget _buildTaskItem(Map<String, dynamic> task) {
    final isCompleted = task['is_completed'] as bool? ?? false;
    final taskId = task['task_id'] as String;
    final title = task['task_title'] as String;
    final duration = task['duration'] as int?;
    final calories = task['calories'] as int?;

    return GestureDetector(
      onTap: () => _onTaskTap(task),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCompleted
              ? const Color(0xFF1DAB87).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? const Color(0xFF1DAB87)
                : const Color(0xFFE0E0E0),
            width: isCompleted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
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
                      ? const Color(0xFF1DAB87)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFF1DAB87)
                        : const Color(0xFFD7D7D8),
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18,
                      )
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
                      color: isCompleted
                          ? const Color(0xFF7E7E7E)
                          : Colors.black,
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
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Color(0xFF1DAB87),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$duration min',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1DAB87),
                            ),
                          ),
                          if (calories != null) const SizedBox(width: 12),
                        ],
                        if (calories != null) ...[
                          const Icon(
                            Icons.local_fire_department,
                            size: 14,
                            color: Color(0xFFF97316),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$calories cal',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFF97316),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.star,
                      size: 12,
                      color: Color(0xFFF97316),
                    ),
                    SizedBox(width: 2),
                    Text(
                      '+5',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF97316),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.star, color: Colors.white),
                const SizedBox(width: 8),
                Text('+${result['xp_added']} XP earned!'),
              ],
            ),
            backgroundColor: const Color(0xFF1DAB87),
            duration: const Duration(seconds: 2),
          ),
        );

        // Check for level up
        if (result['leveled_up'] == true) {
          _showLevelUpDialog(result['current_level']);
        }
      }

      // Refresh tasks
      await _loadDailyTasks();
      await _loadUserProfile();
    } catch (e) {
      print('Error toggling task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update task'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==================== SHOW LEVEL UP DIALOG ====================
  void _showLevelUpDialog(int newLevel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF1DAB87).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star,
                  size: 60,
                  color: Color(0xFFF97316),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '🎉 LEVEL UP! 🎉',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1DAB87),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'You are now Level $newLevel!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DAB87),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'Awesome!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    final fullWorkout = await _workoutService.getWorkoutWithExercises(workoutId);

    Navigator.pop(context); // Close loading

    if (fullWorkout != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutDetailScreen(workout: fullWorkout),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load workout details'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } catch (e) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  void _onTaskTap(Map<String, dynamic> task) {
    // Task details or quick actions
    print('Task tapped: ${task['task_title']}');
  }
}