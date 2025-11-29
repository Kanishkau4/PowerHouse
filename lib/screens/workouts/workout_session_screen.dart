import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:powerhouse/screens/workouts/workout_completion_screen.dart';
import 'package:powerhouse/screens/workouts/rest_screen.dart';
import 'package:powerhouse/models/workout_model.dart';
import 'package:powerhouse/widgets/animated_message.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart'; // ✅ ADD THIS

class WorkoutSessionScreen extends StatefulWidget {
  final WorkoutModel workout;

  const WorkoutSessionScreen({super.key, required this.workout});

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
  bool get _isDurationBased =>
      exercises[_currentExerciseIndex].duration != null &&
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
        AnimatedMessage.show(
          context,
          message: 'No exercises available',
          backgroundColor: Colors.red,
          icon: Icons.error,
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
        await _tts.speak(
          "${exercise.exerciseName}. $_secondsRemaining seconds. Let's go!",
        );
      } else {
        await _tts.speak(
          "${exercise.exerciseName}. $_targetReps reps. Let's go!",
        );
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
    if (_isDurationBased) return;

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
    if (_isDurationBased) return;

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
      final totalDuration = exercises[_currentExerciseIndex].duration ?? 1;
      final elapsed = totalDuration - _secondsRemaining;
      return (elapsed / totalDuration).clamp(0.0, 1.0);
    } else {
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
      return Scaffold(
        backgroundColor: context.surfaceColor, // ✅ DARK MODE
        body: Center(
          child: CircularProgressIndicator(
            color: context.primaryColor,
          ), // ✅ DARK MODE
        ),
      );
    }

    final currentExercise = exercises[_currentExerciseIndex];

    return Scaffold(
      backgroundColor: context.surfaceColor, // ✅ DARK MODE
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final cardHeight = screenHeight * 0.4;

            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildProgressBar(),
                  _buildExerciseCard(currentExercise, cardHeight),
                  const SizedBox(height: 24),
                  _buildExerciseName(currentExercise),
                  const SizedBox(height: 24),
                  if (_isDurationBased)
                    _buildTimerCircle()
                  else
                    _buildRepCounter(),
                  const SizedBox(height: 32),
                  _buildControlButtons(),
                  const SizedBox(height: 24),
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
            style: TextStyle(
              fontSize: 16,
              color: context.secondaryText, // ✅ DARK MODE
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
              backgroundColor: context.dividerColor, // ✅ DARK MODE
              valueColor: AlwaysStoppedAnimation<Color>(
                context.primaryColor, // ✅ DARK MODE
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== EXERCISE CARD ====================
  Widget _buildExerciseCard(
    ExerciseWithDetails exerciseDetails,
    double cardHeight,
  ) {
    final exercise = exerciseDetails.exercise;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Card background colors based on theme
    final cardBgColor = isDark
        ? const Color(0xFF1E3A32) // Dark green tint for dark mode
        : const Color(0xFFE8F5F2); // Light green for light mode

    final overlayColor = isDark
        ? Colors.black.withOpacity(0.3)
        : Colors.white.withOpacity(0.7);

    final badgeBgColor = isDark
        ? context.cardBackground.withOpacity(0.95)
        : Colors.white.withOpacity(0.9);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.infinity,
        height: 400,
        decoration: BoxDecoration(
          color: cardBgColor, // ✅ DARK MODE
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: context.shadowColor, // ✅ DARK MODE
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
                  color: overlayColor, // ✅ DARK MODE
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: 24,
                    color: context.primaryText, // ✅ DARK MODE
                  ),
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
                  color: overlayColor, // ✅ DARK MODE
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isPaused ? Icons.play_arrow : Icons.pause,
                    size: 24,
                    color: context.primaryText, // ✅ DARK MODE
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
                      ? context.primaryColor.withOpacity(0.7)
                      : overlayColor, // ✅ DARK MODE
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isVoiceEnabled ? Icons.volume_up : Icons.volume_off,
                    size: 24,
                    color: _isVoiceEnabled
                        ? Colors.white
                        : context.secondaryText, // ✅ DARK MODE
                  ),
                  onPressed: _toggleVoice,
                ),
              ),
            ),

