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
    return Scaffold(
      backgroundColor: context.surfaceColor, // ✅ DARK MODE
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Outline Title
                      _buildOutlineTitle(),

                      const SizedBox(height: 20),

                      // Heading
                      _buildHeading(),

                      const SizedBox(height: 10),

                      // Weight Display
                      _buildWeightDisplay(),

                      const SizedBox(height: 20),

                      // Ruler
                      _buildRuler(),

                      const SizedBox(height: 20),

                      // Unit Toggle
                      _buildUnitToggle(),

                      const SizedBox(height: 30),

                      // Next Button
                      _buildNextButton(),

                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOutlineTitle() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Outline text
        Text(
          'PowerHouse',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            letterSpacing: -2,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = isDark
                  ? Colors
                        .white // ✅ DARK MODE
                  : Colors.black,
          ),
        ),
        // Solid text
        Text(
          'PowerHouse',
          style: TextStyle(
            color: context.surfaceColor, // ✅ DARK MODE
            fontSize: 48,
            fontWeight: FontWeight.w700,
            letterSpacing: -2,
          ),
        ),
      ],
    );
  }

  Widget _buildHeading() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'How much\n',
            style: TextStyle(
              color: context.primaryText, // ✅ DARK MODE
              fontSize: 48,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          TextSpan(
            text: 'Weight?',
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

  Widget _buildWeightDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          selectedWeight.toInt().toString(),
          style: TextStyle(
            color: context.primaryText, // ✅ DARK MODE
            fontSize: 90,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.92,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20, left: 8),
          child: Text(
            selectedUnit,
            style: TextStyle(
              color: context.secondaryText, // ✅ DARK MODE
              fontSize: 36,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.43,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRuler() {
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

    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center indicator line
          Container(
            width: 4,
            height: 80,
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
                          height: isMajorTick ? 56 : 24,
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
                          const SizedBox(height: 44),
                          Text(
                            weight.toString(),
                            style: TextStyle(
                              color: labelColor, // ✅ DARK MODE
                              fontSize: 14,
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
    print('Selected weight: ${selectedWeight.toInt()} $selectedUnit');

    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final previousData = args ?? {};
    previousData['weight'] = selectedWeight.toString();
    previousData['weightUnit'] = selectedUnit;

    Navigator.pushNamed(context, '/height', arguments: previousData);
  }
}
