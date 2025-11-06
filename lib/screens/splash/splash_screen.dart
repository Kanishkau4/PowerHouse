import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this);

    // Set speed and play once (no repeat)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.duration = const Duration(seconds: 4); // slower animation (x0.5 roughly)
      controller.forward(); // play once
    });

    _navigateToWelcome();
  }

  _navigateToWelcome() async {
    await Future.delayed(const Duration(seconds: 4)); // increase splash duration
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1DAB87),
      body: Center(
        child: Lottie.asset(
          'assets/animations/Muscle.json',
          controller: controller, // attach controller
          onLoaded: (composition) {
            controller.duration = composition.duration * 2; // slow down (x0.5)
            controller.forward();
          },
          width: 100,
          height: 100,
        ),
      ),
    );
  }
}
