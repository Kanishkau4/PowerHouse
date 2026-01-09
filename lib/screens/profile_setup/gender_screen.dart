import 'package:flutter/material.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:powerhouse/widgets/circular_progress_button.dart';

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  String selectedGender = '';

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
    final sectionSpacing = isSmallScreen ? 20.0 : 40.0;
    final headingFontSize = isSmallScreen
        ? 36.0
        : isMediumScreen
        ? 44.0
        : 54.0;
    final buttonSize = isSmallScreen
        ? 110.0
        : isMediumScreen
        ? 124.0
        : 136.0;

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
                        SizedBox(height: sectionSpacing * 1.5),
                        _buildGenderButtons(buttonSize),
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
              text: 'Tell us\nYour ',
              style: TextStyle(
                color: context.primaryText,
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            TextSpan(
              text: 'gender',
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

  Widget _buildGenderButtons(double size) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GenderButtonWithImage(
          imagePath: 'assets/icons/male_icon.png',
          fallbackIcon: Icons.male,
          label: 'Male',
          isSelected: selectedGender == 'male',
          isDark: isDark,
          size: size,
          onTap: () {
            setState(() {
              selectedGender = 'male';
            });
          },
        ),
        SizedBox(width: size * 0.2),
        GenderButtonWithImage(
          imagePath: 'assets/icons/female_icon.png',
          fallbackIcon: Icons.female,
          label: 'Female',
          isSelected: selectedGender == 'female',
          isDark: isDark,
          size: size,
          onTap: () {
            setState(() {
              selectedGender = 'female';
            });
          },
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    final bool isEnabled = selectedGender.isNotEmpty;

    return Center(
      child: CircularProgressButton(
        progress: 0.2, // 20% progress (step 1/5)
        onTap: isEnabled ? _handleNext : null,
        isEnabled: isEnabled,
      ),
    );
  }

  void _handleNext() {
    if (selectedGender.isEmpty) return;

    print('Selected gender: $selectedGender');

    Navigator.pushNamed(context, '/age', arguments: {'gender': selectedGender});
  }
}

// Gender Button with Image and Fallback Icon - Updated for Dark Mode
class GenderButtonWithImage extends StatelessWidget {
  final String imagePath;
  final IconData fallbackIcon;
  final String label;
  final bool isSelected;
  final bool isDark; // ✅ Add dark mode flag
  final double size;
  final VoidCallback onTap;

  const GenderButtonWithImage({
    super.key,
    required this.imagePath,
    required this.fallbackIcon,
    required this.label,
    required this.isSelected,
    required this.isDark, // ✅ Required parameter
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Selected color (orange accent)
    final selectedColor = context.accentColor;

    // Unselected color based on theme
    final unselectedColor = isDark
        ? Colors
              .grey
              .shade400 // ✅ DARK MODE: Lighter grey for visibility
        : const Color(0xFF7E7E7E);

    // Background colors
    final selectedBgColor = context.accentColor.withOpacity(isDark ? 0.2 : 0.1);
    final unselectedBgColor = isDark
        ? context
              .cardBackground // ✅ DARK MODE
        : Colors.white;

    // Border color for unselected in dark mode
    final unselectedBorderColor = isDark
        ? Colors
              .grey
              .shade600 // ✅ DARK MODE
        : const Color(0xFF7E7E7E);

    final color = isSelected ? selectedColor : unselectedColor;
    final bgColor = isSelected ? selectedBgColor : unselectedBgColor;
    final borderColor = isSelected ? selectedColor : unselectedBorderColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(size * 0.22),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : (isDark
                    ? [
                        // ✅ Subtle shadow in dark mode for depth
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Try to load image, fallback to icon
            Image.asset(
              imagePath,
              width: size * 0.44,
              height: size * 0.44,
              color: color, // Tint the icon
              errorBuilder: (context, error, stackTrace) {
                return Icon(fallbackIcon, size: size * 0.44, color: color);
              },
            ),
            SizedBox(height: size * 0.05),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: size * 0.14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
