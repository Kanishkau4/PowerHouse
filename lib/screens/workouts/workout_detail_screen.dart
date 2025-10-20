import 'package:flutter/material.dart';
import 'package:powerhouse/screens/workouts/ready_workout_screen.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final WorkoutDetail workout;

  const WorkoutDetailScreen({
    Key? key,
    required this.workout,
  }) : super(key: key);

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            slivers: [
              // Hero Image with Title
              _buildHeroImage(),
              
              // Content Section
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Description
                    _buildDescription(),
                    
                    const SizedBox(height: 24),
                    
                    // Stats Cards
                    _buildStatsCards(),
                    
                    const SizedBox(height: 32),
                    
                    // Exercise List
                    _buildExerciseList(),
                    
                    const SizedBox(height: 100), // Space for button
                  ],
                ),
              ),
            ],
          ),
          
          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: _buildBackButton(),
          ),
          
          // Floating Start Button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildStartButton(),
          ),
        ],
      ),
    );
  }

  // ==================== HERO IMAGE ====================
  Widget _buildHeroImage() {
    return SliverAppBar(
      expandedHeight: 360,
      pinned: false,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              child: Image.network(
                widget.workout.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1DAB87),
                          const Color(0xFF1DAB87).withOpacity(0.7),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
            ),
            
            // Title
            Positioned(
              bottom: 60,
              left: 24,
              right: 24,
              child: Text(
                widget.workout.title,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== BACK BUTTON ====================
  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  // ==================== DESCRIPTION ====================
  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        widget.workout.description,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFF7E7E7E),
          height: 1.5,
        ),
      ),
    );
  }

  // ==================== STATS CARDS ====================
  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.access_time,
              value: widget.workout.duration,
              label: 'Time',
            ),
          ),
          _buildVerticalDivider(),
          Expanded(
            child: _buildStatCard(
              icon: Icons.local_fire_department,
              value: widget.workout.calories,
              label: 'Calorie',
            ),
          ),
          _buildVerticalDivider(),
          Expanded(
            child: _buildStatCard(
              icon: Icons.trending_up,
              value: widget.workout.difficulty,
              label: '',
            ),
          ),
          _buildVerticalDivider(),
          Expanded(
            child: _buildStatCard(
              icon: Icons.fitness_center,
              value: widget.workout.equipment,
              label: 'Equipment',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF1DAB87),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 44,
      color: const Color(0xFF979797),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  // ==================== EXERCISE LIST ====================
  Widget _buildExerciseList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: widget.workout.exercises.asMap().entries.map((entry) {
          final index = entry.key;
          final exercise = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildExerciseItem(exercise, index),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExerciseItem(Exercise exercise, int index) {
    return GestureDetector(
      onTap: () => _onExerciseTap(exercise),
      child: Container(
        height: 90,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0x7CD9D9D9),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            // Exercise Image
            Container(
              width: 79,
              height: 69,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(exercise.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: exercise.imageUrl.isEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1DAB87).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: Color(0xFF1DAB87),
                        size: 30,
                      ),
                    )
                  : null,
            ),
            
            const SizedBox(width: 14),
            
            // Exercise Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Color(0xFF7E7E7E),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        exercise.duration,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF7E7E7E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Play Button
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1DAB87).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Color(0xFF1DAB87),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== START BUTTON ====================
  Widget _buildStartButton() {
    return GestureDetector(
      onTap: () => _onStartWorkout(),
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1DAB87), Color(0xFF2DD4A3)],
          ),
          borderRadius: BorderRadius.circular(38),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1DAB87).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Start Workout',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== HANDLERS ====================
  
  void _onExerciseTap(Exercise exercise) {
    print('Exercise tapped: ${exercise.name}');
    // Navigate to exercise detail or preview
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ExercisePreviewScreen(exercise: exercise),
    //   ),
    // );
  }

  void _onStartWorkout() {
  print('Start workout tapped');
  
  // Navigate to ready screen with countdown
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ReadyWorkoutScreen(
        workout: widget.workout,
        countdownSeconds: 10, // 10 seconds countdown
      ),
    ),
  );
}

  void _showStartWorkoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Ready to Start?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You\'re about to start:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            _buildDialogInfo(Icons.fitness_center, widget.workout.title),
            const SizedBox(height: 8),
            _buildDialogInfo(Icons.access_time, '${widget.workout.exercises.length} exercises'),
            const SizedBox(height: 8),
            _buildDialogInfo(Icons.timer, widget.workout.duration),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to workout session
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Starting workout...'),
                  backgroundColor: Color(0xFF1DAB87),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1DAB87),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Let\'s Go!'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF1DAB87),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== DATA MODELS ====================

class WorkoutDetail {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String duration;
  final String calories;
  final String difficulty;
  final String equipment;
  final List<Exercise> exercises;

  WorkoutDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.duration,
    required this.calories,
    required this.difficulty,
    required this.equipment,
    required this.exercises,
  });

  // Sample data factory
  factory WorkoutDetail.sample() {
    return WorkoutDetail(
      id: '1',
      title: '30-Day Weight Loss\nChallenge',
      description:
          'Designed for all fitness levels, this program helps you burn fat, boost energy, and build a healthy routine - no gym or equipment needed.',
      imageUrl: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=800',
      duration: '30 min',
      calories: '250-350',
      difficulty: 'Beginner',
      equipment: 'No',
      exercises: [
        Exercise(
          id: '1',
          name: 'Warm-up',
          duration: '02:00',
          imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        ),
        Exercise(
          id: '2',
          name: 'Jumping Jacks',
          duration: '00:30',
          imageUrl: 'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=400',
        ),
        Exercise(
          id: '3',
          name: 'Bodyweight Squats',
          duration: '02:00',
          imageUrl: 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=400',
        ),
        Exercise(
          id: '4',
          name: 'Push-ups',
          duration: '01:00',
          imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        ),
        Exercise(
          id: '5',
          name: 'Plank Hold',
          duration: '00:45',
          imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        ),
      ],
    );
  }
}

class Exercise {
  final String id;
  final String name;
  final String duration;
  final String imageUrl;

  Exercise({
    required this.id,
    required this.name,
    required this.duration,
    required this.imageUrl,
  });
}