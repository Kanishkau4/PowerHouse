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
    return Scaffold(
      backgroundColor: context.surfaceColor, // ✅ DARK MODE
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildOutlineTitle(),
              const SizedBox(height: 20),
              _buildHeading(),
              const SizedBox(height: 20),

              // Height Display
              _buildHeightDisplay(),

              const SizedBox(height: 20),

              // Vertical Ruler
              _buildVerticalRuler(),

              const SizedBox(height: 20),
              _buildUnitToggle(),
              const SizedBox(height: 20),
              _buildNextButton(),
              const SizedBox(height: 20),
            ],
          ),
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
            text: 'How much ',
            style: TextStyle(
              color: context.primaryText, // ✅ DARK MODE
              fontSize: 48,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          TextSpan(
            text: 'Tall\n',
            style: TextStyle(
              color: context.primaryColor, // ✅ DARK MODE
              fontSize: 48,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          TextSpan(
            text: 'are you?',
            style: TextStyle(
              color: context.primaryText, // ✅ DARK MODE
              fontSize: 48,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeightDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          selectedHeight.toInt().toString(),
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
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalRuler() {
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
              width: 80,
              height: 4,
              color: context.accentColor, // ✅ DARK MODE (Orange)
            ),

            // Scrollable vertical ruler
            SizedBox(
              width: 100,
              height: 200,
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
                              width: isMajorTick ? 56 : 24,
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
