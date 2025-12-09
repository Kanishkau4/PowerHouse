import 'package:flutter/material.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:powerhouse/widgets/circular_progress_button.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  String selectedGoal = ''; // No default selection

  final List<GoalOption> goals = [
    GoalOption(
      id: 'lose_weight',
      title: 'I wanna lose weight',
      icon: Icons.trending_down,
      color: const Color(0xFFFF6B6B),
    ),
    GoalOption(
      id: 'gain_muscle',
      title: 'I wanna get bulks',
      icon: Icons.fitness_center,
      color: const Color(0xFF4ECDC4),
    ),
    GoalOption(
      id: 'gain_endurance',
      title: 'I wanna gain endurance',
      icon: Icons.directions_run,
      color: const Color(0xFFFFE66D),
    ),
    GoalOption(
      id: 'try_app',
      title: 'Just trying out the app! 👍',
      icon: Icons.explore,
      color: const Color(0xFFB19CD9),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceColor, // ✅ DARK MODE
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Outline Title
              _buildOutlineTitle(),

              const SizedBox(height: 20),

              // Heading
              _buildHeading(),

              const SizedBox(height: 40),

              // Goal Cards
              Expanded(
                child: ListView.separated(
                  itemCount: goals.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildGoalCard(goals[index]);
                  },
                ),
              ),

              const SizedBox(height: 40),

              // Next Button
              _buildNextButton(),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineTitle() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Image.asset(
        'assets/images/logo.png',
        height: 120,
        width: 280,
        fit: BoxFit.contain,
        // Optional: Apply color filter for dark mode if logo is dark
        color: isDark ? Colors.white : null,
        colorBlendMode: isDark ? BlendMode.srcIn : null,
        errorBuilder: (context, error, stackTrace) {
          return Stack(
            children: [
              Text(
                'PowerHouse',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -2,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2
                    ..color = isDark ? Colors.white : Colors.black,
                ),
              ),
              Text(
                'PowerHouse',
                style: TextStyle(
                  color: context.surfaceColor,
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -2,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeading() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: 'What is your\n',
              style: TextStyle(
                color: context.primaryText, // ✅ DARK MODE
                fontSize: 48,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            TextSpan(
              text: 'Goal?',
              style: TextStyle(
                color: context.primaryColor, // ✅ DARK MODE
                fontSize: 48,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(GoalOption goal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = selectedGoal == goal.id;

    // Background colors based on theme and selection
    final selectedBgColor = context.accentColor.withOpacity(isDark ? 0.2 : 0.1);
    final unselectedBgColor = isDark
        ? context
              .cardBackground // ✅ DARK MODE
        : const Color(0xFFF3F3F3);

    // Border colors
    final selectedBorderColor = context.accentColor;
    final unselectedBorderColor = Colors.transparent;

    // Text color
    final textColor = context.primaryText; // ✅ DARK MODE

    // Unselected checkbox border
    final checkboxBorderColor = isDark
        ? Colors
              .grey
              .shade600 // ✅ DARK MODE
        : const Color(0xFFD7D7D8);

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGoal = goal.id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? selectedBgColor : unselectedBgColor,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: isSelected ? selectedBorderColor : unselectedBorderColor,
            width: 2,
          ),
          boxShadow: isDark && !isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : (isSelected
                    ? [
                        BoxShadow(
                          color: context.accentColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? context
                          .accentColor // ✅ DARK MODE
                    : goal.color.withOpacity(isDark ? 0.3 : 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                goal.icon,
                color: isSelected
                    ? Colors.white
                    : (isDark
                          ? goal.color.withOpacity(0.9) // Brighter in dark mode
                          : goal.color),
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Title
            Expanded(
              child: Text(
                goal.title,
                style: TextStyle(
                  color: textColor, // ✅ DARK MODE
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),

            // Checkmark
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: context.accentColor, // ✅ DARK MODE
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              )
            else
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: checkboxBorderColor, // ✅ DARK MODE
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    final bool isEnabled = selectedGoal.isNotEmpty;

    return Center(
      child: CircularProgressButton(
        progress: 1.0, // 100% progress (step 5/5)
        onTap: isEnabled ? _handleNext : null,
        isEnabled: isEnabled,
      ),
    );
  }

  void _handleNext() {
    if (selectedGoal.isEmpty) return;

    print('Selected goal: $selectedGoal');

    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final previousData = args ?? {};
    previousData['goal'] = selectedGoal;

    // Navigate to congratulations screen
    Navigator.pushNamed(context, '/congratulations', arguments: previousData);
  }
}

// Goal Option Model
class GoalOption {
  final String id;
  final String title;
  final IconData icon;
  final Color color;

  GoalOption({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });
}
