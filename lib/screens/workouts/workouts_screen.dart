import 'package:flutter/material.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  // Selected category
  int selectedCategoryIndex = 0;

  // Categories
  final List<String> categories = [
    'Home Workouts',
    'Yoga & Mobility',
    'Strength Training',
    'For Women',
    'Cardio',
  ];

  // Sample workout data
  final Map<String, List<WorkoutProgram>> workoutsByCategory = {
    'Home Workouts': [
      WorkoutProgram(
        title: '30-Day Weight Loss Challenge',
        duration: '30 min',
        calories: '300 kcal',
        level: 'Beginner',
        imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
        color: const Color(0xFF1DAB87),
      ),
      WorkoutProgram(
        title: 'Morning Mobility Routine',
        duration: '25 min',
        calories: '250 kcal',
        level: 'Intermediate',
        imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800',
        color: const Color(0xFFFF844B),
      ),
      WorkoutProgram(
        title: 'Core Strength Builder',
        duration: '20 min',
        calories: '200 kcal',
        level: 'Advanced',
        imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800',
        color: const Color(0xFF6C63FF),
      ),
    ],
    'Yoga & Mobility': [
      WorkoutProgram(
        title: 'Morning Yoga Flow',
        duration: '30 min',
        calories: '150 kcal',
        level: 'Beginner',
        imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800',
        color: const Color(0xFFB19CD9),
      ),
      WorkoutProgram(
        title: 'Flexibility & Stretch',
        duration: '20 min',
        calories: '100 kcal',
        level: 'All Levels',
        imageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=800',
        color: const Color(0xFF95E1D3),
      ),
    ],
    'Strength Training': [
      WorkoutProgram(
        title: 'Full Body Strength',
        duration: '45 min',
        calories: '400 kcal',
        level: 'Intermediate',
        imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
        color: const Color(0xFF1DAB87),
      ),
    ],
    'For Women': [
      WorkoutProgram(
        title: 'Womens Fitness Program',
        duration: '35 min',
        calories: '280 kcal',
        level: 'Beginner',
        imageUrl: 'https://images.unsplash.com/photo-1518459031867-a89b944bffe4?w=800',
        color: const Color(0xFFFF9ECD),
      ),
    ],
    'Cardio': [
      WorkoutProgram(
        title: 'HIIT Cardio Blast',
        duration: '25 min',
        calories: '350 kcal',
        level: 'Advanced',
        imageUrl: 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800',
        color: const Color(0xFFFF6B6B),
      ),
    ],
  };

  List<WorkoutProgram> get currentWorkouts {
    final category = categories[selectedCategoryIndex];
    return workoutsByCategory[category] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Search Bar
            _buildSearchBar(),
            
            const SizedBox(height: 20),
            
            // Category Tabs
            _buildCategoryTabs(),
            
            const SizedBox(height: 20),
            
            // Section Title with Underline
            _buildSectionTitle(),
            
            const SizedBox(height: 16),
            
            // Workout List
            Expanded(
              child: _buildWorkoutList(),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Workouts',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          GestureDetector(
            onTap: () => _onProfileTap(),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF1DAB87),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                'assets/images/profile_male.png', // Path to your image
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to icon if image fails to load
                  return const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  );
                },
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SEARCH BAR ====================
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: const Color(0x99D9D9D9),
          borderRadius: BorderRadius.circular(25),
        ),
        child: TextField(
          onChanged: (value) => _onSearch(value),
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(
              color: Colors.black.withOpacity(0.5),
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.black.withOpacity(0.5),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }

  // ==================== CATEGORY TABS ====================
  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 45,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = selectedCategoryIndex == index;
          return _buildCategoryTab(
            categories[index],
            isSelected,
            () {
              setState(() {
                selectedCategoryIndex = index;
              });
            },
          );
        },
      ),
    );
  }

  // ==================== CATEGORY TAB ====================
  Widget _buildCategoryTab(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xE01DAB87)
              : const Color(0xD3D7D7D7),
          borderRadius: BorderRadius.circular(25),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0x4C1DAB87),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                    spreadRadius: 5,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  // ==================== SECTION TITLE ====================
  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categories[selectedCategoryIndex],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 72,
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFF1DAB87),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== WORKOUT LIST ====================
  Widget _buildWorkoutList() {
    if (currentWorkouts.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: currentWorkouts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildWorkoutCard(currentWorkouts[index]);
      },
    );
  }

  // ==================== WORKOUT CARD ====================
  Widget _buildWorkoutCard(WorkoutProgram workout) {
    return GestureDetector(
      onTap: () => _onWorkoutTap(workout),
      child: Container(
        height: 151,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: workout.color.withOpacity(0.3),
                child: Image.network(
                  workout.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: workout.color.withOpacity(0.5),
                      child: Icon(
                        Icons.fitness_center,
                        size: 60,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    workout.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '⏱️ ${workout.duration} | 🔥 ${workout.calories} | 💪 ${workout.level}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Play Button
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: workout.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: workout.color.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No workouts available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different category',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HANDLERS ====================
  
  void _onProfileTap() {
    print('Profile tapped');
    // Navigate to profile
  }

  void _onSearch(String query) {
    print('Search: $query');
    // Implement search functionality
  }

  void _onWorkoutTap(WorkoutProgram workout) {
    print('Workout tapped: ${workout.title}');
    // Navigate to workout detail
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => WorkoutDetailScreen(workout: workout),
    //   ),
    // );
  }
}

// ==================== DATA MODEL ====================

class WorkoutProgram {
  final String title;
  final String duration;
  final String calories;
  final String level;
  final String imageUrl;
  final Color color;

  WorkoutProgram({
    required this.title,
    required this.duration,
    required this.calories,
    required this.level,
    required this.imageUrl,
    required this.color,
  });
}