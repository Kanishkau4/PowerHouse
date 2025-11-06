import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2DD4A3),
              Color(0xFF1DB386),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background decorative circles
            _buildBackgroundCircles(),
            
            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    
                    // App Title
                    const Text(
                      'Power House',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -2,
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Subtitle
                    const Text(
                      'FIND OUT EXACTLY WHAT\nDIET & TRAINING WILL WORK\nSPECIFICALLY FOR YOU',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        height: 1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Next Button
                    _buildNextButton(context),
                    
                    const Spacer(),
                  ],
                ),
              ),
            ),
            
            // Bottom Image
            _buildBottomImage(context),
          ],
        ),
      ),
    );
  }

  // Background Circles Widget
  Widget _buildBackgroundCircles() {
    return Stack(
      children: [
        // Top left circles
        Positioned(
          top: -80,
          left: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
          ),
        ),
        
        // Top right circles
        Positioned(
          top: -50,
          right: -100,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 2,
              ),
            ),
          ),
        ),
        
        // Smaller top right circle
        Positioned(
          top: -20,
          right: -40,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 3,
              ),
            ),
          ),
        ),
        
        // Bottom circles
        Positioned(
          bottom: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Next Button Widget
  Widget _buildNextButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to next screen
        Navigator.pushNamed(context, '/onboard');
      },
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Next',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomImage(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Image.asset(
        'assets/images/fitness_model.png',
        width: MediaQuery.of(context).size.width * 0.8, // Adjust size as needed
        fit: BoxFit.contain,
      ),
    );
  }
  
  
}
