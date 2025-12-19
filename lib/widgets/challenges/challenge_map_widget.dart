import 'dart:math' as math;
import 'package:flutter/material.dart';

class ChallengeMapWidget extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final String? mapImageUrl;
  final String? avatarUrl;
  final String? userName;
  final String challengeType;
  final int totalMilestones;

  const ChallengeMapWidget({
    super.key,
    required this.progress,
    this.mapImageUrl,
    this.avatarUrl,
    this.userName,
    this.challengeType = 'physical',
    this.totalMilestones = 4,
  });

  @override
  State<ChallengeMapWidget> createState() => _ChallengeMapWidgetState();
}

class _ChallengeMapWidgetState extends State<ChallengeMapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _getThemeColor().withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final avatarPosition = _calculatePositionOnCurve(
              widget.progress,
              constraints.maxWidth,
              constraints.maxHeight,
            );

            return Stack(
              children: [
                // Background
                Positioned.fill(child: _buildBackground()),

                // Decorative Elements
                ..._buildDecorativeElements(),

                // Path and Progress
                Positioned.fill(
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: _EnhancedMapPathPainter(
                      progress: widget.progress,
                      primaryColor: _getThemeColor(),
                      totalMilestones: widget.totalMilestones,
                    ),
                  ),
                ),

                // Milestones
                ..._buildMilestones(
                  constraints.maxWidth,
                  constraints.maxHeight,
                ),

                // User Avatar at current position
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  left: avatarPosition.dx - 25,
                  top: avatarPosition.dy - 25,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: child,
                      );
                    },
                    child: _buildUserAvatar(context),
                  ),
                ),
                // Start Flag
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: _buildFlag(
                    context: context,
                    icon: Icons.play_arrow_rounded,
                    label: 'START',
                    color: Colors.green,
                  ),
                ),

                // Goal Flag
                Positioned(
                  top: 20,
                  right: 20,
                  child: _buildFlag(
                    context: context,
                    icon: widget.progress >= 1.0
                        ? Icons.emoji_events
                        : Icons.flag_rounded,
                    label: widget.progress >= 1.0 ? 'COMPLETE!' : 'GOAL',
                    color: widget.progress >= 1.0 ? Colors.amber : Colors.red,
                    isGoal: true,
                  ),
                ),

                // Progress Overlay
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: _buildProgressBadge(context),
                ),

                // User Name Badge (optional)
                if (widget.userName != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: _buildUserNameBadge(context),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ==================== USER AVATAR ====================
  Widget _buildUserAvatar(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          // Glow effect
          BoxShadow(
            color: _getThemeColor().withOpacity(0.6),
            blurRadius: 15,
            spreadRadius: 3,
          ),
          // Drop shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(child: _buildAvatarContent(context)),
    );
  }

  Widget _buildAvatarContent(BuildContext context) {
    // Priority 1: Network avatar URL
    if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) {
      return Image.network(
        widget.avatarUrl!,
        fit: BoxFit.cover,
        width: 50,
        height: 50,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingAvatar(context);
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackAvatar(context);
        },
      );
    }

    // Priority 2: Fallback to default avatar
    return _buildFallbackAvatar(context);
  }

  Widget _buildLoadingAvatar(BuildContext context) {
    return Container(
      color: _getThemeColor().withOpacity(0.3),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar(BuildContext context) {
    // Try to load local asset first
    return Image.asset(
      'assets/images/profile_male.png',
      fit: BoxFit.cover,
      width: 50,
      height: 50,
      errorBuilder: (context, error, stackTrace) {
        // If asset fails, show icon fallback
        return Container(
          color: _getThemeColor(),
          child: Center(
            child: Icon(Icons.person, color: Colors.white, size: 28),
          ),
        );
      },
    );
  }

  // ==================== USER NAME BADGE ====================
  Widget _buildUserNameBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini avatar
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: ClipOval(
              child: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                  ? Image.network(
                      widget.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: _getThemeColor(),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    )
                  : Container(
                      color: _getThemeColor(),
                      child: Icon(Icons.person, color: Colors.white, size: 12),
                    ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            widget.userName!,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BACKGROUND ====================
  Widget _buildBackground() {
    if (widget.mapImageUrl != null) {
      return Stack(
        children: [
          // Use Image.asset for local assets, Image.network for URLs
          widget.mapImageUrl!.startsWith('http')
              ? Image.network(
                  widget.mapImageUrl!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildGradientBackground(),
                )
              : Image.asset(
                  widget.mapImageUrl!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildGradientBackground(),
                ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.4),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return _buildGradientBackground();
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(gradient: _getBackgroundGradient()),
      child: CustomPaint(
        size: const Size(double.infinity, 220),
        painter: _TerrainPatternPainter(color: Colors.white.withOpacity(0.08)),
      ),
    );
  }

  LinearGradient _getBackgroundGradient() {
    switch (widget.challengeType.toLowerCase()) {
      case 'nutrition':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1a5f2a), Color(0xFF2d8a3e), Color(0xFF45a859)],
        );
      case 'mindfulness':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2d1b4e), Color(0xFF4a2c7a), Color(0xFF6b3fa0)],
        );
      case 'social':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8b2942), Color(0xFFa83257), Color(0xFFc94b6d)],
        );
      case 'physical':
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0d4f3c), Color(0xFF1a7a5c), Color(0xFF28a77d)],
        );
    }
  }

  Color _getThemeColor() {
    switch (widget.challengeType.toLowerCase()) {
      case 'nutrition':
        return const Color(0xFF00C6FB);
      case 'mindfulness':
        return const Color(0xFFA18CD1);
      case 'social':
        return const Color(0xFFfa709a);
      case 'physical':
      default:
        return const Color(0xFF43E97B);
    }
  }

  // ==================== DECORATIVE ELEMENTS ====================
  List<Widget> _buildDecorativeElements() {
    return [
      Positioned(top: 60, left: 50, child: _buildTree()),
      Positioned(top: 100, left: 120, child: _buildTree(small: true)),
      Positioned(bottom: 80, right: 80, child: _buildTree()),
      Positioned(top: 140, right: 140, child: _buildTree(small: true)),
      Positioned(bottom: 50, left: 180, child: _buildTree(small: true)),
    ];
  }

  Widget _buildTree({bool small = false}) {
    final size = small ? 16.0 : 24.0;
    return Icon(Icons.park, size: size, color: Colors.white.withOpacity(0.15));
  }

  // ==================== MILESTONES ====================
  List<Widget> _buildMilestones(double width, double height) {
    final milestones = <Widget>[];

    for (int i = 1; i < widget.totalMilestones; i++) {
      final t = i / widget.totalMilestones;
      final position = _calculatePositionOnCurve(t, width, height);
      final isCompleted = widget.progress >= t;

      milestones.add(
        Positioned(
          left: position.dx - 14,
          top: position.dy - 14,
          child: _buildMilestone(index: i, isCompleted: isCompleted),
        ),
      );
    }

    return milestones;
  }

  Widget _buildMilestone({required int index, required bool isCompleted}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? _getThemeColor() : Colors.white.withOpacity(0.3),
        border: Border.all(
          color: isCompleted ? Colors.white : Colors.white.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: isCompleted
            ? [
                BoxShadow(
                  color: _getThemeColor().withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : Text(
                '$index',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  // ==================== FLAGS ====================
  Widget _buildFlag({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    bool isGoal = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isGoal && widget.progress >= 1.0
                  ? Colors.amber
                  : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PROGRESS BADGE ====================
  Widget _buildProgressBadge(BuildContext context) {
    final percentage = (widget.progress * 100).clamp(0, 100).toInt();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getThemeColor().withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              value: widget.progress,
              strokeWidth: 3,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(_getThemeColor()),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$percentage%',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PATH CALCULATION ====================
  Offset _calculatePositionOnCurve(double t, double width, double height) {
    final p0 = Offset(width * 0.12, height * 0.85);
    final p1 = Offset(width * 0.35, height * 0.75);
    final p2 = Offset(width * 0.25, height * 0.40);
    final p3 = Offset(width * 0.55, height * 0.35);
    final p4 = Offset(width * 0.75, height * 0.30);
    final p5 = Offset(width * 0.65, height * 0.15);
    final p6 = Offset(width * 0.88, height * 0.12);

    if (t <= 0.5) {
      final localT = t * 2;
      return _cubicBezier(p0, p1, p2, p3, localT);
    } else {
      final localT = (t - 0.5) * 2;
      return _cubicBezier(p3, p4, p5, p6, localT);
    }
  }

  Offset _cubicBezier(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final t2 = t * t;
    final t3 = t2 * t;
    final mt = 1 - t;
    final mt2 = mt * mt;
    final mt3 = mt2 * mt;

    return Offset(
      mt3 * p0.dx + 3 * mt2 * t * p1.dx + 3 * mt * t2 * p2.dx + t3 * p3.dx,
      mt3 * p0.dy + 3 * mt2 * t * p1.dy + 3 * mt * t2 * p2.dy + t3 * p3.dy,
    );
  }
}

// ==================== PATH PAINTER ====================
class _EnhancedMapPathPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final int totalMilestones;

  _EnhancedMapPathPainter({
    required this.progress,
    required this.primaryColor,
    required this.totalMilestones,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final incompletePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final completePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = primaryColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final p0 = Offset(size.width * 0.12, size.height * 0.85);
    final p1 = Offset(size.width * 0.35, size.height * 0.75);
    final p2 = Offset(size.width * 0.25, size.height * 0.40);
    final p3 = Offset(size.width * 0.55, size.height * 0.35);
    final p4 = Offset(size.width * 0.75, size.height * 0.30);
    final p5 = Offset(size.width * 0.65, size.height * 0.15);
    final p6 = Offset(size.width * 0.88, size.height * 0.12);

    final fullPath = Path()
      ..moveTo(p0.dx, p0.dy)
      ..cubicTo(p1.dx, p1.dy, p2.dx, p2.dy, p3.dx, p3.dy)
      ..cubicTo(p4.dx, p4.dy, p5.dx, p5.dy, p6.dx, p6.dy);

    _drawDashedPath(canvas, fullPath, incompletePaint);

    if (progress > 0) {
      final completePath = _extractPathPortion(fullPath, progress);
      canvas.drawPath(completePath, glowPaint);
      canvas.drawPath(completePath, completePaint);
    }

    _drawEndpoint(canvas, p0, Colors.green, true);
    _drawEndpoint(
      canvas,
      p6,
      progress >= 1.0 ? Colors.amber : Colors.red,
      false,
    );
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final dashPath = metric.extractPath(distance, distance + 12);
        canvas.drawPath(dashPath, paint);
        distance += 20;
      }
    }
  }

  Path _extractPathPortion(Path fullPath, double portion) {
    final metrics = fullPath.computeMetrics();
    final result = Path();

    for (final metric in metrics) {
      final length = metric.length * portion;
      result.addPath(metric.extractPath(0, length), Offset.zero);
    }

    return result;
  }

  void _drawEndpoint(
    Canvas canvas,
    Offset position,
    Color color,
    bool isStart,
  ) {
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(position, 12, glowPaint);

    final fillPaint = Paint()..color = color;
    canvas.drawCircle(position, 8, fillPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(position, 8, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _EnhancedMapPathPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ==================== TERRAIN PATTERN PAINTER ====================
class _TerrainPatternPainter extends CustomPainter {
  final Color color;

  _TerrainPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final random = math.Random(42);

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 3 + 1;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
