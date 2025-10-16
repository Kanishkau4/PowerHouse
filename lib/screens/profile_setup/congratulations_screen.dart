import 'package:flutter/material.dart';
import 'dart:math' as math;

class CongratulationsScreen extends StatefulWidget {
  const CongratulationsScreen({Key? key}) : super(key: key);

  @override
  State<CongratulationsScreen> createState() => _CongratulationsScreenState();
}

class _CongratulationsScreenState extends State<CongratulationsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
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
                  
                  // Outline Title
                  _buildOutlineTitle(),
                  
                  const Spacer(),
                  
                  // Success Icon/Image
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildSuccessIcon(),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Congratulations Text
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildCongratulationsText(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Subtitle
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildSubtitle(),
                  ),
                  
                  const Spacer(),
                  
                  // Let's Start Button
                  _buildStartButton(),
                  
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlineTitle() {
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
              ..color = const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        const Text(
          'PowerHouse',
          style: TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.w700,
            letterSpacing: -2,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF1DAB87).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: const BoxDecoration(
              color: Color(0xFF1DAB87),
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
  }

  Widget _buildCongratulationsText() {
    return const Text(
      'Congratulations!',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color(0xFF1DAB87),
        fontSize: 40,
        fontWeight: FontWeight.w800,
        height: 1.15,
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      'You completed your first challenge',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildConfetti() {
    return Stack(
      children: List.generate(30, (index) {
        return _ConfettiParticle(
          index: index,
        );
      }),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: _handleStart,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1DAB87), Color(0xFF2DD4A3)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1DAB87).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "Let's Start!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  void _handleStart() {
    // Get user data
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    print('User profile data: $args');

    // Navigate to home screen
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false, // Remove all previous routes
    );
  }
}

// Confetti Particle Widget
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
    
    final colors = [
      const Color(0xFF1DAB87),
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFE66D),
      const Color(0xFFFF9ECD),
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
              ),
            ),
          ),
        );
      },
    );
  }
}