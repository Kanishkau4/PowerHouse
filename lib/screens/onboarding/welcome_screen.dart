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
      description:
          'Discover personalized nutrition strategies designed specifically for your body and goals',
      lottieAsset: 'assets/animations/diet.json',
    ),
    OnboardingData(
      title: 'Stay Organized\nWith Your Training',
      description:
          'Track your workouts and understand what training methods work best for you',
      lottieAsset: 'assets/animations/workout.json',
    ),
    OnboardingData(
      title: 'Get Results That\nWork For You',
      description:
          'Take control of your fitness journey with personalized insights and recommendations',
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
    // Get screen dimensions for responsive sizing
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate responsive sizes based on screen height
    final isSmallScreen = screenHeight < 700;
    final isMediumScreen = screenHeight >= 700 && screenHeight < 850;

    // Responsive animation size
    final animationContainerHeight = isSmallScreen
        ? screenHeight * 0.30
        : isMediumScreen
        ? screenHeight * 0.35
        : screenHeight * 0.40;

    final circleSize = animationContainerHeight * 0.85;

    // Responsive font sizes
    final titleFontSize = isSmallScreen
        ? 22.0
        : isMediumScreen
        ? 26.0
        : 28.0;
    final descFontSize = isSmallScreen
        ? 13.0
        : isMediumScreen
        ? 14.0
        : 15.0;

    // Responsive spacing
    final topSpacing = isSmallScreen ? 16.0 : 40.0;
    final middleSpacing = isSmallScreen ? 16.0 : 30.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
      child: Column(
        children: [
          SizedBox(height: topSpacing),

          // Lottie Animation with Background Circles - FLEXIBLE
          Flexible(
            flex: 5,
            child: SizedBox(
              height: animationContainerHeight,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Large background circle
                  Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2DD4A3).withOpacity(0.1),
                    ),
                  ),

                  // Medium circle
                  Container(
                    width: circleSize * 0.8,
                    height: circleSize * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2DD4A3).withOpacity(0.15),
                    ),
                  ),

                  // Small inner circle
                  Container(
                    width: circleSize * 0.6,
                    height: circleSize * 0.6,
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
                          width: circleSize,
                          height: circleSize,
                          fit: BoxFit.contain,
                        );
                      }
                      // Fallback icon if Lottie file doesn't exist
                      return Icon(
                        _getIconForPage(_currentPage),
                        size: circleSize * 0.4,
                        color: const Color(0xFF2DD4A3),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: middleSpacing),

          // Page Indicator
          _buildPageIndicator(),

          SizedBox(height: isSmallScreen ? 16 : 24),

          // Title and Description - FLEXIBLE with minimum space
          Flexible(
            flex: 3,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 12 : 16),

                  // Description
                  Text(
                    data.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: descFontSize,
                      color: Colors.black.withOpacity(0.6),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
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
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        isSmallScreen ? 12 : 20,
        24,
        isSmallScreen ? 16 : 24,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Skip Button
          if (_currentPage < _pages.length - 1)
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/onboard');
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
                Navigator.pushReplacementNamed(context, '/onboard');
              }
            },
            child: Container(
              width: isSmallScreen ? 120 : 140,
              height: isSmallScreen ? 48 : 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2DD4A3), Color(0xFF1DB386)],
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
