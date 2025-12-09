import 'package:flutter/material.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:powerhouse/widgets/circular_progress_button.dart';

class AgeScreen extends StatefulWidget {
  const AgeScreen({super.key});

  @override
  State<AgeScreen> createState() => _AgeScreenState();
}

class _AgeScreenState extends State<AgeScreen> {
  int selectedAge = 18; // Default age
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // Initialize scroll controller with default age
    _scrollController = FixedExtentScrollController(
      initialItem: selectedAge - 13, // Offset for starting age 13
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceColor, // ✅ DARK MODE
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Title with outline effect
              _buildOutlineTitle(),

              const SizedBox(height: 15),

              // Main heading
              _buildHeading(),

              const SizedBox(height: 30),

              // Age Picker
              Expanded(child: _buildAgePicker()),

              const SizedBox(height: 40),

              // Next button
              _buildNextButton(),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  // Outline Title Widget
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

  // Heading Widget
  Widget _buildHeading() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'And\nYour ',
            style: TextStyle(
              color: context.primaryText, // ✅ DARK MODE
              fontSize: 48,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          TextSpan(
            text: 'age?',
            style: TextStyle(
              color: context.primaryColor, // ✅ DARK MODE
              fontSize: 48,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  // Age Picker Widget
  Widget _buildAgePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colors for non-selected items based on theme
    final nearbyTextColor = isDark
        ? Colors
              .grey
              .shade500 // ✅ DARK MODE
        : const Color(0xFF9EA0A5);

    final farTextColor = isDark
        ? Colors
              .grey
              .shade700 // ✅ DARK MODE
        : const Color(0xFFD7D7D8);

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Selection highlight container
          Container(
            height: 120,
            width: 220,
            decoration: BoxDecoration(
              color: context.accentColor, // ✅ DARK MODE (Orange)
              borderRadius: BorderRadius.circular(48),
              border: Border.all(
                color: isDark
                    ? context.accentColor.withOpacity(0.5) // ✅ DARK MODE
                    : const Color(0xFFFFEDD5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.accentColor.withOpacity(0.25), // ✅ DARK MODE
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),

          // Age wheel
          SizedBox(
            height: 400,
            child: ListWheelScrollView.useDelegate(
              controller: _scrollController,
              itemExtent: 100,
              diameterRatio: 1.5,
              perspective: 0.001,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedAge = index + 13; // Starting from age 13
                });
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  final age = index + 13;
                  final isSelected = age == selectedAge;

                  // Determine the distance from selected item
                  final difference = (age - selectedAge).abs();

                  // Calculate opacity and size based on distance
                  double fontSize;
                  Color textColor;
                  FontWeight fontWeight;

                  if (isSelected) {
                    fontSize = 80;
                    textColor = Colors.white; // Always white on orange
                    fontWeight = FontWeight.w800;
                  } else if (difference == 1) {
                    fontSize = 60;
                    textColor = nearbyTextColor; // ✅ DARK MODE
                    fontWeight = FontWeight.w700;
                  } else {
                    fontSize = 30;
                    textColor = farTextColor; // ✅ DARK MODE
                    fontWeight = FontWeight.w700;
                  }

                  return Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: textColor,
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                        letterSpacing: fontSize > 60 ? -2.4 : -1.08,
                      ),
                      child: Text('$age'),
                    ),
                  );
                },
                childCount: 88, // Ages from 13 to 100
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Next Button Widget
  Widget _buildNextButton() {
    return Center(
      child: CircularProgressButton(
        progress: 0.4, // Step 2/5 = 40%
        onTap: _handleNext,
        isEnabled: true,
      ),
    );
  }

  // Handle Next Button
  void _handleNext() {
    print('Selected age: $selectedAge');

    // Get previous data if any
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final previousData = args ?? {};

    // Add age to data
    previousData['age'] = selectedAge.toString();

    // Navigate to weight screen
    Navigator.pushNamed(context, '/weight', arguments: previousData);
  }
}
