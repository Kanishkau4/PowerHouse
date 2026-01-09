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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: topPadding),
                        _buildOutlineTitle(logoHeight),
                        SizedBox(height: sectionSpacing * 0.5),
                        _buildHeading(headingFontSize),
                        SizedBox(height: sectionSpacing),
                        // Age Picker
                        Expanded(child: _buildAgePicker(isSmallScreen)),
                        SizedBox(height: sectionSpacing),
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

  // Outline Title Widget
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

  // Heading Widget
  Widget _buildHeading(double fontSize) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'And\nYour ',
            style: TextStyle(
              color: context.primaryText,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          TextSpan(
            text: 'age?',
            style: TextStyle(
              color: context.primaryColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  // Age Picker Widget
  Widget _buildAgePicker(bool isSmall) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

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

    final highlightHeight = isSmall ? 90.0 : 120.0;
    final highlightWidth = isSmall ? 180.0 : 220.0;
    final pickerHeight = isSmall ? screenHeight * 0.35 : 400.0;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Selection highlight container
          Container(
            height: highlightHeight,
            width: highlightWidth,
            decoration: BoxDecoration(
              color: context.accentColor, // ✅ DARK MODE (Orange)
              borderRadius: BorderRadius.circular(highlightHeight * 0.4),
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
            height: pickerHeight,
            child: ListWheelScrollView.useDelegate(
              controller: _scrollController,
              itemExtent: highlightHeight * 0.83,
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
                    fontSize = isSmall ? 60 : 80;
                    textColor = Colors.white; // Always white on orange
                    fontWeight = FontWeight.w800;
                  } else if (difference == 1) {
                    fontSize = isSmall ? 40 : 60;
                    textColor = nearbyTextColor; // ✅ DARK MODE
                    fontWeight = FontWeight.w700;
                  } else {
                    fontSize = isSmall ? 24 : 30;
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
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final previousData = args ?? {};

    // Add age to data
    previousData['age'] = selectedAge.toString();

    // Navigate to weight screen
    Navigator.pushNamed(context, '/weight', arguments: previousData);
  }
}
