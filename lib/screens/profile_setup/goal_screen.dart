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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine screen size category
    final isSmallScreen = screenHeight < 700;
    final isMediumScreen = screenHeight >= 700 && screenHeight < 850;

    // Responsive sizes
    final topPadding = isSmallScreen ? 15.0 : 30.0;
    final logoHeight = isSmallScreen
        ? 80.0
        : isMediumScreen
        ? 100.0
        : 120.0;
    final sectionSpacing = isSmallScreen ? 15.0 : 30.0;
    final headingFontSize = isSmallScreen
        ? 36.0
        : isMediumScreen
        ? 44.0
        : 54.0;

    return Scaffold(
      backgroundColor: context.surfaceColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: topPadding),
                        _buildOutlineTitle(logoHeight),
                        SizedBox(height: sectionSpacing),
                        _buildHeading(headingFontSize),
                        SizedBox(height: sectionSpacing),
                        // Goal Cards - Use Column for deterministic layout in scroll
                        Column(
                          children: goals
                              .map(
                                (goal) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: _buildGoalCard(goal, isSmallScreen),
                                ),
                              )
                              .toList(),
                        ),
                        const Spacer(),
                        _buildNextButton(),
                        SizedBox(height: isSmallScreen ? 30 : 60),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOutlineTitle(double height) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Image.asset(
        'assets/images/logo.png',
        height: height,
        width: height * (280 / 120),
        fit: BoxFit.contain,
        color: isDark ? Colors.white : null,
        colorBlendMode: isDark ? BlendMode.srcIn : null,
        errorBuilder: (context, error, stackTrace) {
          final fontSize = height * 0.4;
          return Stack(
            children: [
              Text(
                'PowerHouse',
                style: TextStyle(
                  fontSize: fontSize,
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
                  fontSize: fontSize,
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

  Widget _buildHeading(double fontSize) {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: 'What is your\n',
              style: TextStyle(
                color: context.primaryText,
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            TextSpan(
              text: 'Goal?',
              style: TextStyle(
                color: context.primaryColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(GoalOption goal, bool isSmall) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = selectedGoal == goal.id;

    final selectedBgColor = context.accentColor.withOpacity(isDark ? 0.2 : 0.1);
    final unselectedBgColor = isDark
        ? context.cardBackground
        : const Color(0xFFF3F3F3);
    final selectedBorderColor = context.accentColor;
    final unselectedBorderColor = Colors.transparent;
    final textColor = context.primaryText;
    final checkboxBorderColor = isDark
        ? Colors.grey.shade600
        : const Color(0xFFD7D7D8);

    final cardPadding = isSmall ? 12.0 : 20.0;
    final iconSize = isSmall ? 36.0 : 48.0;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGoal = goal.id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(cardPadding),
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
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: isSelected
                    ? context.accentColor
                    : goal.color.withOpacity(isDark ? 0.3 : 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                goal.icon,
                color: isSelected
                    ? Colors.white
                    : (isDark ? goal.color.withOpacity(0.9) : goal.color),
                size: iconSize * 0.5,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                goal.title,
                style: TextStyle(
                  color: textColor,
                  fontSize: isSmall ? 14 : 16,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: context.accentColor,
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
                  border: Border.all(color: checkboxBorderColor, width: 2),
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
        progress: 1.0,
        onTap: isEnabled ? _handleNext : null,
        isEnabled: isEnabled,
      ),
    );
  }

  void _handleNext() {
    if (selectedGoal.isEmpty) return;
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final previousData = args ?? {};
    previousData['goal'] = selectedGoal;
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
