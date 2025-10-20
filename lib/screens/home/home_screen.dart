import 'package:flutter/material.dart';
import 'package:powerhouse/screens/workouts/workout_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // User data (replace with actual data later)
  final String userName = 'Kanishka Udayanga';
  final int completedTasks = 2;
  final int totalTasks = 10;
  
  // Calculate progress
  double get progress => completedTasks / totalTasks;
  String get progressPercent => '${(progress * 100).toInt()}%';

  // Sample workout data
  final List<WorkoutItem> workouts = [
    WorkoutItem(
      title: 'Body Building',
      subtitle: 'Full body workout',
      duration: '35 min',
      calories: '120 cal',
      color: const Color(0xFF1DAB87),
    ),
    WorkoutItem(
      title: 'Bar Exercises',
      subtitle: 'Strength training',
      duration: '30 min',
      calories: '150 cal',
      color: const Color(0xFFFF844B),
    ),
    WorkoutItem(
      title: 'Cardio Blast',
      subtitle: 'Heart workout',
      duration: '25 min',
      calories: '200 cal',
      color: const Color(0xFF6C63FF),
    ),
  ];

  // Sample exercise data
  final List<ExerciseItem> exercises = [
    ExerciseItem(
      title: 'Morning Stretch',
      duration: '5 min',
      calories: '40 cal',
      color: const Color(0xFF1DAB87),
    ),
    ExerciseItem(
      title: 'Core Workout',
      duration: '10 min',
      calories: '80 cal',
      color: const Color(0xFFFF844B),
    ),
    ExerciseItem(
      title: 'Evening Walk',
      duration: '15 min',
      calories: '100 cal',
      color: const Color(0xFF6C63FF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
                
                // Exercise List
                ...exercises.map((exercise) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildExerciseItem(exercise),
                )).toList(),
                
                const SizedBox(height: 100), // Space for bottom nav
              ],
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
    );
  }

  // ==================== MY PLAN CARD ====================
  Widget _buildPlanCard() {
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
          // Background Circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),
          
          // Progress Circle
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
          
          // Percentage Text
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
  Widget _buildWorkoutCard(WorkoutItem workout) {
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
            // Image Section with Play Button
            Stack(
              children: [
                Container(
                  width: 285,
                  height: 128,
                  decoration: BoxDecoration(
                    color: workout.color.withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/workout.png', // Path to your image
                      width: 285,
                      height: 128,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to icon if image fails to load
                        return Icon(
                          Icons.fitness_center,
                          size: 50,
                          color: workout.color,
                        );
                      },
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
                      color: workout.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: workout.color.withOpacity(0.3),
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
                    workout.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    workout.subtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF979797),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.access_time,
                        workout.duration,
                        workout.color,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.local_fire_department,
                        workout.calories,
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

  // ==================== EXERCISE ITEM ====================
  Widget _buildExerciseItem(ExerciseItem exercise) {
    return GestureDetector(
      onTap: () => _onExerciseTap(exercise),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            // Exercise Icon/Image
            Container(
              width: 60,
              height: 50,
              decoration: BoxDecoration(
                color: exercise.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                Icons.fitness_center,
                color: exercise.color,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Exercise Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: exercise.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        exercise.duration,
                        style: TextStyle(
                          fontSize: 15,
                          color: exercise.color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Color(0xFFF97316),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        exercise.calories,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFFF97316),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Play Button
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: exercise.color,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
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
    // Navigate to profile or show profile menu
    // Navigator.pushNamed(context, '/profile');
  }

  void _onPlanCardTap() {
    print('Plan card tapped');
    // Navigate to today's plan detail
    // Navigator.pushNamed(context, '/daily-plan');
  }

  void _onSeeAllWorkouts() {
    print('See all workouts tapped');
    // Navigate to all workouts screen
    // Navigator.pushNamed(context, '/all-workouts');
  }

  void _onWorkoutTap(WorkoutItem workout) {
  print('Workout tapped: ${workout.title}');
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => WorkoutDetailScreen(
        workout: WorkoutDetail.sample(), // Replace with actual data
      ),
    ),
  );
}

  void _onExerciseTap(ExerciseItem exercise) {
    print('Exercise tapped: ${exercise.title}');
    // Navigate to exercise detail or start exercise
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ExerciseDetailScreen(exercise: exercise),
    //   ),
    // );
  }
}

// ==================== DATA MODELS ====================

class WorkoutItem {
  final String title;
  final String subtitle;
  final String duration;
  final String calories;
  final Color color;

  WorkoutItem({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.calories,
    required this.color,
  });
}

class ExerciseItem {
  final String title;
  final String duration;
  final String calories;
  final Color color;

  ExerciseItem({
    required this.title,
    required this.duration,
    required this.calories,
    required this.color,
  });
}