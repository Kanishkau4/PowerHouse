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
    return Scaffold(
      backgroundColor: context.surfaceColor, // ✅ DARK MODE
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildOutlineTitle(),
              const SizedBox(height: 40),
              _buildHeading(),
              const SizedBox(height: 60),
              _buildGenderButtons(),
              const Spacer(),
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
              text: 'Tell us\nYour ',
              style: TextStyle(
                color: context.primaryText, // ✅ DARK MODE
                fontSize: 48,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            TextSpan(
              text: 'gender',
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

  Widget _buildGenderButtons() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GenderButtonWithImage(
          imagePath: 'assets/icons/male_icon.png',
          fallbackIcon: Icons.male,
          label: 'Male',
          isSelected: selectedGender == 'male',
          isDark: isDark, // ✅ Pass dark mode flag
          onTap: () {
            setState(() {
              selectedGender = 'male';
            });
          },
        ),
        const SizedBox(width: 25),
        GenderButtonWithImage(
          imagePath: 'assets/icons/female_icon.png',
          fallbackIcon: Icons.female,
          label: 'Female',
          isSelected: selectedGender == 'female',
          isDark: isDark, // ✅ Pass dark mode flag
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
  final VoidCallback onTap;

  const GenderButtonWithImage({
    super.key,
    required this.imagePath,
    required this.fallbackIcon,
    required this.label,
    required this.isSelected,
    required this.isDark, // ✅ Required parameter
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
        width: 136,
        height: 136,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(30),
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
              width: 60,
              height: 60,
              color: color, // Tint the icon
              errorBuilder: (context, error, stackTrace) {
                return Icon(fallbackIcon, size: 60, color: color);
              },
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
