import 'package:flutter/material.dart';

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildOutlineTitle(),
              const SizedBox(height: 60),
              _buildHeading(),
              const SizedBox(height: 80),
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
    return Center(
      child: Stack(
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
      ),
    );
  }

  Widget _buildHeading() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'Tell us\nYour ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 48,
                fontWeight: FontWeight.w800,
                height: 1.1, 
              ),
            ),
            TextSpan(
              text: 'gender',
              style: TextStyle(
                color: Color(0xFF1DAB87),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GenderButtonWithImage(
          imagePath: 'assets/icons/male_icon.png',
          fallbackIcon: Icons.male,
          label: 'Male',
          isSelected: selectedGender == 'male',
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
      child: GestureDetector(
        onTap: isEnabled ? _handleNext : null,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isEnabled
                    ? const Color(0xFF1DAB87).withOpacity(0.3)
                    : Colors.grey.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isEnabled 
                    ? const Color(0xFF1DAB87) 
                    : Colors.grey,
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
      ),
    );
  }

  void _handleNext() {
    if (selectedGender.isEmpty) return;

    print('Selected gender: $selectedGender');
    
    Navigator.pushNamed(
      context,
      '/age',
      arguments: {'gender': selectedGender},
    );
  }
}

// Gender Button with Image and Fallback Icon
class GenderButtonWithImage extends StatelessWidget {
  final String imagePath;
  final IconData fallbackIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const GenderButtonWithImage({
    super.key,
    required this.imagePath,
    required this.fallbackIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected 
        ? const Color(0xFFF15223) 
        : const Color(0xFF7E7E7E);
    final bgColor = isSelected 
        ? const Color(0xFFF15223).withOpacity(0.1) 
        : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 136,
        height: 136,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Try to load image, fallback to icon
            Image.asset(
              imagePath,
              width: 60,
              height: 60,
              color: color,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  fallbackIcon,
                  size: 60,
                  color: color,
                );
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