import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:powerhouse/models/badge_model.dart';
import 'package:powerhouse/core/constants/badge_icons.dart';

class BadgeUnlockScreen extends StatefulWidget {
  final BadgeModel badge;

  const BadgeUnlockScreen({super.key, required this.badge});

  @override
  State<BadgeUnlockScreen> createState() => _BadgeUnlockScreenState();
}

class _BadgeUnlockScreenState extends State<BadgeUnlockScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _bgColorAnimation;

  // This controls grayscale → full color transition
  late Animation<double> _grayscaleToColorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _bgColorAnimation =
        ColorTween(
          begin: Colors.grey.shade400,
          end: const Color(0xFF1DAB87),
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 0.8, curve: Curves.easeInOut),
          ),
        );

    // Grayscale (1.0) → Full color (0.0)
    _grayscaleToColorAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Auto close after full animation
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Grayscale matrix: amount 1.0 = fully gray, 0.0 = full color
  ColorFilter _grayscaleFilter(double amount) {
    final inverse = 1.0 - amount;
    return ColorFilter.matrix([
      inverse * 0.33 + amount * 0.299,
      inverse * 0.33 + amount * 0.587,
      inverse * 0.33 + amount * 0.114,
      0,
      0, // Red
      inverse * 0.33 + amount * 0.299,
      inverse * 0.33 + amount * 0.587,
      inverse * 0.33 + amount * 0.114,
      0,
      0, // Green
      inverse * 0.33 + amount * 0.299,
      inverse * 0.33 + amount * 0.587,
      inverse * 0.33 + amount * 0.114,
      0,
      0, // Blue
      0,
      0,
      0,
      1,
      0, // Alpha
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceColor.withOpacity(0.9),
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Stack(
          children: [
            // Confetti Background
            Center(
              child: Lottie.asset(
                'assets/animations/confetti.json',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF1DAB87).withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Main Content
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Title
                          const Text(
                            'Achievement Unlocked!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 40),

                          // Badge Circle + Icon
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              color: _bgColorAnimation.value,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (_bgColorAnimation.value ??
                                              const Color(0xFF1DAB87))
                                          .withOpacity(0.5),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: _buildBadgeIcon(),
                          ),

                          const SizedBox(height: 40),

                          // Badge Name
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              widget.badge.badgeName,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1DAB87),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Description
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              widget.badge.description ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Tap hint
                          const Text(
                            'Tap anywhere to continue',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white54,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeIcon() {
    final assetPath = BadgeIcons.getAssetPath(widget.badge.badgeName);

    return AnimatedBuilder(
      animation: _grayscaleToColorAnimation,
      builder: (context, child) {
        final grayscaleAmount = _grayscaleToColorAnimation.value;

        return Padding(
          padding: const EdgeInsets.all(30),
          child: ColorFiltered(
            colorFilter: grayscaleAmount > 0.01
                ? _grayscaleFilter(grayscaleAmount)
                : const ColorFilter.mode(Colors.transparent, BlendMode.color),
            child: _getBadgeImage(assetPath),
          ),
        );
      },
    );
  }

  Widget _getBadgeImage(String? assetPath) {
    if (assetPath != null) {
      return Image.asset(
        assetPath,
        width: 120,
        height: 120,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
      );
    } else if (widget.badge.iconUrl != null &&
        widget.badge.iconUrl!.isNotEmpty) {
      return Image.network(
        widget.badge.iconUrl!,
        width: 120,
        height: 120,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const CircularProgressIndicator(color: Colors.white);
        },
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
      );
    } else {
      return _buildFallbackIcon();
    }
  }

  Widget _buildFallbackIcon() {
    return AnimatedBuilder(
      animation: _grayscaleToColorAnimation,
      builder: (context, child) {
        final amount = _grayscaleToColorAnimation.value;
        final targetColor = const Color(0xFFFFD700); // Gold trophy color
        final currentColor = Color.lerp(
          Colors.grey.shade400,
          targetColor,
          1.0 - amount,
        )!;

        return Icon(Icons.emoji_events, color: currentColor, size: 100);
      },
    );
  }
}
