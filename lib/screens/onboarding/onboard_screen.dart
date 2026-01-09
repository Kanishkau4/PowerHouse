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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine screen size category
    final isSmallScreen = screenHeight < 700;
    final isMediumScreen = screenHeight >= 700 && screenHeight < 850;

    // Responsive font sizes
    final welcomeFontSize = isSmallScreen
        ? 36.0
        : isMediumScreen
        ? 44.0
        : 48.0;
    final orFontSize = isSmallScreen ? 16.0 : 18.0;
    final createAccountFontSize = isSmallScreen ? 18.0 : 20.0;
    final signInFontSize = isSmallScreen ? 13.0 : 14.0;

    // Responsive asset sizes
    final logoHeight = isSmallScreen
        ? 100.0
        : isMediumScreen
        ? 120.0
        : 140.0;

    // Responsive spacing
    final topPadding = isSmallScreen ? 40.0 : 60.0;
    final sectionSpacing = isSmallScreen ? 30.0 : 50.0;
    final itemSpacing = isSmallScreen ? 15.0 : 20.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: topPadding),

                        // Welcome Text
                        Text(
                          'Welcome To',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: welcomeFontSize,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),

                        // App Name / Logo
                        _buildGradientTitle(logoHeight),

                        SizedBox(height: sectionSpacing),

                        // Sign in with Apple Button
                        _buildAppleSignInButton(context, isSmallScreen),

                        SizedBox(height: itemSpacing),

                        // Sign in with Google Button
                        _buildGoogleSignInButton(context, isSmallScreen),

                        SizedBox(height: sectionSpacing),

                        // Or Text
                        Text(
                          'Or',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF979797),
                            fontSize: orFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 20 : 30),

                        // Create New Account Button
                        _buildCreateAccountButton(
                          context,
                          createAccountFontSize,
                        ),

                        const Spacer(), // This will push the content below to the bottom
                        // Already have account? Sign in
                        _buildSignInLink(context, signInFontSize),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Logo Widget
  Widget _buildGradientTitle(double height) {
    return Image.asset(
      'assets/images/logo.png',
      height: height,
      width: height * (280 / 120), // Maintain aspect ratio
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Text(
          'PowerHouse',
          style: TextStyle(
            color: Colors.black,
            fontSize: height * 0.4,
            fontWeight: FontWeight.w700,
            letterSpacing: -2,
          ),
        );
      },
    );
  }

  // Apple Sign-In Button
  Widget _buildAppleSignInButton(BuildContext context, bool isSmall) {
    final buttonHeight = isSmall ? 52.0 : 58.0;
    final fontSize = isSmall ? 16.0 : 18.0;
    final iconSize = isSmall ? 24.0 : 28.0;

    return GestureDetector(
      onTap: () {
        print('Apple Sign-In tapped');
        _showComingSoonDialog(context, 'Apple Sign-In');
      },
      child: Container(
        width: double.infinity,
        height: buttonHeight,
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
              width: iconSize,
              height: iconSize,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.apple, size: iconSize);
              },
            ),
            const SizedBox(width: 12),
            Text(
              'Sign in with Apple',
              style: TextStyle(
                color: Colors.black,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Google Sign-In Button
  Widget _buildGoogleSignInButton(BuildContext context, bool isSmall) {
    final buttonHeight = isSmall ? 52.0 : 58.0;
    final fontSize = isSmall ? 16.0 : 18.0;
    final iconSize = isSmall ? 24.0 : 28.0;

    return GestureDetector(
      onTap: _isProcessingAuth ? null : () => _handleGoogleSignIn(context),
      child: Container(
        width: double.infinity,
        height: buttonHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF979797)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isProcessingAuth)
              SizedBox(
                width: iconSize,
                height: iconSize,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6489FA)),
                ),
              )
            else
              Image.asset(
                'assets/icons/google_logo.png',
                width: iconSize,
                height: iconSize,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.g_mobiledata,
                    size: iconSize,
                    color: const Color(0xFF6489FA),
                  );
                },
              ),
            const SizedBox(width: 12),
            Text(
              _isProcessingAuth ? 'Signing in...' : 'Sign in with Google',
              style: TextStyle(
                color: const Color(0xFF6489FA),
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Create New Account Button
  Widget _buildCreateAccountButton(BuildContext context, double fontSize) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/signup');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Create New Account',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFFFF844B),
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Sign In Link at Bottom
  Widget _buildSignInLink(BuildContext context, double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(color: const Color(0xFF979797), fontSize: fontSize),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/signin');
          },
          child: Text(
            'Sign In',
            style: TextStyle(
              color: const Color(0xFF1DB386),
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
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
