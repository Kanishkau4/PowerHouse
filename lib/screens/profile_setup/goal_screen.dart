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
      backgroundColor: context.surfaceColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Outline Title
              _buildOutlineTitle(),

              const SizedBox(height: 60),

              // Heading
              _buildHeading(),

              const SizedBox(height: 60),

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
    return Center(
      child: Stack(
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
                ..color = const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const Text(
            'PowerHouse',
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w700,
              letterSpacing: -2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeading() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'What is your\n',
              style: TextStyle(
                color: Colors.black,
                fontSize: 48,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            TextSpan(
              text: 'Goal?',
              style: TextStyle(
                color: Color(0xFF1DAB87),
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
    final isSelected = selectedGoal == goal.id;

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
          color: isSelected
              ? const Color(0xFFF97316).withOpacity(0.1)
              : const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: isSelected ? const Color(0xFFF97316) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFF97316)
                    : goal.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                goal.icon,
                color: isSelected ? Colors.white : goal.color,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Title
            Expanded(
              child: Text(
                goal.title,
                style: TextStyle(
                  color: const Color(0xFF101114),
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
                decoration: const BoxDecoration(
                  color: Color(0xFFF97316),
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
                  border: Border.all(color: const Color(0xFFD7D7D8), width: 2),
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
