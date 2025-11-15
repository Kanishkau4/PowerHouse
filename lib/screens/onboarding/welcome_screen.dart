import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Find Your Perfect\nDiet Plan',
      description: 'Discover personalized nutrition strategies designed specifically for your body and goals',
      lottieAsset: 'assets/animations/diet.json',
    ),
    OnboardingData(
      title: 'Stay Organized\nWith Your Training',
      description: 'Track your workouts and understand what training methods work best for you',
      lottieAsset: 'assets/animations/workout.json',
    ),
    OnboardingData(
      title: 'Get Results That\nWork For You',
      description: 'Take control of your fitness journey with personalized insights and recommendations',
      lottieAsset: 'assets/animations/results.json',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<bool> _checkAssetExists(String path) async {
    try {
      await DefaultAssetBundle.of(context).load(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  IconData _getIconForPage(int page) {
    switch (page) {
      case 0:
        return Icons.restaurant_menu;
      case 1:
        return Icons.fitness_center;
      case 2:
        return Icons.emoji_events;
      default:
        return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // Lottie Animation with Background Circles
          SizedBox(
            height: 360,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Large background circle
                Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2DD4A3).withOpacity(0.1),
                  ),
                ),
                
                // Medium circle
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2DD4A3).withOpacity(0.15),
                  ),
                ),
                
                // Small inner circle
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1DB386).withOpacity(0.1),
                  ),
                ),
                
                // Lottie Animation on top
                FutureBuilder(
                  future: _checkAssetExists(data.lottieAsset),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(
                        color: Color(0xFF2DD4A3),
                      );
                    }
                    if (snapshot.hasData && snapshot.data == true) {
                      return Lottie.asset(
                        data.lottieAsset,
                        width: 320,
                        height: 320,
                        fit: BoxFit.contain,
                      );
                    }
                    // Fallback icon if Lottie file doesn't exist
                    return Icon(
                      _getIconForPage(_currentPage),
                      size: 140,
                      color: const Color(0xFF2DD4A3),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Page Indicator
          _buildPageIndicator(),
          
          const SizedBox(height: 30),
          
          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.black.withOpacity(0.6),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Colors.black
                : Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Skip Button
          if (_currentPage < _pages.length - 1)
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text(
                'SKIP',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                  letterSpacing: 1,
                ),
              ),
            )
          else
            const SizedBox(width: 60),
          
          // Next/Start Button
          GestureDetector(
            onTap: () {
              if (_currentPage < _pages.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
            child: Container(
              width: 140,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2DD4A3),
                    Color(0xFF1DB386),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2DD4A3).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _currentPage < _pages.length - 1 ? 'NEXT' : 'START',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String lottieAsset;

  OnboardingData({
    required this.title,
    required this.description,
    required this.lottieAsset,
  });
}