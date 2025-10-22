import 'package:flutter/material.dart';
import 'package:powerhouse/core/config/supabase_config.dart';
import 'package:powerhouse/core/constants/app_colors.dart';
import 'package:powerhouse/core/routes/app_routes.dart';
import 'package:powerhouse/screens/home/main_navigation.dart';
import 'package:powerhouse/screens/onboarding/onboard_screen.dart';
import 'package:powerhouse/screens/onboarding/verification_screen.dart';
import 'package:powerhouse/screens/splash/splash_screen.dart';
import 'package:powerhouse/screens/onboarding/welcome_screen.dart';
import 'package:powerhouse/screens/onboarding/sign_up_screen.dart';
import 'package:powerhouse/screens/onboarding/sign_in_screen.dart';
import 'package:powerhouse/screens/profile_setup/gender_screen.dart';
import 'package:powerhouse/screens/profile_setup/age_screen.dart';
import 'package:powerhouse/screens/profile_setup/weight_screen.dart';
import 'package:powerhouse/screens/profile_setup/height_screen.dart';
import 'package:powerhouse/screens/profile_setup/goal_screen.dart';
import 'package:powerhouse/screens/profile_setup/congratulations_screen.dart';
// Import other screens as you create them

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POWERHOUSE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.welcome: (context) => const WelcomeScreen(),
        // Add other routes as you create screens
        AppRoutes.onboard: (context) => const OnboardScreen(),
        AppRoutes.signUp: (context) => const SignUpScreen(),
        AppRoutes.signIn: (context) => const SignInScreen(),
        AppRoutes.verification: (context) => const VerificationScreen(),
        AppRoutes.gender: (context) => const GenderScreen(),
        AppRoutes.age: (context) => const AgeScreen(),
        AppRoutes.weight: (context) => const WeightScreen(),
        AppRoutes.height: (context) => const HeightScreen(),
        AppRoutes.goal: (context) => const GoalScreen(),
        AppRoutes.congratulations: (context) => const CongratulationsScreen(),
        AppRoutes.MainNavigation: (context) => const MainNavigation(),
      },
    );
  }
}