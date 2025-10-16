import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.repeat(min: 0, max: 50, period: const Duration(seconds: 2));
    });

    _navigateToWelcome();
  }

  _navigateToWelcome() async {
    await Future.delayed(const Duration(seconds: 3));
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
          'assets/animations/splash_screen.json',
          width: 300,
          height: 300,
        ),
      ),
    );
  }
}
