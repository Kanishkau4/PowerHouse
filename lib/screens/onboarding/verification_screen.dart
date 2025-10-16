import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({Key? key}) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  // OTP Controllers
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );

  // Focus Nodes
  final List<FocusNode> _focusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );

  // Loading state
  bool _isLoading = false;

  // Timer for resend code
  int _resendTimer = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
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
    // Get email from navigation arguments
    final String email = ModalRoute.of(context)?.settings.arguments as String? ?? 
                         'abc@gmail.com';

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
                  'We will send code to $email',
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

  // Top Bar with Back Button and Help
  Widget _buildTopBar(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // Back Button with Custom Icon
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 40,
          height: 40,
          child: Image.asset(
            'assets/icons/back_arrow.png', // Replace with your icon filename
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
        ),
      ),
      // Need Help
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

  // OTP Input Fields
  Widget _buildOTPFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        return Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _otpControllers[index].text.isNotEmpty
                  ? const Color(0xFFF15223)
                  : const Color(0xFF7E7E7E),
              width: 1.5,
            ),
          ),
          child: Center(
            child: TextField(
              controller: _otpControllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) {
                if (value.length == 1 && index < 3) {
                  // Move to next field
                  _focusNodes[index + 1].requestFocus();
                } else if (value.isEmpty && index > 0) {
                  // Move to previous field
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

  // Continue Button
  Widget _buildContinueButton() {
    final isComplete = _otpControllers.every((controller) => 
      controller.text.isNotEmpty
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

  // Resend Code
  Widget _buildResendCode() {
    return Center(
      child: GestureDetector(
        onTap: _canResend ? _resendCode : null,
        child: Text(
          _canResend 
              ? 'Resend Code' 
              : 'Resend Code in ${_resendTimer}s',
          style: TextStyle(
            color: _canResend 
                ? const Color(0xFFF15223) 
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

  // Handle Verification
  void _handleVerification() {
    final otp = _otpControllers.map((c) => c.text).join();
    
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });

      // Check if OTP is correct (for demo, accept any 4 digits)
      if (otp.length == 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification successful!'),
            backgroundColor: Color(0xFF1DAB87),
          ),
        );

        // Navigate to gender screen (first profile setup)
        Navigator.pushNamed(context, '/gender');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid verification code!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    // TODO: Implement actual OTP verification
    print('Verifying OTP: $otp');
  }

  // Resend Code
  void _resendCode() {
    // Clear all fields
    for (var controller in _otpControllers) {
      controller.clear();
    }
    
    // Focus first field
    _focusNodes[0].requestFocus();
    
    // Restart timer
    _startTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification code sent!'),
        backgroundColor: Color(0xFF1DAB87),
      ),
    );

    setState(() {});

    // TODO: Implement actual resend OTP API call
    print('Resending OTP...');
  }

  // Help Dialog
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Need Help?'),
        content: const Text(
          'If you didn\'t receive the code:\n\n'
          '1. Check your spam folder\n'
          '2. Make sure your email is correct\n'
          '3. Click "Resend Code" after the timer\n\n'
          'Contact us: support@powerhouse.lk',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF1DAB87)),
            ),
          ),
        ],
      ),
    );
  }
}