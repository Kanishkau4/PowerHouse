import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:powerhouse/services/auth_service.dart';
import 'package:powerhouse/widgets/animated_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _authService = AuthService();

  // OTP Controllers (Changed to 6 digits)
  final List<TextEditingController> _otpControllers = List.generate(
    6, // Changed from 4 to 6
    (index) => TextEditingController(),
  );

  // Focus Nodes
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  // Loading state
  bool _isLoading = false;

  // Timer for resend code
  int _resendTimer = 60;
  Timer? _timer;
  bool _canResend = false;

  // Email from arguments
  String _email = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get email from navigation arguments
    _email = ModalRoute.of(context)?.settings.arguments as String? ?? '';
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _canResend = false;
    _resendTimer = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar
                _buildTopBar(context),

                const SizedBox(height: 40),

                // Title
                const Text(
                  'Verification',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle with email
                Text(
                  'We sent a 6-digit code to\n$_email',
                  style: const TextStyle(
                    color: Color(0xFF7E7E7E),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 60),

                // OTP Input Fields
                _buildOTPFields(),

                const SizedBox(height: 40),

                // Continue Button
                _buildContinueButton(),

                const SizedBox(height: 40),

                // Resend Code
                _buildResendCode(),
              ],
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
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.arrow_back, size: 24);
              },
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            _showHelpDialog();
          },
          child: const Text(
            'Need Help?',
            style: TextStyle(
              color: Color(0xFF979797),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOTPFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return Container(
          width: 50, // Smaller to fit 6 digits
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _otpControllers[index].text.isNotEmpty
                  ? const Color(0xFF1DAB87)
                  : const Color(0xFF7E7E7E),
              width: 2,
            ),
            // Adding outline effect with boxShadow
            boxShadow: [
              BoxShadow(
                color: _otpControllers[index].text.isNotEmpty
                    ? const Color(0xFF1DAB87).withOpacity(0.3)
                    : const Color(0xFF7E7E7E).withOpacity(0.1),
                offset: const Offset(0, 0),
                blurRadius: 0,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: TextField(
              controller: _otpControllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                if (value.length == 1 && index < 5) {
                  _focusNodes[index + 1].requestFocus();
                } else if (value.isEmpty && index > 0) {
                  _focusNodes[index - 1].requestFocus();
                }
                setState(() {});
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildContinueButton() {
    final isComplete = _otpControllers.every(
      (controller) => controller.text.isNotEmpty,
    );

    return GestureDetector(
      onTap: isComplete && !_isLoading ? _handleVerification : null,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isComplete
              ? const Color(0xFF1DAB87)
              : const Color(0xFF1DAB87).withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isComplete
              ? [
                  BoxShadow(
                    color: const Color(0xFF1DAB87).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Continue',
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

  Widget _buildResendCode() {
    return Center(
      child: GestureDetector(
        onTap: _canResend ? _resendCode : null,
        child: Text(
          _canResend ? 'Resend Code' : 'Resend Code in ${_resendTimer}s',
          style: TextStyle(
            color: _canResend
                ? const Color(0xFF1DAB87)
                : const Color(0xFF7E7E7E),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: _canResend
                ? TextDecoration.underline
                : TextDecoration.none,
          ),
        ),
      ),
    );
  }

  // ========== HANDLE VERIFICATION (REAL SUPABASE) ==========
  void _handleVerification() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Verify OTP with Supabase
      final response = await _authService.verifyOTP(email: _email, token: otp);

      setState(() {
        _isLoading = false;
      });

      if (response.user != null) {
        // Success!
        AnimatedMessage.show(
          context,
          message: 'Email verified successfully!',
          backgroundColor: const Color(0xFF1DAB87),
          icon: Icons.check_circle_rounded,
        );

        // Navigate to gender screen (profile setup)
        Navigator.pushReplacementNamed(context, '/gender');
      }
    } on AuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      String errorMessage = 'Invalid verification code';

      if (e.message.contains('expired')) {
        errorMessage = 'Code expired. Please request a new one.';
      } else if (e.message.contains('invalid')) {
        errorMessage = 'Invalid code. Please try again.';
      }

      AnimatedMessage.show(
        context,
        message: errorMessage,
        backgroundColor: Colors.red,
        icon: Icons.error_rounded,
      );

      // Clear OTP fields
      for (var controller in _otpControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
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

  // ========== RESEND CODE (REAL SUPABASE) ==========
  void _resendCode() async {
    try {
      await _authService.resendOTP(_email);

      // Clear all fields
      for (var controller in _otpControllers) {
        controller.clear();
      }

      // Focus first field
      _focusNodes[0].requestFocus();

      // Restart timer
      _startTimer();

      AnimatedMessage.show(
        context,
        message: 'New verification code sent!',
        backgroundColor: const Color(0xFF1DAB87),
        icon: Icons.check_circle_rounded,
      );

      setState(() {});
    } catch (e) {
      AnimatedMessage.show(
        context,
        message: 'Failed to resend code: ${e.toString()}',
        backgroundColor: Colors.red,
        icon: Icons.error_rounded,
      );
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Need Help?'),
        content: const Text(
          'If you didn\'t receive the code:\n\n'
          '1. Check your spam/junk folder\n'
          '2. Make sure your email is correct\n'
          '3. Wait for the timer and click "Resend Code"\n\n'
          'Still having issues?\n'
          'Contact us: support@powerhouse.lk',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF1DAB87))),
          ),
        ],
      ),
    );
  }
}
