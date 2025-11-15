import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:powerhouse/models/badge_model.dart';
import 'package:powerhouse/core/constants/badge_icons.dart';

class BadgeUnlockScreen extends StatefulWidget {
  final BadgeModel badge;

  const BadgeUnlockScreen({
    Key? key,
    required this.badge,
  }) : super(key: key);

  @override
  State<BadgeUnlockScreen> createState() => _BadgeUnlockScreenState();
}

class _BadgeUnlockScreenState extends State<BadgeUnlockScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _colorAnimation;

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

    _colorAnimation = ColorTween(
      begin: Colors.grey.shade400,
      end: const Color(0xFF1DAB87),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // Auto close after animation
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceColor.withOpacity(0.9),
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Stack(
          children: [
            // Background Lottie Animation
            Center(
              child: Lottie.asset(
                'assets/animations/badge.json',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback: Show sparkles instead
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

            // Badge Content
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
                          // "Achievement Unlocked" Text
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: const Text(
                              '🎉 Achievement Unlocked! 🎉',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Badge Icon with Color Animation
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              color: _colorAnimation.value,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (_colorAnimation.value ?? const Color(0xFF1DAB87))
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
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Padding(
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
                          ),

                          const SizedBox(height: 16),

                          // Badge Description
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Padding(
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
                          ),

                          const SizedBox(height: 40),

                          // Tap to continue
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: const Text(
                              'Tap anywhere to continue',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white54,
                                fontStyle: FontStyle.italic,
                              ),
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
    // Try to get local asset first
    final assetPath = BadgeIcons.getAssetPath(widget.badge.badgeName);
    
    if (assetPath != null) {
      // Use local asset
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Image.asset(
          assetPath,
          color: Colors.white,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackIcon();
          },
        ),
      );
    } else if (widget.badge.iconUrl != null && widget.badge.iconUrl!.isNotEmpty) {
      // Fallback to network URL if available
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Image.network(
          widget.badge.iconUrl!,
          color: Colors.white,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackIcon();
          },
        ),
      );
    } else {
      // Default icon
      return _buildFallbackIcon();
    }
  }

  Widget _buildFallbackIcon() {
    return const Icon(
      Icons.emoji_events,
      color: Colors.white,
      size: 80,
    );
  }
}