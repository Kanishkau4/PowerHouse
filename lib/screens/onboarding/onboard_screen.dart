import 'package:flutter/material.dart';
import 'package:powerhouse/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final _authService = AuthService();
  StreamSubscription<AuthState>? _authSubscription;
  bool _isProcessingAuth = false;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  // Setup auth state listener for OAuth callbacks
  void _setupAuthListener() {
    _authSubscription = _authService.authStateChanges.listen((authState) {
      if (!mounted || _isProcessingAuth) return;

      final session = authState.session;
      if (session != null && authState.event == AuthChangeEvent.signedIn) {
        _handleAuthSuccess();
      }
    });
  }

  // Handle successful authentication (OAuth callback)
  Future<void> _handleAuthSuccess() async {
    if (_isProcessingAuth) return;

    setState(() {
      _isProcessingAuth = true;
    });

    try {
      // Check if profile exists and is complete
      final hasProfile = await _authService.doesProfileExist();

      if (!mounted) return;

      if (!hasProfile) {
        // No profile, navigate to profile setup
        Navigator.pushReplacementNamed(context, '/gender');
      } else {
        // Profile exists, check if it's complete
        final profile = await _authService.getUserProfile();

        if (!mounted) return;

        if (profile != null &&
            profile['height'] != null &&
            profile['current_weight'] != null &&
            profile['fitness_goal'] != null) {
          // Profile is complete, navigate to home
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // Profile is incomplete, navigate to profile setup
          Navigator.pushReplacementNamed(context, '/gender');
        }
      }
    } catch (e) {
      print('Error handling auth success: $e');
      if (mounted) {
        setState(() {
          _isProcessingAuth = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            children: [
              const SizedBox(height: 80),

              // Welcome Text
              const Text(
                'Welcome To',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),

              // App Name with Gradient
              _buildGradientTitle(),

              const SizedBox(height: 60),

              // Sign in with Apple Button
              _buildAppleSignInButton(context),

              const SizedBox(height: 20),

              // Sign in with Google Button
              _buildGoogleSignInButton(context),

              const SizedBox(height: 50),

              // Or Text
              const Text(
                'Or',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF979797),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 30),

              // Create New Account Button
              _buildCreateAccountButton(context),

              const Spacer(),

              // Already have account? Sign in
              _buildSignInLink(context),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Gradient Title Widget
  Widget _buildGradientTitle() {
    return Stack(
      children: [
        // Outline text
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
        // Solid text
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

  // Apple Sign-In Button
  Widget _buildAppleSignInButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement Apple Sign-In
        print('Apple Sign-In tapped');
        _showComingSoonDialog(context, 'Apple Sign-In');
      },
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF979797)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/apple_logo.png',
              width: 28,
              height: 28,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.apple, size: 28);
              },
            ),
            const SizedBox(width: 12),
            const Text(
              'Sign in with Apple',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Google Sign-In Button
  Widget _buildGoogleSignInButton(BuildContext context) {
    return GestureDetector(
      onTap: _isProcessingAuth ? null : () => _handleGoogleSignIn(context),
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF979797)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isProcessingAuth)
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6489FA)),
                ),
              )
            else
              Image.asset(
                'assets/icons/google_logo.png',
                width: 28,
                height: 28,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.g_mobiledata,
                    size: 28,
                    color: Color(0xFF6489FA),
                  );
                },
              ),
            const SizedBox(width: 12),
            Text(
              _isProcessingAuth ? 'Signing in...' : 'Sign in with Google',
              style: const TextStyle(
                color: Color(0xFF6489FA),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Create New Account Button
  Widget _buildCreateAccountButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to Sign Up Screen
        Navigator.pushNamed(context, '/signup');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: const Text(
          'Create New Account',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFFF844B),
            fontSize: 22,
            fontWeight: FontWeight.w600,
            // decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  // Sign In Link at Bottom
  Widget _buildSignInLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(color: Color(0xFF979797), fontSize: 14),
        ),
        GestureDetector(
          onTap: () {
            // Navigate to Sign In Screen
            Navigator.pushNamed(context, '/signin');
          },
          child: const Text(
            'Sign In',
            style: TextStyle(
              color: Color(0xFF1DB386),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              //decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  // Coming Soon Dialog (Temporary)
  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text('This feature will be implemented soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Handle Google Sign-In
  void _handleGoogleSignIn(BuildContext context) async {
    if (_isProcessingAuth) return;

    setState(() {
      _isProcessingAuth = true;
    });

    try {
      final success = await _authService.signInWithGoogle();

      if (!success && mounted) {
        setState(() {
          _isProcessingAuth = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google sign in failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // If success, the auth state listener will handle navigation
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessingAuth = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
