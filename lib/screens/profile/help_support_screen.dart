import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        children: [
          // Quick Actions
          _buildSectionTitle('Quick Actions'),
          const SizedBox(height: 16),
          
          _buildActionCard(
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'support@powerhouse.lk',
            color: const Color(0xFF1DAB87),
            onTap: () => _launchEmail(),
          ),
          
          const SizedBox(height: 12),
          
          _buildActionCard(
            icon: Icons.phone_outlined,
            title: 'Call Support',
            subtitle: '+94 11 123 4567',
            color: const Color(0xFFFF844B),
            onTap: () => _launchPhone(),
          ),
          
          const SizedBox(height: 12),
          
          _buildActionCard(
            icon: Icons.chat_bubble_outline,
            title: 'Live Chat',
            subtitle: 'Chat with our support team',
            color: const Color(0xFF6C63FF),
            onTap: () => _openLiveChat(context),
          ),
          
          const SizedBox(height: 12),
          
          _buildActionCard(
            icon: Icons.language_outlined,
            title: 'Visit Website',
            subtitle: 'www.powerhouse.lk',
            color: const Color(0xFF1DAB87),
            onTap: () => _launchWebsite(),
          ),
          
          const SizedBox(height: 32),
          
          // FAQ Section
          _buildSectionTitle('Frequently Asked Questions'),
          const SizedBox(height: 16),
          
          _buildFAQItem(
            question: 'How do I reset my password?',
            answer: 'Go to Settings > Account > Change Password. You can also reset it from the login screen by tapping "Forgot Password".',
          ),
          
          _buildFAQItem(
            question: 'How do I track my workouts?',
            answer: 'Navigate to the Workouts tab, select a workout plan, and tap "Start Workout". The app will guide you through each exercise.',
          ),
          
          _buildFAQItem(
            question: 'Can I customize my meal plans?',
            answer: 'Yes! Go to Nutrition > My Meals and tap the "+" button to add custom meals. You can also edit existing meal plans.',
          ),
          
          _buildFAQItem(
            question: 'How do challenges work?',
            answer: 'Challenges are time-based fitness goals. Join a challenge from the Challenges tab and complete daily tasks to earn XP and badges.',
          ),
          
          _buildFAQItem(
            question: 'How do I sync with other devices?',
            answer: 'PowerHouse automatically syncs your data across all devices when you\'re logged in with the same account.',
          ),
          
          const SizedBox(height: 32),
          
          // About Section
          _buildSectionTitle('About'),
          const SizedBox(height: 16),
          
          _buildInfoCard('Version', '1.0.0'),
          _buildInfoCard('Privacy Policy', 'View Privacy Policy', onTap: () {}),
          _buildInfoCard('Terms of Service', 'View Terms', onTap: () {}),
          _buildInfoCard('Licenses', 'Open Source Licenses', onTap: () {}),
          
          const SizedBox(height: 32),
          
          // Social Media
          _buildSectionTitle('Connect With Us'),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(
                icon: Icons.facebook,
                color: const Color(0xFF1877F2),
                onTap: () {},
              ),
              _buildSocialButton(
                icon: Icons.camera_alt,
                color: const Color(0xFFE4405F),
                onTap: () {},
              ),
              _buildSocialButton(
                icon: Icons.send,
                color: const Color(0xFF0088CC),
                onTap: () {},
              ),
              _buildSocialButton(
                icon: Icons.video_library,
                color: const Color(0xFFFF0000),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.black,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7E7E7E),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Theme(
      data: ThemeData(
        dividerColor: Colors.transparent,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          iconColor: const Color(0xFF1DAB87),
          collapsedIconColor: const Color(0xFF7E7E7E),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7E7E7E),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String subtitle, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            Row(
              children: [
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7E7E7E),
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Color(0xFF7E7E7E),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: 28,
        ),
      ),
    );
  }

  // ==================== LAUNCH FUNCTIONS ====================

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
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '+94111234567',
    );
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Live Chat'),
        content: const Text(
          'Live chat feature coming soon! For now, please email us at support@powerhouse.lk',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF1DAB87)),
            ),
          ),
        ],
      ),
    );
  }
}