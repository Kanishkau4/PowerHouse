import 'package:flutter/material.dart';

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Title with outline effect
              _buildOutlineTitle(),
              
              const SizedBox(height: 60),
              
              // Main heading
              _buildHeading(),
              
              const SizedBox(height: 60),
              
              // Age Picker
              Expanded(
                child: _buildAgePicker(),
              ),
              
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

  // Outline Title Widget (Same as Gender Screen)
  Widget _buildOutlineTitle() {
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
              ..color = const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        // Solid text
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

  // Heading Widget
  Widget _buildHeading() {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'And\nYour ',
            style: TextStyle(
              color: Colors.black,
              fontSize: 48,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          TextSpan(
            text: 'age?',
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

  // Age Picker Widget
  Widget _buildAgePicker() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Selection highlight container
          Container(
            height: 120, // Increased from 118 to better match item size
            width: 220, // Increased from 218 for better visual balance
            decoration: BoxDecoration(
              color: const Color(0xFFF97316),
              borderRadius: BorderRadius.circular(48),
              border: Border.all(
                color: const Color(0xFFFFEDD5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF97316).withOpacity(0.25),
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
              itemExtent: 100, // Increased from 80 to accommodate larger font
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
                    fontSize = 80; // Reduced from 96 to better fit in item extent
                    textColor = Colors.white;
                    fontWeight = FontWeight.w800;
                  } else if (difference == 1) {
                    fontSize = 60;
                    textColor = const Color(0xFF9EA0A5);
                    fontWeight = FontWeight.w700;
                  } else {
                    fontSize = 30;
                    textColor = const Color(0xFFD7D7D8);
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

  // Next Button Widget (Same as Gender Screen)
  Widget _buildNextButton() {
    return GestureDetector(
      onTap: _handleNext,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer circle (light)
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF1DAB87).withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
          // Inner circle (solid)
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

  // Handle Next Button
  void _handleNext() {
    print('Selected age: $selectedAge');

    // Get previous data if any
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final previousData = args ?? {};
    
    // Add age to data
    previousData['age'] = selectedAge.toString();

    // Navigate to weight screen
    Navigator.pushNamed(
      context,
      '/weight',
      arguments: previousData,
    );
  }
}