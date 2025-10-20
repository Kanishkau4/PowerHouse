import 'package:flutter/material.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({Key? key}) : super(key: key);

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
    backgroundColor: Colors.white,
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
                    
                    const SizedBox(height: 30), // Replace Spacer with fixed height
                    
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
            text: 'How much\n',
            style: TextStyle(
              color: Colors.black,
              fontSize: 48,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          TextSpan(
            text: 'Weight?',
            style: TextStyle(
              color: Color(0xFF1DAB87),
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
              letterSpacing: -0.43,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRuler() {
    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center indicator line
          Container(
            width: 4,
            height: 80,
            color: const Color(0xFFF97316),
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
                                ? const Color(0xFFB9BBBE) 
                                : const Color(0xFFD7D7D8),
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
                            style: const TextStyle(
                              color: Color(0xFF676B74),
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
    final isSelected = selectedUnit == unit;
    
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
          color: isSelected ? const Color(0xFF1DAB87) : Colors.white,
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF1DAB87) 
                : const Color(0xFFD7D7D8),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          unit,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF676B74),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: _handleNext,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF1DAB87).withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFF1DAB87),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    print('Selected weight: ${selectedWeight.toInt()} $selectedUnit');

    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final previousData = args ?? {};
    previousData['weight'] = selectedWeight.toString();
    previousData['weightUnit'] = selectedUnit;

    Navigator.pushNamed(
      context,
      '/height',
      arguments: previousData,
    );
  }
}