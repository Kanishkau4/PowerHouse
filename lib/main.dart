import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:powerhouse/services/notification_service.dart';
import 'package:powerhouse/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:powerhouse/core/config/supabase_config.dart';
import 'package:powerhouse/core/routes/app_routes.dart';
import 'package:powerhouse/core/theme/theme_provider.dart';
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
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await SupabaseConfig.initialize();

  // Initialize notifications
  await NotificationService().initialize();
  await NotificationService().requestPermissions();

  // Schedule inactivity reminder (will notify if user doesn't use app for 3 days)
  await NotificationService().scheduleInactivityReminder();

  // Check and schedule other enabled notifications (workout, meals, etc.)
  await NotificationService().checkAndScheduleNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Add more providers here as needed
        // ChangeNotifierProvider(create: (_) => UserProvider()),
        // ChangeNotifierProvider(create: (_) => WorkoutProvider()),
      ],
      child: const PowerHouseApp(),
    );
  }
}

class PowerHouseApp extends StatefulWidget {
  const PowerHouseApp({super.key});

  @override
  State<PowerHouseApp> createState() => _PowerHouseAppState();
}

class _PowerHouseAppState extends State<PowerHouseApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final StreamSubscription<AuthState> _authSubscription;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    // Listen to auth state changes (including OAuth callbacks)
    _authSubscription = SupabaseConfig.client.auth.onAuthStateChange.listen(
      (data) {
        final event = data.event;
        final session = data.session;

        print('🔐 Auth event: $event');

        if (event == AuthChangeEvent.signedIn && session != null) {
          print('✅ User signed in: ${session.user.id}');
          _handleSuccessfulAuth();
        } else if (event == AuthChangeEvent.signedOut) {
          print('🚪 User signed out');
        } else if (event == AuthChangeEvent.tokenRefreshed) {
          print('🔄 Token refreshed');
        }
      },
      onError: (error) {
        print('❌ Auth error: $error');
      },
    );
  }

  Future<void> _handleSuccessfulAuth() async {
    try {
      // Wait a bit for the navigation context to be ready
      await Future.delayed(const Duration(milliseconds: 500));

      final context = _navigatorKey.currentContext;
      if (context == null || !mounted) return;

      // Create profile for OAuth users if it doesn't exist
      print('👤 Creating OAuth user profile if needed...');
      await _authService.createOAuthUserProfile();

      print('🔍 Checking if profile is complete...');
      final isComplete = await _authService.isProfileComplete();

      print('📊 Profile complete: $isComplete');

      if (!mounted) return;

      if (isComplete) {
        // Profile is complete, go to home
        print('🏠 Navigating to home...');
        _navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.MainNavigation,
          (route) => false,
        );
      } else {
        // Profile incomplete, go to profile setup
        print('📝 Navigating to profile setup...');
        _navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.gender,
          (route) => false,
        );
      }
    } catch (e) {
      print('❌ Error handling auth: $e');
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          title: 'POWERHOUSE',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          initialRoute: AppRoutes.splash,
          routes: {
            AppRoutes.splash: (context) => const SplashScreen(),
            AppRoutes.welcome: (context) => const WelcomeScreen(),
            AppRoutes.onboard: (context) => const OnboardScreen(),
            AppRoutes.signUp: (context) => const SignUpScreen(),
            AppRoutes.signIn: (context) => const SignInScreen(),
            AppRoutes.verification: (context) => const VerificationScreen(),
            AppRoutes.gender: (context) => const GenderScreen(),
            AppRoutes.age: (context) => const AgeScreen(),
            AppRoutes.weight: (context) => const WeightScreen(),
            AppRoutes.height: (context) => const HeightScreen(),
            AppRoutes.goal: (context) => const GoalScreen(),
            AppRoutes.congratulations: (context) =>
                const CongratulationsScreen(),
            AppRoutes.MainNavigation: (context) => const MainNavigation(),
          },
        );
      },
    );
  }
}
