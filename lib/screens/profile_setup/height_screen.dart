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
      backgroundColor: context.surfaceColor,
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

              // Vertical Ruler (without Expanded)
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
    );
  }

  Widget _buildHeading() {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'How much ',
            style: TextStyle(
              color: Colors.black,
              fontSize: 48,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          TextSpan(
            text: 'Tall\n',
            style: TextStyle(
              color: Color(0xFF1DAB87),
              fontSize: 48,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          TextSpan(
            text: 'are you?',
            style: TextStyle(
              color: Colors.black,
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
          style: const TextStyle(
            color: Color(0xFF101114),
            fontSize: 90,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.92,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20, left: 8),
          child: Text(
            selectedUnit,
            style: const TextStyle(
              color: Color(0xFF676B74),
              fontSize: 36,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalRuler() {
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
                style: const TextStyle(
                  color: Color(0xFF676B74),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Remove Spacer and add explicit height
              Text(
                '${(selectedHeight + 1).toInt()}',
                style: const TextStyle(
                  color: Color(0xFF676B74),
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
            Container(width: 80, height: 4, color: const Color(0xFFF97316)),

            // Scrollable vertical ruler
            SizedBox(
              width: 100,
              height: 200, // Add explicit height
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
                                    ? const Color(0xFFB9BBBE)
                                    : const Color(0xFFD7D7D8),
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
    final isSelected = selectedUnit == unit;

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
          color: isSelected ? const Color(0xFF1DAB87) : Colors.white,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1DAB87)
                : const Color(0xFFD7D7D8),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          unit,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF676B74),
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
        isEnabled: true, // Always enabled on height screen
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
