import 'package:flutter/material.dart';
import 'package:powerhouse/screens/home/home_screen.dart';
import 'package:powerhouse/screens/workouts/workouts_screen.dart';
import 'package:powerhouse/screens/nutrition/nutrition_screen.dart';
import 'package:powerhouse/screens/challenges/challenges_screen.dart';
import 'package:powerhouse/screens/profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const WorkoutsScreen(),
    const NutritionScreen(),
    const ChallengesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItemWithAsset('assets/icons/home_icon.png', Icons.home, 'Home', 0),
          _buildNavItemWithAsset('assets/icons/workout_icon.png', Icons.fitness_center, 'Workouts', 1),
          _buildCenterNavItem(Icons.add, 2),
          _buildNavItemWithAsset('assets/icons/challenge_icon.png', Icons.emoji_events, 'Challenges', 3),
          _buildNavItemWithAsset('assets/icons/profile_icon.png', Icons.person_outline, 'Profile', 4),
        ],
      ),
    );
  }

  Widget _buildNavItemWithAsset(String assetPath, IconData fallbackIcon, String label, int index) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            assetPath,
            width: 24,
            height: 24,
            color: isSelected ? const Color(0xFF1DAB87) : Colors.grey.shade400,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to Material icon if asset fails to load
              return Icon(
                fallbackIcon,
                color: isSelected ? const Color(0xFF1DAB87) : Colors.grey.shade400,
                size: 24,
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? const Color(0xFF1DAB87) : Colors.grey.shade400,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterNavItem(IconData icon, int index) {
  return Transform.translate(
    offset: const Offset(0, -12), // 👈 Move up by 12 pixels
    child: GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1DAB87), Color(0xFF2DD4A3)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1DAB87).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            'assets/icons/nutrition_icon.png',
            color: Colors.white,
            fit: BoxFit.contain,
          ),
        ),
      ),
    ),
  );
}
}