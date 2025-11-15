import 'package:flutter/material.dart';
import 'package:powerhouse/models/workout_model.dart';
import 'dart:math' as math;
import 'package:powerhouse/screens/workouts/workout_session_screen.dart';

class ReadyWorkoutScreen extends StatefulWidget {
  final WorkoutModel workout;
  final int countdownSeconds;

  const ReadyWorkoutScreen({
    super.key,
    required this.workout,
    this.countdownSeconds = 10,
  });

  @override
  State<ReadyWorkoutScreen> createState() => _ReadyWorkoutScreenState();
}

class _ReadyWorkoutScreenState extends State<ReadyWorkoutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int countdown = 9; // Will be updated dynamically

  @override
  void initState() {
    super.initState();

    // Ensure countdown is at least 1
    final seconds = widget.countdownSeconds.clamp(1, 60);
    countdown = seconds;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: seconds),
    );

    // Start the countdown animation
    _controller.forward();

    // Update countdown number as animation progresses
    _controller.addListener(() {
      // Calculate remaining seconds: total - elapsed
      int remaining = (seconds - (_controller.value * seconds)).ceil();
      if (remaining < 0) remaining = 0;

      if (remaining != countdown) {
        setState(() {
          countdown = remaining;
        });
      }

      // Auto-navigate when done
      if (_controller.isCompleted) {
        _navigateToWorkoutSession();
      }
    });
  }

  void _navigateToWorkoutSession() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutSessionScreen(workout: widget.workout),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Back Button (Top Left)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    _controller.stop();
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
                ),
              ),
            ),

            // Main Content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Get Ready Text
                  const Text(
                    'Get Ready!',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1DAB87),
                    ),
                  ),
                  const SizedBox(height: 80),

                  // Countdown Circle with Progress Arc
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(250, 250),
                        painter: CountdownCirclePainter(
                          progress: _controller.value,
                          activeColor: const Color(0xFF1DAB87),
                          backgroundColor: const Color(0x541DAB87), // ~33% opacity
                        ),
                        child: SizedBox(
                          width: 250,
                          height: 250,
                          child: Center(
                            child: Text(
                              '$countdown',
                              style: const TextStyle(
                                fontSize: 120,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1DAB87),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Start Now Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    _controller.stop();
                    _navigateToWorkoutSession();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DAB87),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFF1DAB87).withOpacity(0.3),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Start Now',
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
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ==================== CUSTOM PAINTER FOR COUNTDOWN ARC ====================
class CountdownCirclePainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color backgroundColor;

  CountdownCirclePainter({
    required this.progress,
    this.activeColor = const Color(0xFF1DAB87),
    this.backgroundColor = const Color(0x541DAB87),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10; // Leave margin for stroke
    final strokeWidth = 20.0;

    // Background circle (faded)
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc (active color)
    final progressPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw arc starting from top (-90° = -π/2 radians)
    final sweepAngle = progress * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CountdownCirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}