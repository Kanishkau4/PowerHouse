import 'package:flutter/material.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:powerhouse/widgets/circular_progress_button.dart';

class HeightScreen extends StatefulWidget {
  const HeightScreen({super.key});

  @override
  State<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends State<HeightScreen> {
  double selectedHeight = 170.0; // cm
  String selectedUnit = 'cm';
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: (selectedHeight - 100) * 10,
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    double offset = _scrollController.offset;
    setState(() {
      selectedHeight = (100 + (offset / 10)).clamp(100.0, 250.0);
    });
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
    final sectionSpacing = isSmallScreen ? 5.0 : 15.0;
    final headingFontSize = isSmallScreen
        ? 36.0
        : isMediumScreen
        ? 44.0
        : 54.0;
    final heightFontSize = isSmallScreen
        ? 60.0
        : isMediumScreen
        ? 75.0
        : 90.0;
    final unitFontSize = isSmallScreen ? 24.0 : 36.0;

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
                      children: [
                        SizedBox(height: topPadding),
                        _buildOutlineTitle(logoHeight),
                        SizedBox(height: sectionSpacing),
                        _buildHeading(headingFontSize),
                        SizedBox(height: sectionSpacing),
                        _buildHeightDisplay(heightFontSize, unitFontSize),
                        SizedBox(height: sectionSpacing),
                        _buildVerticalRuler(isSmallScreen),
                        SizedBox(height: sectionSpacing),
                        _buildUnitToggle(),
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
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'How much ',
            style: TextStyle(
              color: context.primaryText,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          TextSpan(
            text: 'Tall\n',
            style: TextStyle(
              color: context.primaryColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          TextSpan(
            text: 'are you?',
            style: TextStyle(
              color: context.primaryText,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeightDisplay(double heightFontSize, double unitFontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          selectedHeight.toInt().toString(),
          style: TextStyle(
            color: context.primaryText,
            fontSize: heightFontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.92,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: heightFontSize * 0.2, left: 8),
          child: Text(
            selectedUnit,
            style: TextStyle(
              color: context.secondaryText,
              fontSize: unitFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalRuler(bool isSmall) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Tick colors based on theme
    final majorTickColor = isDark
        ? Colors
              .grey
              .shade500 // ✅ DARK MODE
        : const Color(0xFFB9BBBE);

    final minorTickColor = isDark
        ? Colors
              .grey
              .shade700 // ✅ DARK MODE
        : const Color(0xFFD7D7D8);

    final labelColor = isDark
        ? Colors
              .grey
              .shade400 // ✅ DARK MODE
        : const Color(0xFF676B74);

    final rulerHeight = isSmall ? 150.0 : 200.0;
    final tickWidth = isSmall ? 40.0 : 56.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left labels
        SizedBox(
          width: 40,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(selectedHeight - 1).toInt()}',
                style: TextStyle(
                  color: labelColor, // ✅ DARK MODE
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(selectedHeight + 1).toInt()}',
                style: TextStyle(
                  color: labelColor, // ✅ DARK MODE
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Ruler
        Stack(
          alignment: Alignment.center,
          children: [
            // Center indicator line
            Container(
              width: tickWidth * 1.5,
              height: 4,
              color: context.accentColor, // ✅ DARK MODE (Orange)
            ),

            // Scrollable vertical ruler
            SizedBox(
              width: 100,
              height: rulerHeight,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: List.generate(
                    151, // 100 to 250 cm
                    (index) {
                      final height = 100 + index;
                      final isMajorTick = height % 5 == 0;

                      return Container(
                        height: 10,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: isMajorTick ? 4 : 2,
                              width: isMajorTick ? tickWidth : 24,
                              decoration: BoxDecoration(
                                color: isMajorTick
                                    ? majorTickColor // ✅ DARK MODE
                                    : minorTickColor, // ✅ DARK MODE
                                borderRadius: BorderRadius.circular(
                                  isMajorTick ? 1.5 : 0.75,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnitToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildUnitButton('cm'),
        const SizedBox(width: 16),
        _buildUnitButton('ft'),
      ],
    );
  }

  Widget _buildUnitButton(String unit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = selectedUnit == unit;

    // Colors based on theme and selection state
    final selectedBgColor = context.primaryColor;
    final unselectedBgColor = isDark
        ? context
              .cardBackground // ✅ DARK MODE
        : Colors.white;

    final selectedBorderColor = context.primaryColor;
    final unselectedBorderColor = isDark
        ? Colors
              .grey
              .shade600 // ✅ DARK MODE
        : const Color(0xFFD7D7D8);

    final selectedTextColor = Colors.white;
    final unselectedTextColor = context.secondaryText; // ✅ DARK MODE

    return GestureDetector(
      onTap: () {
        setState(() {
          if (unit == 'ft' && selectedUnit == 'cm') {
            selectedHeight = selectedHeight / 30.48;
          } else if (unit == 'cm' && selectedUnit == 'ft') {
            selectedHeight = selectedHeight * 30.48;
          }
          selectedUnit = unit;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? selectedBgColor : unselectedBgColor,
          border: Border.all(
            color: isSelected ? selectedBorderColor : unselectedBorderColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: isDark && !isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          unit,
          style: TextStyle(
            color: isSelected ? selectedTextColor : unselectedTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Center(
      child: CircularProgressButton(
        progress: 0.8, // 80% progress (step 4/5)
        onTap: _handleNext,
        isEnabled: true,
      ),
    );
  }

  void _handleNext() {
    print('Selected height: ${selectedHeight.toInt()} $selectedUnit');

    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final previousData = args ?? {};
    previousData['height'] = selectedHeight.toString();
    previousData['heightUnit'] = selectedUnit;

    Navigator.pushNamed(context, '/goal', arguments: previousData);
  }
}
