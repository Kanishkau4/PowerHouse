import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:powerhouse/screens/workouts/workout_completion_screen.dart';
import 'package:powerhouse/screens/workouts/rest_screen.dart';
import 'package:powerhouse/models/workout_model.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final WorkoutModel workout;

  const WorkoutSessionScreen({
    super.key,
    required this.workout,
  });

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen>
    with SingleTickerProviderStateMixin {
  int _currentExerciseIndex = 0;
  int _currentReps = 0;
  int _targetReps = 12;
  bool _isPaused = false;
  bool _isVoiceEnabled = true;

  // Timer for timed exercises
  Timer? _exerciseTimer;
  int _secondsRemaining = 0;

  // Check if current exercise is duration-based or reps-based
  bool get _isDurationBased => exercises[_currentExerciseIndex].duration != null && 
                                exercises[_currentExerciseIndex].duration! > 0;

  // Text-to-Speech
  final FlutterTts _tts = FlutterTts();

  late AnimationController _repAnimationController;
  late Animation<double> _repScaleAnimation;

  // Get exercises list
  List<ExerciseWithDetails> get exercises => widget.workout.exercises ?? [];

  @override
  void initState() {
    super.initState();

    if (exercises.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No exercises available'),
            backgroundColor: Colors.red,
          ),
        );
      });
      return;
    }

    _initializeExercise();
    _configureTts();

    // Animation for rep counter
    _repAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _repScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _repAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Announce exercise start
    _announceExerciseStart();
  }

  // Configure Text-to-Speech
  Future<void> _configureTts() async {
    try {
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (e) {
      print('TTS configuration error: $e');
    }
  }

  // Announce exercise start
  Future<void> _announceExerciseStart() async {
    final exercise = exercises[_currentExerciseIndex].exercise;
    await Future.delayed(const Duration(milliseconds: 500));
    if (_isVoiceEnabled) {
      if (_isDurationBased) {
        await _tts.speak("${exercise.exerciseName}. ${_secondsRemaining} seconds. Let's go!");
      } else {
        await _tts.speak("${exercise.exerciseName}. $_targetReps reps. Let's go!");
      }
    }
  }

  void _initializeExercise() {
    final currentExercise = exercises[_currentExerciseIndex];

    // Set target reps (for reps-based exercises)
    _targetReps = currentExercise.reps ?? 12;
    _currentReps = 0;

    // Set duration (for duration-based exercises)
    _secondsRemaining = currentExercise.duration ?? 0;

    // Start timer ONLY if duration-based
    if (_isDurationBased) {
      _startExerciseTimer();
    }
  }

  void _startExerciseTimer() {
    _exerciseTimer?.cancel();
    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && _secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });

        // Voice countdown for last 5 seconds
        if (_isVoiceEnabled &&
            _secondsRemaining <= 5 &&
            _secondsRemaining > 0) {
          _tts.speak(_secondsRemaining.toString());
        }
      } else if (_secondsRemaining == 0) {
        _exerciseTimer?.cancel();
        if (_isVoiceEnabled) {
          _tts.speak("Exercise complete!");
        }
        // Auto-proceed to next exercise
        Future.delayed(const Duration(milliseconds: 1000), () {
          _nextExercise();
        });
      }
    });
  }

  // Enhanced rep increment with voice
  void _incrementReps() {
    if (_isDurationBased) return; // Don't increment reps for duration-based exercises

    if (_currentReps < _targetReps) {
      setState(() {
        _currentReps++;
      });
      _repAnimationController.forward(from: 0);

      // Speak rep number
      if (_isVoiceEnabled) {
        _tts.speak(_currentReps.toString());
      }

      // Motivational messages
      if (_isVoiceEnabled) {
        if (_currentReps == _targetReps ~/ 2) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _tts.speak("Halfway there! Keep going!");
          });
        } else if (_currentReps == _targetReps - 3 && _targetReps > 3) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _tts.speak("Almost done! Three more!");
          });
        }
      }

      if (_currentReps >= _targetReps) {
        if (_isVoiceEnabled) {
          _tts.speak("Exercise complete! Great job!");
        }
        Future.delayed(const Duration(milliseconds: 1500), () {
          _nextExercise();
        });
      }
    }
  }

  void _decrementReps() {
    if (_isDurationBased) return; // Don't decrement reps for duration-based exercises

    if (_currentReps > 0) {
      setState(() {
        _currentReps--;
      });
      if (_isVoiceEnabled) {
        _tts.speak(_currentReps.toString());
      }
    }
  }

  // Add 20 seconds to timer (for duration-based exercises)
  void _addTime() {
    if (!_isDurationBased) return;

    setState(() {
      _secondsRemaining += 20;
    });
    if (_isVoiceEnabled) {
      _tts.speak("Added 20 seconds");
    }
  }

  // Next exercise with rest screen
  void _nextExercise() {
    _exerciseTimer?.cancel();
    _tts.stop();

    if (_currentExerciseIndex < exercises.length - 1) {
      // Show rest screen before next exercise
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RestScreen(
            nextExercise: exercises[_currentExerciseIndex + 1],
            restSeconds: 30,
            onRestComplete: () {
              setState(() {
                _currentExerciseIndex++;
                _currentReps = 0;
              });
              _initializeExercise();
              _announceExerciseStart();
            },
          ),
        ),
      );
    } else {
      _showWorkoutCompleteDialog();
    }
  }

  void _previousExercise() {
    if (_currentExerciseIndex > 0) {
      _exerciseTimer?.cancel();
      _tts.stop();
      setState(() {
        _currentExerciseIndex--;
        _currentReps = 0;
      });
      _initializeExercise();
      _announceExerciseStart();
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    if (_isVoiceEnabled) {
      _tts.speak(_isPaused ? "Paused" : "Resumed");
    }
  }

  void _toggleVoice() {
    setState(() {
      _isVoiceEnabled = !_isVoiceEnabled;
    });
    if (_isVoiceEnabled) {
      _tts.speak("Voice enabled");
    } else {
      _tts.stop();
    }
  }

  double get _progress {
    return (_currentExerciseIndex + 1) / exercises.length;
  }

  double get _repProgress {
    if (_isDurationBased) {
      // For duration-based: show progress based on time elapsed
      final totalDuration = exercises[_currentExerciseIndex].duration ?? 1;
      final elapsed = totalDuration - _secondsRemaining;
      return (elapsed / totalDuration).clamp(0.0, 1.0);
    } else {
      // For reps-based: show progress based on reps completed
      return _currentReps / _targetReps;
    }
  }

  String get _progressText {
    return '${_currentExerciseIndex + 1}/${exercises.length} Done';
  }

  String get _timeText {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _exerciseTimer?.cancel();
    _repAnimationController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1DAB87)),
        ),
      );
    }

    final currentExercise = exercises[_currentExerciseIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final cardHeight = screenHeight * 0.4;

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Progress Bar Section
                  _buildProgressBar(),

                  // Exercise Illustration Card
                  _buildExerciseCard(currentExercise, cardHeight),

                  const SizedBox(height: 24),

                  // Exercise Name
                  _buildExerciseName(currentExercise),

                  const SizedBox(height: 24),

                  // CONDITIONAL: Show either Timer Circle OR Rep Counter
                  if (_isDurationBased)
                    _buildTimerCircle()
                  else
                    _buildRepCounter(),

                  const SizedBox(height: 32),

                  // Control Buttons (conditional based on exercise type)
                  _buildControlButtons(),

                  const SizedBox(height: 24),

                  // Navigation Buttons
                  _buildNavigationButtons(),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ==================== PROGRESS BAR ====================
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text(
            _progressText,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF1DAB87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== EXERCISE CARD ====================
  Widget _buildExerciseCard(ExerciseWithDetails exerciseDetails, double cardHeight) {
    final exercise = exerciseDetails.exercise;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.infinity,
        height: 400,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5F2),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Back Button
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, size: 24),
                  onPressed: () {
                    _exerciseTimer?.cancel();
                    _tts.stop();
                    _showExitConfirmation();
                  },
                ),
              ),
            ),

            // Pause/Play Button
            Positioned(
              top: 20,
              right: 70,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isPaused ? Icons.play_arrow : Icons.pause,
                    size: 24,
                  ),
                  onPressed: _togglePause,
                ),
              ),
            ),

            // Voice Toggle Button
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: _isVoiceEnabled
                      ? const Color(0xFF1DAB87).withOpacity(0.7)
                      : Colors.white.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isVoiceEnabled ? Icons.volume_up : Icons.volume_off,
                    size: 24,
                    color: _isVoiceEnabled ? Colors.white : Colors.grey,
                  ),
                  onPressed: _toggleVoice,
                ),
              ),
            ),

            // Exercise Illustration or Image
            Center(
              child: exercise.animationUrl != null &&
                      exercise.animationUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        exercise.animationUrl!,
                        width: 200,
                        height: 280,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return CustomPaint(
                            size: const Size(150, 280),
                            painter: ExercisePersonPainter(),
                          );
                        },
                      ),
                    )
                  : CustomPaint(
                      size: const Size(150, 280),
                      painter: ExercisePersonPainter(),
                    ),
            ),

            // Exercise Info Badge at bottom
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isDurationBased) ...[
                      const Icon(Icons.timer, color: Color(0xFF1DAB87), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        exerciseDetails.durationFormatted,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1DAB87),
                        ),
                      ),
                    ] else ...[
                      const Icon(Icons.repeat, color: Color(0xFF1DAB87), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${exerciseDetails.reps} reps',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1DAB87),
                        ),
                      ),
                      if (exerciseDetails.sets != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          'x ${exerciseDetails.sets}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF7E7E7E),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== EXERCISE NAME ====================
  Widget _buildExerciseName(ExerciseWithDetails exerciseDetails) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        exerciseDetails.exercise.exerciseName,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ==================== TIMER CIRCLE (for duration-based exercises) ====================
  Widget _buildTimerCircle() {
    return GestureDetector(
      onTap: () {
        // Optional: tap to pause
        _togglePause();
      },
      child: CustomPaint(
        size: const Size(200, 200),
        painter: RepCounterPainter(progress: _repProgress),
        child: SizedBox(
          width: 200,
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _timeText,
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1DAB87),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'remaining',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== REP COUNTER (for reps-based exercises) ====================
  Widget _buildRepCounter() {
    return GestureDetector(
      onTap: _incrementReps,
      child: AnimatedBuilder(
        animation: _repScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _repScaleAnimation.value,
            child: CustomPaint(
              size: const Size(200, 200),
              painter: RepCounterPainter(progress: _repProgress),
              child: SizedBox(
                width: 200,
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentReps.toString(),
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1DAB87),
                        ),
                      ),
                      Text(
                        '/ $_targetReps',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==================== CONTROL BUTTONS ====================
  Widget _buildControlButtons() {
    if (_isDurationBased) {
      // For duration-based: Show "Add Time" button
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _addTime,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add 20s'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB2E5D8),
                foregroundColor: const Color(0xFF1DAB87),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap to pause/resume',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    } else {
      // For reps-based: Show increment/decrement buttons
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Decrease Reps
            IconButton(
              onPressed: _decrementReps,
              icon: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFB2E5D8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.remove,
                  color: Color(0xFF1DAB87),
                ),
              ),
            ),

            const SizedBox(width: 20),

            // Tap to Count Text
            Text(
              'Tap circle to count',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(width: 20),

            // Increase Reps
            IconButton(
              onPressed: _incrementReps,
              icon: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF1DAB87),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  // ==================== NAVIGATION BUTTONS ====================
  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          // Previous Button
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed:
                    _currentExerciseIndex > 0 ? _previousExercise : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB2E5D8),
                  foregroundColor: const Color(0xFF1DAB87),
                  disabledBackgroundColor: Colors.grey.shade200,
                  disabledForegroundColor: Colors.grey.shade400,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.arrow_back, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Previous',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Next Button
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _nextExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DAB87),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== DIALOGS ====================

  void _showWorkoutCompleteDialog() {
    if (_isVoiceEnabled) {
      _tts.speak("Workout complete! Congratulations!");
    }

    // Calculate workout duration
    final workoutDuration = Duration(
      minutes: widget.workout.estimatedDuration ?? 30,
    );

    // Navigate to completion screen
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutCompletionScreen(
            workout: widget.workout,
            workoutsCompleted: exercises.length,
            caloriesBurned: widget.workout.estimatedCaloriesBurned ?? 320,
            workoutDuration: workoutDuration,
          ),
        ),
      );
    });
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Exit Workout?'),
        content: const Text(
            'Are you sure you want to exit? Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _tts.stop();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit workout
            },
            child: const Text(
              'Exit',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== REP COUNTER PAINTER ====================
class RepCounterPainter extends CustomPainter {
  final double progress;

  RepCounterPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 12.0;

    // Background circle
    final backgroundPaint = Paint()
      ..color = const Color(0xFFB2E5D8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = const Color(0xFF1DAB87)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect =
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      progress * 2 * math.pi,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(RepCounterPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ==================== EXERCISE PERSON PAINTER ====================
class ExercisePersonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Head
    paint.color = const Color(0xFFE8C5A5);
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.15),
      20,
      paint,
    );

    // Neck
    paint.color = const Color(0xFFE8C5A5);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.2),
        width: 10,
        height: 15,
      ),
      paint,
    );

    // Shirt (maroon)
    paint.color = const Color(0xFF8B2E2E);
    final shirtPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.25)
      ..lineTo(size.width * 0.7, size.height * 0.25)
      ..lineTo(size.width * 0.65, size.height * 0.45)
      ..lineTo(size.width * 0.35, size.height * 0.45)
      ..close();
    canvas.drawPath(shirtPath, paint);

    // Arms
    paint.color = const Color(0xFFE8C5A5);
    // Left arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.2, size.height * 0.25, 15, 80),
        const Radius.circular(7),
      ),
      paint,
    );
    // Right arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.8 - 15, size.height * 0.25, 15, 80),
        const Radius.circular(7),
      ),
      paint,
    );

    // Shorts (gray)
    paint.color = const Color(0xFF7A8B9A);
    final shortsPath = Path()
      ..moveTo(size.width * 0.35, size.height * 0.45)
      ..lineTo(size.width * 0.65, size.height * 0.45)
      ..lineTo(size.width * 0.6, size.height * 0.65)
      ..lineTo(size.width * 0.4, size.height * 0.65)
      ..close();
    canvas.drawPath(shortsPath, paint);

    // Legs
    paint.color = const Color(0xFFE8C5A5);
    // Left leg
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.38, size.height * 0.63, 18, 110),
        const Radius.circular(9),
      ),
      paint,
    );
    // Right leg
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.56, size.height * 0.63, 18, 110),
        const Radius.circular(9),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}