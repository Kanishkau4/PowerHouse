import 'package:flutter/material.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:powerhouse/services/auth_service.dart';
import 'package:powerhouse/widgets/animated_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
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
                  // Top Bar
                  _buildTopBar(context),

                  const SizedBox(height: 40),

                  // Title
                  Text(
                    'Create Account',
                    style: TextStyle(
                      color: context.primaryText, // ✅ DARK MODE
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Fill the details to create account',
                    style: TextStyle(
                      color: context.secondaryText, // ✅ DARK MODE
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Name Field
                  _buildTextField(
                    label: 'Name',
                    controller: _nameController,
                    hintText: 'Enter your name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

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

                  // Sign Up Button
                  _buildSignUpButton(),

                  const SizedBox(height: 30),

                  // Sign In Link
                  _buildSignInLink(context),
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
              // ✅ Add color filter for dark mode
              color: context.primaryText,
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
              return 'Please enter a password';
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

        const SizedBox(height: 8),

        // Password Requirements Hint
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 14,
              color: context.secondaryText.withOpacity(0.7), // ✅ DARK MODE
            ),
            const SizedBox(width: 6),
            Text(
              'Password must be at least 6 characters',
              style: TextStyle(
                fontSize: 12,
                color: context.secondaryText.withOpacity(0.7), // ✅ DARK MODE
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleSignUp,
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
                  'Sign Up',
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

  Widget _buildSignInLink(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account? ',
            style: TextStyle(
              color: context.secondaryText, // ✅ DARK MODE
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/signin');
            },
            child: Text(
              'Sign In.',
              style: TextStyle(
                color: context.accentColor, // ✅ DARK MODE (Orange)
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _authService.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          username: _nameController.text.trim(),
        );

        setState(() {
          _isLoading = false;
        });

        if (response.user != null) {
          AnimatedMessage.show(
            context,
            message: 'Verification code sent to your email!',
            backgroundColor: context.primaryColor,
            icon: Icons.check_circle_rounded,
          );

          Navigator.pushNamed(
            context,
            '/verification',
            arguments: _emailController.text.trim(),
          );
        }
      } on AuthException catch (e) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage = 'Sign up failed';

        if (e.message.contains('already registered')) {
          errorMessage = 'This email is already registered. Please sign in.';
        } else if (e.message.contains('Invalid email')) {
          errorMessage = 'Please enter a valid email address.';
        } else if (e.message.contains('Password')) {
          errorMessage = 'Password must be at least 6 characters.';
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
          message: 'Error: ${e.toString()}',
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
}
