import 'package:flutter/material.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'dart:math' as math;
import 'package:powerhouse/services/auth_service.dart';
import 'package:lottie/lottie.dart';
import 'package:powerhouse/widgets/animated_message.dart';

class CongratulationsScreen extends StatefulWidget {
  const CongratulationsScreen({super.key});

  @override
  State<CongratulationsScreen> createState() => _CongratulationsScreenState();
}

class _CongratulationsScreenState extends State<CongratulationsScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isSaving = false;
  bool _profileSaved = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // Save profile automatically when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveProfileToDatabase();
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
      backgroundColor: context.surfaceColor, // ✅ DARK MODE
      body: SafeArea(
        child: Stack(
          children: [
            // Confetti background
            _buildConfetti(),

            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  _buildOutlineTitle(),

                  const Spacer(),

                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildSuccessIcon(),
                  ),

                  const SizedBox(height: 30),

                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildCongratulationsText(),
                  ),

                  const SizedBox(height: 16),

                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildSubtitle(),
                  ),

                  const Spacer(),

                  _buildStartButton(),

                  const SizedBox(height: 60),
                ],
              ),
            ),

            // Loading overlay
            if (_isSaving)
              Container(
                color: Colors.black54,
                child: Center(
                  child: CircularProgressIndicator(
                    color: context.primaryColor, // ✅ DARK MODE
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlineTitle() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Image.asset(
        'assets/images/logo.png',
        height: 120,
        width: 280,
        fit: BoxFit.contain,
        // Optional: Apply color filter for dark mode if logo is dark
        color: isDark ? Colors.white : null,
        colorBlendMode: isDark ? BlendMode.srcIn : null,
        errorBuilder: (context, error, stackTrace) {
          return Stack(
            children: [
              Text(
                'PowerHouse',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -2,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2
                    ..color = isDark ? Colors.white : Colors.black,
                ),
              ),
              Text(
                'PowerHouse',
                style: TextStyle(
                  color: context.surfaceColor,
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -2,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSuccessIcon() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 300,
      height: 300,
      child: Lottie.asset(
        'assets/animations/success.json',
        repeat: false,
        animate: true,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to the original icon if Lottie file is not found
          return Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: context.primaryColor.withOpacity(
                isDark ? 0.2 : 0.1,
              ), // ✅ DARK MODE
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: context.primaryColor, // ✅ DARK MODE
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCongratulationsText() {
    return Text(
      'Congratulations!',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: context.primaryColor, // ✅ DARK MODE
        fontSize: 40,
        fontWeight: FontWeight.w800,
        height: 1.15,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Your profile is ready!',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: context.primaryText, // ✅ DARK MODE
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildConfetti() {
    return Stack(
      children: List.generate(30, (index) {
        return _ConfettiParticle(index: index);
      }),
    );
  }

  Widget _buildStartButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Disabled colors
    final disabledColors = isDark
        ? [Colors.grey.shade700, Colors.grey.shade600]
        : [Colors.grey.shade400, Colors.grey.shade500];

    return GestureDetector(
      onTap: _profileSaved ? _handleStart : null,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _profileSaved
                ? [context.primaryColor, const Color(0xFF2DD4A3)] // ✅ DARK MODE
                : disabledColors,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: _profileSaved
              ? [
                  BoxShadow(
                    color: context.primaryColor.withOpacity(0.3), // ✅ DARK MODE
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            _isSaving ? 'Saving...' : "Let's Start!",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  // ========== SAVE PROFILE TO DATABASE ==========
  Future<void> _saveProfileToDatabase() async {
    if (_isSaving || _profileSaved) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Get all profile data from navigation arguments
      final args = ModalRoute.of(context)?.settings.arguments as Map?;

      if (args == null) {
        throw Exception('Profile data missing');
      }

      print('📦 Profile data received: $args');

      // Extract data
      final gender = args['gender'] as String?;
      final ageStr = args['age'] as String?;
      final weightStr = args['weight'] as String?;
      final heightStr = args['height'] as String?;
      final goal = args['goal'] as String?;
      final weightUnit = args['weightUnit'] as String?;
      final heightUnit = args['heightUnit'] as String?;

      // Validate required fields
      if (gender == null ||
          ageStr == null ||
          weightStr == null ||
          heightStr == null ||
          goal == null) {
        throw Exception('Missing required profile fields');
      }

      // Parse values
      final age = int.parse(ageStr);
      final weight = double.parse(weightStr);
      final height = double.parse(heightStr);

      print('💾 Saving profile to database...');

      // Save to database
      await _authService.completeProfileSetup(
        gender: gender,
        age: age,
        weight: weight,
        height: height,
        goal: goal,
        weightUnit: weightUnit ?? 'kg',
        heightUnit: heightUnit ?? 'cm',
      );

      setState(() {
        _isSaving = false;
        _profileSaved = true;
      });

      print('✅ Profile saved successfully!');

      // Show success message
      if (mounted) {
        AnimatedMessage.show(
          context,
          message: '✅ Profile created successfully!',
          backgroundColor: context.primaryColor,
          icon: Icons.check_circle_rounded,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      print('❌ Error saving profile: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                _saveProfileToDatabase();
              },
            ),
          ),
        );
      }
    }
  }

  void _handleStart() {
    if (!_profileSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('⏳ Please wait while we save your profile...'),
          backgroundColor: context.accentColor,
        ),
      );
      return;
    }

    print('🚀 Navigating to home...');

    // Navigate to home screen and remove all previous routes
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }
}

// Confetti Particle Widget - Updated for Dark Mode
class _ConfettiParticle extends StatefulWidget {
  final int index;

  const _ConfettiParticle({required this.index});

  @override
  State<_ConfettiParticle> createState() => _ConfettiParticleState();
}

class _ConfettiParticleState extends State<_ConfettiParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double leftPosition;
  late double delay;
  late Color color;

  @override
  void initState() {
    super.initState();

    final random = math.Random(widget.index);
    leftPosition = random.nextDouble() * 400;
    delay = random.nextDouble() * 2;

    // Confetti colors - these work well in both light and dark mode
    final colors = [
      const Color(0xFF1DAB87), // Primary green
      const Color(0xFFFF6B6B), // Red/Pink
      const Color(0xFF4ECDC4), // Teal
      const Color(0xFFFFE66D), // Yellow
      const Color(0xFFFF9ECD), // Pink
      const Color(0xFFF97316), // Orange (accent)
      const Color(0xFFB19CD9), // Purple
    ];
    color = colors[random.nextInt(colors.length)];

    _controller = AnimationController(
      duration: Duration(milliseconds: 3000 + random.nextInt(2000)),
      vsync: this,
    );

    Future.delayed(Duration(milliseconds: (delay * 1000).toInt()), () {
      if (mounted) {
        _controller.repeat();
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: leftPosition,
          top: -20 + (_controller.value * MediaQuery.of(context).size.height),
          child: Transform.rotate(
            angle: _controller.value * 4 * math.pi,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                // Add subtle glow effect for dark mode
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
