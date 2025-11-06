import 'package:flutter/material.dart';
import 'package:powerhouse/screens/workouts/ready_workout_screen.dart';
import 'package:powerhouse/models/workout_model.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final WorkoutModel workout;

  const WorkoutDetailScreen({
    super.key,
    required this.workout,
  });

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final exercises = widget.workout.exercises ?? [];
    
    print('Building workout detail screen for: ${widget.workout.workoutName}');
    print('Number of exercises: ${exercises.length}');

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
                    if (exercises.isNotEmpty)
                      _buildExerciseList(exercises)
                    else
                      _buildNoExercisesMessage(),

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
              child: widget.workout.imageUrl != null
                  ? Image.network(
                      widget.workout.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImageFallback();
                      },
                    )
                  : _buildImageFallback(),
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
                widget.workout.workoutName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.workout.difficultyColor,
            widget.workout.difficultyColor.withOpacity(0.7),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Center(
        child: Icon(
          Icons.fitness_center,
          size: 120,
          color: Colors.white.withOpacity(0.5),
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
        widget.workout.description ?? 'No description available',
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
              value: '${widget.workout.estimatedDuration ?? 30}',
              label: 'Time (min)',
            ),
          ),
          _buildVerticalDivider(),
          Expanded(
            child: _buildStatCard(
              icon: Icons.local_fire_department,
              value: '${widget.workout.estimatedCaloriesBurned ?? 200}',
              label: 'Calories',
            ),
          ),
          _buildVerticalDivider(),
          Expanded(
            child: _buildStatCard(
              icon: Icons.trending_up,
              value: widget.workout.difficulty ?? 'All',
              label: '',
            ),
          ),
          _buildVerticalDivider(),
          Expanded(
            child: _buildStatCard(
              icon: Icons.fitness_center,
              value: '${widget.workout.exercises?.length ?? 0}',
              label: 'Exercises',
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
  Widget _buildExerciseList(List<ExerciseWithDetails> exercises) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              'Exercises',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
          ...exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exerciseDetails = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildExerciseItem(exerciseDetails, index),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(ExerciseWithDetails exerciseDetails, int index) {
    final exercise = exerciseDetails.exercise;

    return GestureDetector(
      onTap: () => _onExerciseTap(exerciseDetails),
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
                color: const Color(0xFF1DAB87).withOpacity(0.2),
              ),
              child: exercise.animationUrl != null &&
                      exercise.animationUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        exercise.animationUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.fitness_center,
                            color: Color(0xFF1DAB87),
                            size: 30,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.fitness_center,
                      color: Color(0xFF1DAB87),
                      size: 30,
                    ),
            ),

            const SizedBox(width: 14),

            // Exercise Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    exercise.exerciseName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (exerciseDetails.reps != null) ...[
                        const Icon(
                          Icons.repeat,
                          size: 16,
                          color: Color(0xFF7E7E7E),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${exerciseDetails.reps} reps',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7E7E7E),
                          ),
                        ),
                        if (exerciseDetails.sets != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            'x ${exerciseDetails.sets}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF7E7E7E),
                            ),
                          ),
                        ],
                      ],
                      if (exerciseDetails.duration != null) ...[
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Color(0xFF7E7E7E),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          exerciseDetails.durationFormatted,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7E7E7E),
                          ),
                        ),
                      ],
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

  // ==================== NO EXERCISES MESSAGE ====================
  Widget _buildNoExercisesMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(
              Icons.fitness_center,
              size: 60,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'No exercises available for this workout',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check back later or try another workout',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== START BUTTON ====================
  Widget _buildStartButton() {
    final exercises = widget.workout.exercises ?? [];

    return GestureDetector(
      onTap: exercises.isEmpty ? null : () => _onStartWorkout(),
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          gradient: exercises.isEmpty
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF1DAB87), Color(0xFF2DD4A3)],
                ),
          color: exercises.isEmpty ? Colors.grey : null,
          borderRadius: BorderRadius.circular(38),
          boxShadow: exercises.isEmpty
              ? null
              : [
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

  void _onExerciseTap(ExerciseWithDetails exerciseDetails) {
    print('Exercise tapped: ${exerciseDetails.exercise.exerciseName}');
    // Could show exercise detail/preview
  }

  void _onStartWorkout() {
    print('Start workout tapped');

    if (widget.workout.exercises == null ||
        widget.workout.exercises!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No exercises available for this workout'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadyWorkoutScreen(
          workout: widget.workout,
          countdownSeconds: 10,
        ),
      ),
    );
  }
}