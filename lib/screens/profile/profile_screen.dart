import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:powerhouse/screens/profile/edit_profile_screen.dart';
import 'package:powerhouse/screens/profile/help_support_screen.dart';
import 'package:powerhouse/screens/profile/notifications_screen.dart';
import 'package:powerhouse/services/user_service.dart';
import 'package:powerhouse/services/badge_service.dart';
import 'package:powerhouse/models/user_model.dart';
import 'package:powerhouse/models/user_badge_model.dart';
import 'package:powerhouse/core/config/supabase_config.dart';
import 'package:powerhouse/core/constants/badge_icons.dart';
import 'package:powerhouse/core/theme/theme_provider.dart';
import 'dart:math' as math;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Services
  final _userService = UserService();
  final _badgeService = BadgeService();
  
  // User data
  UserModel? _userProfile;
  List<UserBadgeModel> _userBadges = [];
  
  // Chart data (BMI over time)
  List<FlSpot> _chartData = [];
  
  // Settings
  String selectedLanguage = 'English';
  
  // Loading state
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load user profile
      final profile = await _userService.getCurrentUserProfile();
      
      // Load user badges
      final badges = await _badgeService.getUserBadges();
      
      print('✅ Loaded ${badges.length} badges for user');
      
      setState(() {
        _userProfile = profile;
        _userBadges = badges;
        _generateBMIChartData();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading profile data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _generateBMIChartData() {
    final List<FlSpot> data = [];
    final currentBMI = _userProfile?.bmi ?? 22.0;
    final random = math.Random();
    
    for (int i = 0; i < 7; i++) {
      final variation = (random.nextDouble() - 0.5) * 2;
      final bmi = (currentBMI + variation).clamp(15.0, 35.0);
      data.add(FlSpot(i.toDouble(), bmi));
    }
    
    setState(() {
      _chartData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF1DAB87),
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildProfileHeader(isDarkMode),
              const SizedBox(height: 32),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stats Overview',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatsCards(isDarkMode),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BMI Trend',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBMIChart(isDarkMode),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildSettingsSection(isDarkMode),
              ),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== PROFILE HEADER ====================
  Widget _buildProfileHeader(bool isDarkMode) {
    return Column(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF1DAB87),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1DAB87).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child: _userProfile?.profilePictureUrl != null
                ? Image.network(
                    _userProfile!.profilePictureUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderAvatar();
                    },
                  )
                : _buildPlaceholderAvatar(),
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          _userProfile?.username ?? 'User',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Level ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white70 : Colors.black,
                ),
              ),
              TextSpan(
                text: '${_userProfile?.level ?? 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1DAB87),
                ),
              ),
              TextSpan(
                text: ' • ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white70 : Colors.black,
                ),
              ),
              TextSpan(
                text: '${_userProfile?.xpPoints ?? 0} XP',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF97316),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? Colors.grey.shade800 
                      : const Color(0x9ED9D9D9),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              FractionallySizedBox(
                widthFactor: _userProfile != null 
                    ? _userProfile!.levelProgress 
                    : 0.0,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1DAB87),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _userProfile != null
              ? 'XP to next level: ${_userProfile!.xpNeededForNextLevel}'
              : 'XP to next level: 100',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF7E7E7E),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      color: const Color(0xFF1DAB87),
      child: Center(
        child: Text(
          _userProfile?.username.substring(0, 1).toUpperCase() ?? 'U',
          style: const TextStyle(
            fontSize: 60,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ==================== STATS CARDS ====================
  Widget _buildStatsCards(bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.monitor_weight_outlined,
            label: 'Weight',
            value: _userProfile?.currentWeight != null 
                ? _userProfile!.currentWeight!.toStringAsFixed(1) 
                : 'N/A',
            unit: 'kg',
            isDarkMode: isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.height,
            label: 'Height',
            value: _userProfile?.height != null 
                ? _userProfile!.height!.toStringAsFixed(0) 
                : 'N/A',
            unit: 'cm',
            isDarkMode: isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.favorite_outline,
            label: 'BMI',
            value: _userProfile?.bmi != null 
                ? _userProfile!.bmi!.toStringAsFixed(1)
                : 'N/A',
            unit: '',
            isDarkMode: isDarkMode,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required bool isDarkMode,
  }) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: const Color(0xFF1DAB87),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7E7E7E),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 1),
                  child: Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7E7E7E),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== BMI CHART ====================
  Widget _buildBMIChart(bool isDarkMode) {
    if (_chartData.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'No BMI data available',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF7E7E7E),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_userProfile?.bmi != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current BMI',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7E7E7E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _userProfile!.bmi!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1DAB87),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getBMIColor(_userProfile!.bmi!).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _userProfile!.bmiCategory ?? 'Normal',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getBMIColor(_userProfile!.bmi!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x261DAB87),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Last 7 Days',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF038866),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0x4C979797),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF979797),
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        final index = value.toInt();
                        if (index >= 0 && index < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              days[index],
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF979797),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: const Color(0xFF1DAB87).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                minX: 0,
                maxX: 6,
                minY: 15,
                maxY: 35,
                lineBarsData: [
                  LineChartBarData(
                    spots: _chartData,
                    isCurved: true,
                    color: const Color(0xFF1DAB87),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xFF1DAB87),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF1DAB87).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  // ==================== SETTINGS SECTION ====================
  Widget _buildSettingsSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0x26D9D9D9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            onTap: () => _onEditProfile(),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            icon: Icons.emoji_events_outlined,
            title: 'My Achievements / Badges',
            onTap: () => _onAchievements(),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () => _onNotifications(),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF979797),
            ),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () => _onHelpSupport(),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF979797),
            ),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            trailing: _buildToggleSwitch(
              value: isDarkMode,
              onChanged: (value) {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
            ),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: '($selectedLanguage)',
            onTap: () => _onLanguageSelect(),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF979797),
            ),
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () => _onLogout(),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.red,
            ),
            titleColor: Colors.red,
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color? titleColor,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: (titleColor ?? const Color(0xFF1DAB87)).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: titleColor ?? const Color(0xFF1DAB87),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? (isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                  if (subtitle != null)
                    TextSpan(
                      text: ' $subtitle',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xCE7E7E7E),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildToggleSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 44,
        height: 25,
        decoration: BoxDecoration(
          color: value ? const Color(0xFF1DAB87) : const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== HANDLERS ====================

  void _onAchievements() {
    print('🎯 Showing ${_userBadges.length} badges');
    _showAchievementsDialog();
  }

  Future<void> _onEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );
    
    if (result == true) {
      _loadProfileData();
    }
  }

  void _onNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ),
    );
  }

  void _onHelpSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HelpSupportScreen(),
      ),
    );
  }

  void _onLanguageSelect() {
    _showLanguageDialog();
  }

  void _onLogout() {
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Logout',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handleLogout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF1DAB87),
          ),
        ),
      );

      await SupabaseConfig.client.auth.signOut();

      if (mounted) Navigator.pop(context);

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/welcome',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      
      print('Logout error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to logout: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAchievementsDialog() {
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'My Achievements',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_userBadges.length} badges earned',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF7E7E7E),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _userBadges.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.emoji_events_outlined,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No achievements yet!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7E7E7E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Keep working out to earn badges.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7E7E7E),
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: _userBadges.length,
                      itemBuilder: (context, index) {
                        return _buildAchievementBadge(_userBadges[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(UserBadgeModel userBadge) {
    final badge = userBadge.badge;
    if (badge == null) return const SizedBox.shrink();
    
    // Try to get local asset path
    final assetPath = BadgeIcons.getAssetPath(badge.badgeName);
    
    return GestureDetector(
      onTap: () => _showBadgeDetail(badge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF1DAB87),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1DAB87).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: assetPath != null
                  ? Image.asset(
                      assetPath,
                      color: Colors.white,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 35,
                        );
                      },
                    )
                  : (badge.iconUrl != null && badge.iconUrl!.isNotEmpty
                      ? Image.network(
                          badge.iconUrl!,
                          color: Colors.white,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.emoji_events,
                              color: Colors.white,
                              size: 35,
                            );
                          },
                        )
                      : const Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 35,
                        )),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.badgeName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showBadgeDetail(dynamic badge) {
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF1DAB87),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                badge.badgeName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              badge.description ?? 'Achievement unlocked!',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            if (badge.requirementDescription != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1DAB87).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF1DAB87),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        badge.requirementDescription,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1DAB87),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(
                color: Color(0xFF1DAB87),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Select Language',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English', isDarkMode),
            _buildLanguageOption('Sinhala', isDarkMode),
            _buildLanguageOption('Tamil', isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language, bool isDarkMode) {
    final isSelected = selectedLanguage == language;
    return ListTile(
      title: Text(
        language,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFF1DAB87))
          : null,
      onTap: () {
        setState(() {
          selectedLanguage = language;
        });
        Navigator.pop(context);
      },
    );
  }
}