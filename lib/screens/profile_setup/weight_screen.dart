import 'package:flutter/material.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:powerhouse/widgets/circular_progress_button.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  double selectedWeight = 70.0; // Default weight in kg
  String selectedUnit = 'kg'; // kg or lbs
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // Initialize scroll controller
    _scrollController = ScrollController(
      initialScrollOffset: (selectedWeight - 30) * 10, // Offset calculation
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Calculate weight based on scroll position
    double offset = _scrollController.offset;
    setState(() {
      selectedWeight = (30 + (offset / 10)).clamp(30.0, 200.0);
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
    final weightFontSize = isSmallScreen
        ? 60.0
        : isMediumScreen
        ? 75.0
        : 90.0;
    final unitFontSize = isSmallScreen ? 24.0 : 36.0;

    return Scaffold(
      backgroundColor: context.surfaceColor, // ✅ DARK MODE
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

                        // Outline Title
                        _buildOutlineTitle(logoHeight),

                        SizedBox(height: sectionSpacing),

                        // Heading
                        _buildHeading(headingFontSize),

                        SizedBox(height: sectionSpacing),

                        // Weight Display
                        _buildWeightDisplay(weightFontSize, unitFontSize),

                        SizedBox(height: sectionSpacing),

                        // Ruler
                        _buildRuler(isSmallScreen),

                        SizedBox(height: isSmallScreen ? 15 : 30),

                        // Unit Toggle
                        _buildUnitToggle(),

                        const Spacer(),

                        // Next Button
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
        // Optional: Apply color filter for dark mode if logo is dark
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
            text: 'How much\n',
            style: TextStyle(
              color: context.primaryText, // ✅ DARK MODE
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          TextSpan(
            text: 'Weight?',
            style: TextStyle(
              color: context.primaryColor, // ✅ DARK MODE
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightDisplay(double weightFontSize, double unitFontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          selectedWeight.toInt().toString(),
          style: TextStyle(
            color: context.primaryText, // ✅ DARK MODE
            fontSize: weightFontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.92,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: weightFontSize * 0.2, left: 8),
          child: Text(
            selectedUnit,
            style: TextStyle(
              color: context.secondaryText, // ✅ DARK MODE
              fontSize: unitFontSize,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.43,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRuler(bool isSmall) {
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

    final rulerHeight = isSmall ? 120.0 : 160.0;
    final tickHeight = isSmall ? 40.0 : 56.0;

    return SizedBox(
      height: rulerHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center indicator line
          Container(
            width: 4,
            height: tickHeight * 1.5,
            color: context.accentColor, // ✅ DARK MODE (Orange)
          ),

          // Scrollable ruler
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(
                171, // 30 to 200 kg
                (index) {
                  final weight = 30 + index;
                  final isMajorTick = weight % 5 == 0;

                  return Container(
                    width: 10,
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: [
                        // Tick mark
                        Container(
                          width: isMajorTick ? 4 : 2,
                          height: isMajorTick ? tickHeight : 24,
                          decoration: BoxDecoration(
                            color: isMajorTick
                                ? majorTickColor // ✅ DARK MODE
                                : minorTickColor, // ✅ DARK MODE
                            borderRadius: BorderRadius.circular(
                              isMajorTick ? 1.5 : 0.75,
                            ),
                          ),
                        ),

                        // Number label (only for major ticks)
                        if (isMajorTick) ...[
                          SizedBox(height: rulerHeight * 0.25),
                          Text(
                            weight.toString(),
                            style: TextStyle(
                              color: labelColor, // ✅ DARK MODE
                              fontSize: isSmall ? 12 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildUnitButton('kg'),
        const SizedBox(width: 16),
        _buildUnitButton('lbs'),
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
          if (unit == 'lbs' && selectedUnit == 'kg') {
            selectedWeight = selectedWeight * 2.20462;
          } else if (unit == 'kg' && selectedUnit == 'lbs') {
            selectedWeight = selectedWeight / 2.20462;
          }
          selectedUnit = unit;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedBgColor : unselectedBgColor,
          border: Border.all(
            color: isSelected ? selectedBorderColor : unselectedBorderColor,
          ),
          borderRadius: BorderRadius.circular(20),
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Center(
      child: CircularProgressButton(
        progress: 0.6, // 60% progress (step 3/5)
        onTap: _handleNext,
        isEnabled: true,
      ),
    );
  }

  void _handleNext() {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final previousData = args ?? {};
    previousData['weight'] = selectedWeight.toString();
    previousData['weightUnit'] = selectedUnit;

    Navigator.pushNamed(context, '/height', arguments: previousData);
  }
}
