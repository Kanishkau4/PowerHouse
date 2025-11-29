import 'package:flutter/material.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:powerhouse/screens/workouts/workout_detail_screen.dart';
import 'package:powerhouse/services/workout_service.dart';
import 'package:powerhouse/services/user_service.dart';
import 'package:powerhouse/models/workout_model.dart';
import 'package:powerhouse/widgets/animated_message.dart';
import 'package:powerhouse/widgets/skeleton_widgets.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final _workoutService = WorkoutService();
  final _userService = UserService();

  // Selected category
  int selectedCategoryIndex = 0;

  // Categories (matching database)
  final List<String> categories = [
    'All',
    'Home Workout',
    'Gym',
    'Cardio',
    'Strength',
    'Yoga',
  ];

  // Data
  List<WorkoutModel> allWorkouts = [];
  List<WorkoutModel> filteredWorkouts = [];
  String? profilePictureUrl;

  // Loading & search
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load user profile for picture
      final profile = await _userService.getCurrentUserProfile();
      profilePictureUrl = profile?.profilePictureUrl;

      // Load all workouts
      allWorkouts = await _workoutService.getAllWorkouts();
      _filterWorkouts();
    } catch (e) {
      print('Error loading workouts: $e');
      AnimatedMessage.show(
        context,
        message: 'Error loading workouts: ${e.toString()}',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterWorkouts() {
    setState(() {
      // Filter by category
      if (selectedCategoryIndex == 0) {
        // All
        filteredWorkouts = allWorkouts;
      } else {
        final category = categories[selectedCategoryIndex];
        filteredWorkouts = allWorkouts
            .where((w) => w.category?.toLowerCase() == category.toLowerCase())
            .toList();
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        filteredWorkouts = filteredWorkouts.where((w) {
          return w.workoutName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              (w.description?.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ??
                  false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceColor,
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

            // Section Title
            _buildSectionTitle(),

            const SizedBox(height: 16),

            // Workout List
            Expanded(
              child: _isLoading
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 6,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return const SkeletonCard(height: 151);
                        },
                      ),
                    )
                  : _buildWorkoutList(),
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
          Text(
            'Workouts',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: context.primaryText,
            ),
          ),
          GestureDetector(
            onTap: () => _onProfileTap(),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1DAB87), width: 2),
              ),
              child: ClipOval(
                child: profilePictureUrl != null
                    ? Image.network(
                        profilePictureUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildProfileFallback();
                        },
                      )
                    : _buildProfileFallback(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileFallback() {
    return Image.asset(
      'assets/images/profile_male.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFF1DAB87),
          child: const Icon(Icons.person, color: Colors.white, size: 30),
        );
      },
    );
  }

  // ==================== SEARCH BAR ====================
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: context.inputBackground, // ✅ theme-aware
          borderRadius: BorderRadius.circular(25),
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
            _filterWorkouts();
          },
          style: TextStyle(color: context.primaryText), // ✅ text color
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(
              color: context.secondaryText, // ✅
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: context.secondaryText, // ✅
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
          return _buildCategoryTab(categories[index], isSelected, () {
            setState(() {
              selectedCategoryIndex = index;
            });
            _filterWorkouts();
          });
        },
      ),
    );
  }

  Widget _buildCategoryTab(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? context.primaryColor
              : context.cardBackground.withOpacity(
                  0.5,
                ), // ✅ adaptive unselected
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? context.primaryColor
                : context.dividerColor, // ✅ border adapts
            width: isSelected ? 0 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
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
              color: isSelected ? Colors.white : context.primaryText, // ✅
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
            selectedCategoryIndex == 0
                ? 'All Workouts'
                : categories[selectedCategoryIndex],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: context.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 72,
            height: 3,
            decoration: BoxDecoration(
              color: context.primaryColor, // ✅
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== WORKOUT LIST ====================
  Widget _buildWorkoutList() {
    if (filteredWorkouts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF1DAB87),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: filteredWorkouts.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildWorkoutCard(filteredWorkouts[index]);
        },
      ),
    );
  }

  // ==================== WORKOUT CARD ====================
  Widget _buildWorkoutCard(WorkoutModel workout) {
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
                color: workout.difficultyColor.withOpacity(0.3),
                child: workout.imageUrl != null
                    ? Image.network(
                        workout.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildWorkoutFallback(workout);
                        },
                      )
                    : _buildWorkoutFallback(workout),
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
                    workout.workoutName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '⏱️ ${workout.estimatedDuration ?? 30} min | 🔥 ${workout.estimatedCaloriesBurned ?? 200} kcal | 💪 ${workout.difficulty ?? 'All Levels'}',
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
                  color: workout.difficultyColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: workout.difficultyColor.withOpacity(0.5),
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

  Widget _buildWorkoutFallback(WorkoutModel workout) {
    return Container(
      color: workout.difficultyColor.withOpacity(0.5),
      child: Icon(Icons.fitness_center, size: 60, color: Colors.white),
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
            color: context.dividerColor, // ✅ subtle icon
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No workouts found for "$_searchQuery"'
                : 'No workouts available',
            style: TextStyle(
              fontSize: 18,
              color: context.primaryText, // ✅ main text
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different category',
            style: TextStyle(
              fontSize: 14,
              color: context.secondaryText, // ✅ secondary text
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HANDLERS ====================

  void _onProfileTap() {
    print('Profile tapped');
  }

  void _onWorkoutTap(WorkoutModel workout) async {
    print('Workout tapped: ${workout.workoutName}');
    print('Workout ID: ${workout.workoutId}');

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF1DAB87)),
      ),
    );

    try {
      // Fetch workout with exercises
      print('Fetching workout with exercises...');
      final fullWorkout = await _workoutService.getWorkoutWithExercises(
        workout.workoutId,
      );

      Navigator.pop(context); // Close loading

      if (fullWorkout != null) {
        print(
          'Successfully fetched workout with ${fullWorkout.exercises?.length ?? 0} exercises',
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutDetailScreen(workout: fullWorkout),
          ),
        );
      } else {
        print('Failed to fetch workout details');
        AnimatedMessage.show(
          context,
          message: 'Failed to load workout details. Please try again.',
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
      }
    } catch (e, stackTrace) {
      Navigator.pop(context); // Close loading
      print('Error fetching workout: $e');
      print('Stack trace: $stackTrace');
      AnimatedMessage.show(
        context,
        message: 'Error loading workout: ${e.toString()}',
        backgroundColor: Colors.red,
        icon: Icons.error,
      );
    }
  }
}
