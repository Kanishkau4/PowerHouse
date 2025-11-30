import 'package:flutter/material.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:powerhouse/services/auth_service.dart';
import 'package:powerhouse/widgets/animated_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceColor, // ✅ DARK MODE
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 40),

                  // Title
                  Text(
                    'Sign In',
                    style: TextStyle(
                      color: context.primaryText, // ✅ DARK MODE
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Fill the details to sign in account',
                    style: TextStyle(
                      color: context.secondaryText, // ✅ DARK MODE
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Email Field
                  _buildTextField(
                    label: 'Email',
                    controller: _emailController,
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Password Field
                  _buildPasswordField(),

                  const SizedBox(height: 40),

                  // Sign In Button
                  _buildSignInButton(),

                  const SizedBox(height: 30),

                  // Forgot Password Link
                  _buildForgotPasswordLink(),

                  const SizedBox(height: 100),

                  // Create Account Link
                  _buildCreateAccountLink(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button with Custom Icon
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Image.asset(
              'assets/icons/back_arrow.png',
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              // ✅ Removed color filter to show actual PNG color
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.arrow_back,
                  size: 24,
                  color: context.primaryText, // ✅ DARK MODE
                );
              },
            ),
          ),
        ),

        // Need Help
        GestureDetector(
          onTap: () {
            _showHelpDialog();
          },
          child: Text(
            'Need Help?',
            style: TextStyle(
              color: context.secondaryText, // ✅ DARK MODE
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: context.primaryText, // ✅ DARK MODE
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            color: context.primaryText, // ✅ DARK MODE
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: context.secondaryText.withOpacity(0.6), // ✅ DARK MODE
              fontSize: 15,
            ),
            filled: true,
            fillColor: context.inputBackground, // ✅ DARK MODE
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: context.borderColor, // ✅ DARK MODE
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: context.borderColor, // ✅ DARK MODE
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: context.primaryColor, // ✅ DARK MODE
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: TextStyle(
            color: context.primaryText, // ✅ DARK MODE
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          style: TextStyle(
            color: context.primaryText, // ✅ DARK MODE
            fontSize: 15,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Enter your password',
            hintStyle: TextStyle(
              color: context.secondaryText.withOpacity(0.6), // ✅ DARK MODE
              fontSize: 15,
            ),
            filled: true,
            fillColor: context.inputBackground, // ✅ DARK MODE
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: context.secondaryText, // ✅ DARK MODE
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: context.borderColor, // ✅ DARK MODE
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: context.borderColor, // ✅ DARK MODE
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: context.primaryColor, // ✅ DARK MODE
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleSignIn,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: context.primaryColor, // ✅ DARK MODE
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.primaryColor.withOpacity(0.3), // ✅ DARK MODE
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Sign In',
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

  Widget _buildForgotPasswordLink() {
    return Center(
      child: GestureDetector(
        onTap: () {
          _showForgotPasswordDialog();
        },
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: context.accentColor, // ✅ DARK MODE (Orange)
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCreateAccountLink(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: TextStyle(
              color: context.secondaryText, // ✅ DARK MODE
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/signup');
            },
            child: Text(
              'Create Account',
              style: TextStyle(
                color: context.primaryColor, // ✅ DARK MODE
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _authService.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        setState(() {
          _isLoading = false;
        });

        if (response.user != null) {
          final hasProfile = await _authService.doesProfileExist();

          if (!hasProfile) {
            AnimatedMessage.show(
              context,
              message: 'Please complete your profile setup',
              backgroundColor: context.accentColor,
              icon: Icons.warning_rounded,
            );
            Navigator.pushReplacementNamed(context, '/gender');
          } else {
            final profile = await _authService.getUserProfile();

            if (profile != null &&
                profile['height'] != null &&
                profile['current_weight'] != null &&
                profile['fitness_goal'] != null) {
              AnimatedMessage.show(
                context,
                message: 'Welcome back!',
                backgroundColor: context.primaryColor,
                icon: Icons.check_circle_rounded,
              );

              Future.delayed(const Duration(milliseconds: 500), () {
                Navigator.pushReplacementNamed(context, '/home');
              });
            } else {
              AnimatedMessage.show(
                context,
                message: 'Please complete your profile setup',
                backgroundColor: context.accentColor,
                icon: Icons.warning_rounded,
              );
              Navigator.pushReplacementNamed(context, '/gender');
            }
          }
        }
      } on AuthException catch (e) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage = 'Sign in failed';

        if (e.message.contains('Invalid login credentials')) {
          errorMessage = 'Invalid email or password';
        } else if (e.message.contains('Email not confirmed')) {
          errorMessage = 'Please verify your email first';
        } else {
          errorMessage = e.message;
        }

        AnimatedMessage.show(
          context,
          message: errorMessage,
          backgroundColor: Colors.red,
          icon: Icons.error_rounded,
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        AnimatedMessage.show(
          context,
          message: 'Something went wrong. Please try again',
          backgroundColor: Colors.red,
          icon: Icons.error_rounded,
        );
      }
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.cardBackground, // ✅ DARK MODE
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Need Help?',
          style: TextStyle(
            color: context.primaryText, // ✅ DARK MODE
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Contact us at:\nsupport@powerhouse.lk\n\nOr call: +94 77 123 4567',
          style: TextStyle(
            color: context.secondaryText, // ✅ DARK MODE
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'OK',
              style: TextStyle(
                color: context.primaryColor, // ✅ DARK MODE
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.cardBackground, // ✅ DARK MODE
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Forgot Password?',
          style: TextStyle(
            color: context.primaryText, // ✅ DARK MODE
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address and we will send you a reset link.',
              style: TextStyle(
                color: context.secondaryText, // ✅ DARK MODE
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: context.primaryText, // ✅ DARK MODE
              ),
              decoration: InputDecoration(
                hintText: 'Email address',
                hintStyle: TextStyle(
                  color: context.secondaryText.withOpacity(0.6), // ✅ DARK MODE
                ),
                filled: true,
                fillColor: context.inputBackground, // ✅ DARK MODE
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: context.borderColor, // ✅ DARK MODE
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: context.borderColor, // ✅ DARK MODE
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: context.primaryColor, // ✅ DARK MODE
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: context.secondaryText, // ✅ DARK MODE
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _authService.resetPassword(emailController.text.trim());
                Navigator.pop(dialogContext);

                AnimatedMessage.show(
                  context,
                  message: 'Password reset link sent to your email!',
                  backgroundColor: context.primaryColor,
                  icon: Icons.check_circle_rounded,
                );
              } catch (e) {
                Navigator.pop(dialogContext);

                AnimatedMessage.show(
                  context,
                  message: 'Failed to send reset link',
                  backgroundColor: Colors.red,
                  icon: Icons.error_rounded,
                );
              }
            },
            child: Text(
              'Send',
              style: TextStyle(
                color: context.primaryColor, // ✅ DARK MODE
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
