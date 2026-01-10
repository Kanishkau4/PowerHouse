import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:powerhouse/core/config/supabase_config.dart';
import 'package:powerhouse/screens/home/main_navigation.dart';
import 'package:powerhouse/screens/onboarding/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;
  late AnimationController _fillController;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();

    _lottieController = AnimationController(vsync: this);

    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fillAnimation = Tween<double>(begin: 0.0, end: 30.0).animate(
      CurvedAnimation(parent: _fillController, curve: Curves.easeInOut),
    );

    _checkSessionAndAnimate();
  }

  _checkSessionAndAnimate() async {
    // 1. Wait for splash duration
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted) return;

    // 2. Start the Expansion (Fill screen with color)
    await _fillController.forward();

    final session = SupabaseConfig.client.auth.currentSession;

    if (!mounted) return;

    Widget nextScreen = (session != null)
        ? const MainNavigation()
        : const WelcomeScreen();

    // 3. Navigate instantly
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextScreen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _fillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double maxSize = screenSize.height > screenSize.width
        ? screenSize.height
        : screenSize.width;

    // MEKA THAMAI WENASA:
    // App eke Theme eka anuwa background color eka gannawa.
    // ThemeProvider eken Dark mode dila thibboth meka auto dark wenawa.
    final targetBackgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: const Color(0xFF1DAB87),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Lottie (Bottom Layer)
          Center(
            child: Lottie.asset(
              'assets/animations/Muscle.json',
              controller: _lottieController,
              onLoaded: (composition) {
                _lottieController.duration = composition.duration * 2;
                _lottieController.forward();
              },
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
          ),

          // 2. Expanding Circle (Top Layer)
          ScaleTransition(
            scale: _fillAnimation,
            child: Container(
              width: maxSize / 20,
              height: maxSize / 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    targetBackgroundColor, // <--- Auto changes based on theme
              ),
            ),
          ),
        ],
      ),
    );
  }
}
