import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A circular button with an animated progress indicator
///
/// Displays a circular progress arc around a navigation button,
/// showing completion percentage through the profile setup flow.
class CircularProgressButton extends StatelessWidget {
  /// Progress value from 0.0 to 1.0
  final double progress;

  /// Callback when button is tapped
  final VoidCallback? onTap;

  /// Whether the button is enabled
  final bool isEnabled;

  const CircularProgressButton({
    super.key,
    required this.progress,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Progress indicator
            CustomPaint(
              size: const Size(110, 110),
              painter: CircularProgressPainter(
                progress: progress,
                isEnabled: isEnabled,
              ),
            ),

            // Outer circle (light background)
            // Container(
            //   width: 100,
            //   height: 100,
            //   decoration: BoxDecoration(
            //     color: isEnabled
            //         ? const Color(0xFF1DAB87).withOpacity(0.3)
            //         : Colors.grey.withOpacity(0.2),
            //     shape: BoxShape.circle,
            //   ),
            // ),

            // Inner circle (solid button)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isEnabled ? const Color(0xFF1DAB87) : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the circular progress indicator
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final bool isEnabled;

  CircularProgressPainter({required this.progress, required this.isEnabled});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle (light gray track)
    final backgroundPaint = Paint()
      ..color = const Color(0xFFE0E0E0).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - 3, backgroundPaint);

    // Progress arc (teal color)
    if (progress > 0 && isEnabled) {
      final progressPaint = Paint()
        ..color = const Color(0xFF1DAB87)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round;

      // Draw arc from top (-90 degrees) clockwise
      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 3),
        -math.pi / 2, // Start from top
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isEnabled != isEnabled;
  }
}
