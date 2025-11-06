import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:powerhouse/models/workout_model.dart'; // Add this import

class RestScreen extends StatefulWidget {
  final ExerciseWithDetails nextExercise; // Change type from Exercise to ExerciseWithDetails
  final int restSeconds;
  final VoidCallback onRestComplete;

  const RestScreen({
    super.key,
    required this.nextExercise,
    this.restSeconds = 30,
    required this.onRestComplete,
  });

  @override
  State<RestScreen> createState() => _RestScreenState();
}

class _RestScreenState extends State<RestScreen>
    with SingleTickerProviderStateMixin {
  late int _secondsRemaining;
  Timer? _restTimer;
  final FlutterTts _tts = FlutterTts();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.restSeconds;
    
    // Configure TTS
    _configureTts();
    
    // Pulse animation for timer
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startRestTimer();
    _announceRest();
  }

  Future<void> _configureTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> _announceRest() async {
    await _tts.speak("Take a rest");
    await Future.delayed(const Duration(seconds: 2));
    await _tts.speak("Next exercise is ${widget.nextExercise.exercise.exerciseName}"); // Access exerciseName through exercise property
  }

  void _startRestTimer() {
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
        
        // Countdown voice for last 5 seconds
        if (_secondsRemaining <= 5) {
          _tts.speak(_secondsRemaining.toString());
        }
      } else {
        _restTimer?.cancel();
        _tts.speak("Let's go!");
        Future.delayed(const Duration(milliseconds: 800), () {
          Navigator.pop(context);
          widget.onRestComplete();
        });
      }
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    _tts.stop();
    Navigator.pop(context);
    widget.onRestComplete();
  }

  String get _timeText {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _pulseController.dispose();
    _tts.stop();
    super.dispose();
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
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 60),

                        // Title
                        const Text(
                          'Take a Rest',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1DAB87),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Countdown Timer with Animation
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Text(
                                _timeText,
                                style: const TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 40),

                        // Divider
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: Container(
                            height: 1,
                            color: const Color(0xFF7E7E7E),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Next Workout Section
                        const Text(
                          'Next workout',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          widget.nextExercise.exercise.exerciseName, // Access exerciseName through exercise property
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7E7E7E),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Preview Card
                        _buildPreviewCard(),

                        const SizedBox(height: 32),

                        // Action Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildActionButtons(),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),

              // Back Button (always visible on top)
              Positioned(
                top: 16,
                left: 16,
                child: _buildBackButton(),
              ),
            ],
          );
        },
      ),
    ),
  );
}

  Widget _buildPreviewCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: double.infinity,
        height: 177,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0x191DAB87),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            // Exercise Image/Icon
            Container(
              width: 120,
              height: 137,
              decoration: BoxDecoration(
                color: const Color(0xFF1DAB87).withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: widget.nextExercise.exercise.animationUrl?.isNotEmpty == true // Access animationUrl through exercise property
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        widget.nextExercise.exercise.animationUrl!, // Access animationUrl through exercise property
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.fitness_center,
                            size: 60,
                            color: Color(0xFF1DAB87),
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.fitness_center,
                      size: 60,
                      color: Color(0xFF1DAB87),
                    ),
            ),
            
            const SizedBox(width: 20),
            
            // Exercise Info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.nextExercise.exercise.exerciseName, // Access exerciseName through exercise property
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 20,
                        color: Color(0xFF7E7E7E),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.nextExercise.durationFormatted, // Use durationFormatted from ExerciseWithDetails
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7E7E7E),
                        ),
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Add +20s Button
        TextButton.icon(
          onPressed: () {
            setState(() {
              _secondsRemaining += 20;
            });
            _tts.speak("Added 20 seconds");
          },
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Add 20s'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF1DAB87),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Skip Rest / Start Now Button
        SizedBox(
          width: double.infinity,
          height: 62,
          child: ElevatedButton(
            onPressed: _skipRest,
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
                  'Skip Rest',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.skip_next, size: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        _restTimer?.cancel();
        _tts.stop();
        Navigator.pop(context);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF1DAB87).withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF1DAB87),
            width: 2,
          ),
        ),
        child: const Icon(
          Icons.close,
          color: Color(0xFF1DAB87),
          size: 24,
        ),
      ),
    );
  }
}