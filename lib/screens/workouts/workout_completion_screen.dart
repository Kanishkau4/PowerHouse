import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';
import 'package:powerhouse/models/workout_model.dart';
import 'package:powerhouse/services/workout_service.dart';

class WorkoutCompletionScreen extends StatefulWidget {
  final WorkoutModel workout;
  final int workoutsCompleted;
  final int caloriesBurned;
  final Duration workoutDuration;

  const WorkoutCompletionScreen({
    super.key,
    required this.workout,
    this.workoutsCompleted = 1,
    this.caloriesBurned = 320,
    required this.workoutDuration,
  });

  @override
  State<WorkoutCompletionScreen> createState() =>
      _WorkoutCompletionScreenState();
}

class _WorkoutCompletionScreenState extends State<WorkoutCompletionScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _scaleController;
  late AnimationController _xpController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _xpAnimation;

  final _workoutService = WorkoutService();

  int earnedXP = 0;
  int maxXP = 100; // XP needed for next level
  bool _isSaving = false;
  bool _dataSaved = false;

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _xpController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _xpAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _xpController, curve: Curves.easeOut));

    // Save workout and award XP
    _saveWorkoutCompletion();

    // Start animations
    Timer(const Duration(milliseconds: 300), () {
      _confettiController.play();
      _scaleController.forward();
    });
  }

  // ========== SAVE WORKOUT TO DATABASE ==========
  Future<void> _saveWorkoutCompletion() async {
    if (_dataSaved) return;

    setState(() {
      _isSaving = true;
    });

    try {
      print('💾 Saving workout completion...');

      final result = await _workoutService.logWorkoutCompletion(
        workoutId: widget.workout.workoutId,
        duration: widget.workoutDuration.inMinutes,
        caloriesBurned: widget.caloriesBurned,
      );

      setState(() {
        earnedXP = result['xp_added'] ?? 0;
        maxXP = 100; // Fixed for now
        _dataSaved = true;
      });

      // Update XP animation
      _xpAnimation = Tween<double>(
        begin: 0.0,
        end: (earnedXP / maxXP).clamp(0.0, 1.0),
      ).animate(CurvedAnimation(parent: _xpController, curve: Curves.easeOut));

      _xpController.forward();

      print('✅ Workout saved! Earned $earnedXP XP');

      // Check for level up
      if (result['leveled_up'] == true) {
        Future.delayed(const Duration(seconds: 2), () {
          _showLevelUpDialog(result['current_level']);
        });
      }
    } catch (e) {
      print('❌ Error saving workout: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save workout: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showLevelUpDialog(int newLevel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
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

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _xpController.dispose();
    super.dispose();
  }

  String get _durationText {
    final minutes = widget.workoutDuration.inMinutes;
    final seconds = widget.workoutDuration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Scrollable main content
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 36),

                          // Trophy Animation
                          _buildTrophySection(),

                          const SizedBox(height: 40),

                          // Title
                          const Text(
                            'Awesome!',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1DAB87),
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'You are almost finish it',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF7E7E7E),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // XP Progress Bar
                          _buildXPBar(),

                          const SizedBox(height: 40),

                          // Statistics
                          _buildStatistics(),

                          const SizedBox(height: 48),

                          // Action Buttons
                          _buildActionButtons(),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),

                // Confetti (top-aligned, doesn't affect layout)
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirection: 3.14 / 2, // Down
                    emissionFrequency: 0.05,
                    numberOfParticles: 20,
                    gravity: 0.3,
                    colors: const [
                      Color(0xFF1DAB87),
                      Color(0xFFFF844B),
                      Color(0xFF6C63FF),
                      Colors.yellow,
                      Colors.pink,
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ==================== TROPHY SECTION ====================
  Widget _buildTrophySection() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9E6),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(
          Icons.emoji_events,
          size: 100,
          color: Color(0xFFFFD700),
        ),
      ),
    );
  }

  // ==================== XP BAR ====================
  Widget _buildXPBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 74.0),
      child: Column(
        children: [
          // Progress Bar
          Stack(
            children: [
              // Background
              Container(
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0x9ED9D9D9),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              // Progress
              AnimatedBuilder(
                animation: _xpAnimation,
                builder: (context, child) {
                  return FractionallySizedBox(
                    widthFactor: _xpAnimation.value,
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1DAB87), Color(0xFF2DD4A3)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          '+$earnedXP XP',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          // XP Text
          Text(
            '$earnedXP / $maxXP XP',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF7E7E7E),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== STATISTICS ====================
  Widget _buildStatistics() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatCard(
            value: widget.workoutsCompleted.toString(),
            label: 'Workouts',
          ),
          _buildDivider(),
          _buildStatCard(value: widget.caloriesBurned.toString(), label: 'cal'),
          _buildDivider(),
          _buildStatCard(value: _durationText, label: 'minutes'),
        ],
      ),
    );
  }

  Widget _buildStatCard({required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 61, color: const Color(0xFF7E7E7E));
  }

  // ==================== ACTION BUTTONS ====================
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        children: [
          // Start Next Workout Button
          SizedBox(
            width: double.infinity,
            height: 62,
            child: ElevatedButton(
              onPressed: _onStartNextWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1DAB87),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(38),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Start Next Workout',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Back to Home Button
          SizedBox(
            width: double.infinity,
            height: 62,
            child: ElevatedButton(
              onPressed: _onBackToHome,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF844B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(38),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.home),
                  SizedBox(width: 8),
                  Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HANDLERS ====================

  void _onStartNextWorkout() {
    // Navigate to next workout or workout selection
    Navigator.popUntil(context, (route) => route.isFirst);
    // Then navigate to workouts screen
    // Navigator.pushNamed(context, '/workouts');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Starting next workout...'),
        backgroundColor: Color(0xFF1DAB87),
      ),
    );
  }

  void _onBackToHome() {
    // Navigate back to home screen
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