            // Exercise Illustration or Image
            Center(
              child:
                  exercise.animationUrl != null &&
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
                            painter: ExercisePersonPainter(isDark: isDark),
                          );
                        },
                      ),
                    )
                  : CustomPaint(
                      size: const Size(150, 280),
                      painter: ExercisePersonPainter(isDark: isDark),
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
                  color: badgeBgColor, // ✅ DARK MODE
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isDurationBased) ...[
                      Icon(
                        Icons.timer,
                        color: context.primaryColor, // ✅ DARK MODE
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        exerciseDetails.durationFormatted,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: context.primaryColor, // ✅ DARK MODE
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.repeat,
                        color: context.primaryColor, // ✅ DARK MODE
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${exerciseDetails.reps} reps',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: context.primaryColor, // ✅ DARK MODE
                        ),
                      ),
                      if (exerciseDetails.sets != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          'x ${exerciseDetails.sets}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: context.secondaryText, // ✅ DARK MODE
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
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: context.primaryText, // ✅ DARK MODE
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ==================== TIMER CIRCLE ====================
  Widget _buildTimerCircle() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        _togglePause();
      },
      child: CustomPaint(
        size: const Size(200, 200),
        painter: RepCounterPainter(
          progress: _repProgress,
          isDark: isDark,
          primaryColor: context.primaryColor,
        ),
        child: SizedBox(
          width: 200,
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _timeText,
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    color: context.primaryColor, // ✅ DARK MODE
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'remaining',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.secondaryText, // ✅ DARK MODE
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== REP COUNTER ====================
  Widget _buildRepCounter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: _incrementReps,
      child: AnimatedBuilder(
        animation: _repScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _repScaleAnimation.value,
            child: CustomPaint(
              size: const Size(200, 200),
              painter: RepCounterPainter(
                progress: _repProgress,
                isDark: isDark,
                primaryColor: this.context.primaryColor,
              ),
              child: SizedBox(
                width: 200,
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentReps.toString(),
                        style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w800,
                          color: this.context.primaryColor, // ✅ DARK MODE
                        ),
                      ),
                      Text(
                        '/ $_targetReps',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: this.context.secondaryText, // ✅ DARK MODE
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Secondary button colors
    final secondaryBgColor = isDark
        ? context.primaryColor.withOpacity(0.2)
        : const Color(0xFFB2E5D8);

    if (_isDurationBased) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _addTime,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add 20s'),
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryBgColor, // ✅ DARK MODE
                foregroundColor: context.primaryColor, // ✅ DARK MODE
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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
                color: context.secondaryText, // ✅ DARK MODE
              ),
            ),
          ],
        ),
      );
    } else {
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
                decoration: BoxDecoration(
                  color: secondaryBgColor, // ✅ DARK MODE
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.remove,
                  color: context.primaryColor, // ✅ DARK MODE
                ),
              ),
            ),

            const SizedBox(width: 20),

            Text(
              'Tap circle to count',
              style: TextStyle(
                fontSize: 14,
                color: context.secondaryText, // ✅ DARK MODE
              ),
            ),

            const SizedBox(width: 20),

            // Increase Reps
            IconButton(
              onPressed: _incrementReps,
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.primaryColor, // ✅ DARK MODE
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
  }

  // ==================== NAVIGATION BUTTONS ====================
  Widget _buildNavigationButtons() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Secondary button colors
    final secondaryBgColor = isDark
        ? context.primaryColor.withOpacity(0.2)
        : const Color(0xFFB2E5D8);

    final disabledBgColor = isDark
        ? Colors.grey.shade800
        : Colors.grey.shade200;

    final disabledFgColor = isDark
        ? Colors.grey.shade600
        : Colors.grey.shade400;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          // Previous Button
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _currentExerciseIndex > 0 ? _previousExercise : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryBgColor, // ✅ DARK MODE
                  foregroundColor: context.primaryColor, // ✅ DARK MODE
                  disabledBackgroundColor: disabledBgColor, // ✅ DARK MODE
                  disabledForegroundColor: disabledFgColor, // ✅ DARK MODE
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
                  backgroundColor: context.primaryColor, // ✅ DARK MODE
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

    final workoutDuration = Duration(
      minutes: widget.workout.estimatedDuration ?? 30,
    );

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardBackground, // ✅ DARK MODE
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Exit Workout?',
          style: TextStyle(color: context.primaryText), // ✅ DARK MODE
        ),
        content: Text(
          'Are you sure you want to exit? Your progress will be lost.',
          style: TextStyle(color: context.secondaryText), // ✅ DARK MODE
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: context.primaryColor), // ✅ DARK MODE
            ),
          ),
          TextButton(
            onPressed: () {
              _tts.stop();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ==================== REP COUNTER PAINTER ====================
class RepCounterPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  final Color primaryColor;

  RepCounterPainter({
    required this.progress,
    this.isDark = false,
    this.primaryColor = const Color(0xFF1DAB87),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 12.0;

    // Background circle - adapts to dark mode
    final backgroundPaint = Paint()
      ..color = isDark
          ? primaryColor.withOpacity(0.2) // Darker background for dark mode
          : const Color(0xFFB2E5D8) // Light green for light mode
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );
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
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}

// ==================== EXERCISE PERSON PAINTER ====================
class ExercisePersonPainter extends CustomPainter {
  final bool isDark;

  ExercisePersonPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Skin color - slightly adjusted for dark mode visibility
    final skinColor = isDark
        ? const Color(0xFFD4A574) // Slightly warmer for dark mode
        : const Color(0xFFE8C5A5);

    // Head
    paint.color = skinColor;
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.15), 20, paint);

    // Neck
    paint.color = skinColor;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.2),
        width: 10,
        height: 15,
      ),
      paint,
    );

    // Shirt (maroon) - slightly brighter for dark mode
    paint.color = isDark
        ? const Color(0xFFA63D3D) // Brighter maroon for dark mode
        : const Color(0xFF8B2E2E);
    final shirtPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.25)
      ..lineTo(size.width * 0.7, size.height * 0.25)
      ..lineTo(size.width * 0.65, size.height * 0.45)
      ..lineTo(size.width * 0.35, size.height * 0.45)
      ..close();
    canvas.drawPath(shirtPath, paint);

    // Arms
    paint.color = skinColor;
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

    // Shorts (gray) - adjusted for dark mode
    paint.color = isDark
        ? const Color(0xFF8A9BAA) // Slightly lighter for dark mode
        : const Color(0xFF7A8B9A);
    final shortsPath = Path()
      ..moveTo(size.width * 0.35, size.height * 0.45)
      ..lineTo(size.width * 0.65, size.height * 0.45)
      ..lineTo(size.width * 0.6, size.height * 0.65)
      ..lineTo(size.width * 0.4, size.height * 0.65)
      ..close();
    canvas.drawPath(shortsPath, paint);

    // Legs
    paint.color = skinColor;
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
  bool shouldRepaint(ExercisePersonPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
