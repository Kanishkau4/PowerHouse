import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Modern off-white background to make white cards pop
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FD),
        surfaceTintColor: Colors.transparent, // Material 3 fix
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildSectionHeader('How can we help you?'),
          const SizedBox(height: 16),

          _buildActionCard(
            icon: FontAwesomeIcons.envelope,
            title: 'Email Support',
            subtitle: 'Get a response within 24h',
            color: const Color(0xFF1DAB87),
            onTap: () => _launchEmail(),
          ),

          const SizedBox(height: 16),

          _buildActionCard(
            icon: FontAwesomeIcons.phone,
            title: 'Call Support',
            subtitle: '+94 11 123 4567',
            color: const Color(0xFFFF844B),
            onTap: () => _launchPhone(),
          ),

          const SizedBox(height: 16),

          _buildActionCard(
            icon: FontAwesomeIcons.comments,
            title: 'Live Chat',
            subtitle: 'Chat with our support team',
            color: const Color.fromARGB(255, 255, 225, 0),
            onTap: () => _openLiveChat(context),
          ),

          const SizedBox(height: 16),

          _buildActionCard(
            icon: FontAwesomeIcons.globe,
            title: 'Visit Website',
            subtitle: 'www.powerhouse.lk',
            color: const Color.fromARGB(255, 69, 81, 255),
            onTap: () => _launchWebsite(),
          ),

          const SizedBox(height: 32),

          // FAQ Section
          _buildSectionHeader('Frequently Asked Questions'),
          const SizedBox(height: 16),

          Column(
            children: [
              _buildFAQItem(
                question: 'How do I reset my password?',
                answer:
                    'Go to Settings > Account > Change Password. You can also reset it from the login screen by tapping "Forgot Password".',
              ),
              _buildFAQItem(
                question: 'How do I track my workouts?',
                answer:
                    'Navigate to the Workouts tab, select a workout plan, and tap "Start Workout". The app will guide you through each exercise.',
              ),
              _buildFAQItem(
                question: 'Can I customize my meal plans?',
                answer:
                    'Yes! Go to Nutrition > My Meals and tap the "+" button to add custom meals. You can also edit existing meal plans.',
              ),
              _buildFAQItem(
                question: 'How do challenges work?',
                answer:
                    'Challenges are time-based fitness goals. Join a challenge from the Challenges tab and complete daily tasks to earn XP and badges.',
              ),
              _buildFAQItem(
                question: 'How do I sync with other devices?',
                answer:
                    'PowerHouse automatically syncs your data across all devices when you\'re logged in with the same account.',
              ),
            ],
          ),

          const SizedBox(height: 32),

          // About Section - Modern Grouped Style
          _buildSectionHeader('About'),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInfoRow('Version', '1.0.2', isFirst: true),
                const Divider(height: 1, indent: 20, endIndent: 20),
                _buildInfoRow('Privacy Policy', '', onTap: () {}),
                const Divider(height: 1, indent: 20, endIndent: 20),
                _buildInfoRow('Terms of Service', '', onTap: () {}),
                const Divider(height: 1, indent: 20, endIndent: 20),
                _buildInfoRow('Licenses', '', onTap: () {}, isLast: true),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Social Media
          _buildSectionHeader('Follow Us'),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(
                icon: FontAwesomeIcons.facebook,
                color: const Color(0xFF1877F2),
                onTap: () {},
              ),
              _buildSocialButton(
                icon: FontAwesomeIcons.instagram,
                color: const Color(0xFFE4405F),
                onTap: () {},
              ),
              _buildSocialButton(
                icon: FontAwesomeIcons.telegram,
                color: const Color(0xFF0088CC),
                onTap: () {},
              ),
              _buildSocialButton(
                icon: FontAwesomeIcons.youtube,
                color: const Color(0xFFFF0000),
                onTap: () {},
              ),
            ],
          ),

          // Bottom padding
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF2D3142),
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3142),
            ),
          ),
          iconColor: const Color(0xFF1DAB87),
          collapsedIconColor: const Color(0xFF2D3142),
          children: [
            Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String title,
    String subtitle, {
    VoidCallback? onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(20) : Radius.zero,
          bottom: isLast ? const Radius.circular(20) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3142),
                ),
              ),
              Row(
                children: [
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1DAB87),
                      ),
                    ),
                  if (onTap != null) ...[
                    if (subtitle.isNotEmpty) const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: color,
            size: 34, // Increased size to better fit circle
          ),
        ),
      ),
    );
  }

  // ==================== LAUNCH FUNCTIONS (UNCHANGED) ====================

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@powerhouse.lk',
      query: 'subject=Support Request',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+94111234567');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchWebsite() async {
    final Uri websiteUri = Uri.parse('https://www.powerhouse.lk');
    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
    }
  }

  void _openLiveChat(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Live Chat'),
        content: const Text(
          'Live chat feature coming soon! For now, please email us at support@powerhouse.lk',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF1DAB87))),
          ),
        ],
      ),
    );
  }
}
