import 'package:flutter/material.dart';
import 'package:powerhouse/services/user_service.dart';
import 'package:powerhouse/models/user_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _userService = UserService();
  
  // Notification settings
  bool _workoutReminders = true;
  bool _mealReminders = true;
  bool _challengeUpdates = true;
  bool _achievementNotifications = true;
  bool _socialNotifications = false;
  bool _emailNotifications = true;
  bool _pushNotifications = true;

  String _workoutReminderTime = '07:00 AM';
  String _mealReminderTime = '12:00 PM';
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final user = await _userService.getCurrentUserProfile();
      if (user != null) {
        // In a real app, these settings would be stored in the database
        // For now, we'll use default values
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading notification settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveNotificationSettings() async {
    // In a real app, these settings would be saved to the database
    // For now, we'll just show a success message
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Notification settings saved!'),
          backgroundColor: Color(0xFF1DAB87),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF1DAB87),
          ),
        ),
      );
    }
    
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
          'Notifications',
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
          // Push Notifications Section
          _buildSectionTitle('Push Notifications'),
          const SizedBox(height: 16),
          
          _buildSwitchTile(
            title: 'Push Notifications',
            subtitle: 'Receive notifications on your device',
            value: _pushNotifications,
            onChanged: (value) {
              setState(() {
                _pushNotifications = value;
              });
            },
            icon: Icons.notifications_active_outlined,
          ),
          
          const SizedBox(height: 24),
          
          // Workout Notifications
          _buildSectionTitle('Workout Notifications'),
          const SizedBox(height: 16),
          
          _buildSwitchTile(
            title: 'Workout Reminders',
            subtitle: 'Daily reminders to complete your workout',
            value: _workoutReminders,
            onChanged: (value) {
              setState(() {
                _workoutReminders = value;
              });
            },
            icon: Icons.fitness_center,
          ),
          
          if (_workoutReminders) ...[
            const SizedBox(height: 12),
            _buildTimePicker(
              title: 'Reminder Time',
              time: _workoutReminderTime,
              onTap: () => _selectTime(
                context,
                _workoutReminderTime,
                (newTime) {
                  setState(() {
                    _workoutReminderTime = newTime;
                  });
                },
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Nutrition Notifications
          _buildSectionTitle('Nutrition Notifications'),
          const SizedBox(height: 16),
          
          _buildSwitchTile(
            title: 'Meal Reminders',
            subtitle: 'Reminders to log your meals',
            value: _mealReminders,
            onChanged: (value) {
              setState(() {
                _mealReminders = value;
              });
            },
            icon: Icons.restaurant,
          ),
          
          if (_mealReminders) ...[
            const SizedBox(height: 12),
            _buildTimePicker(
              title: 'Meal Reminder Time',
              time: _mealReminderTime,
              onTap: () => _selectTime(
                context,
                _mealReminderTime,
                (newTime) {
                  setState(() {
                    _mealReminderTime = newTime;
                  });
                },
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Activity Notifications
          _buildSectionTitle('Activity Notifications'),
          const SizedBox(height: 16),
          
          _buildSwitchTile(
            title: 'Challenge Updates',
            subtitle: 'Updates on your active challenges',
            value: _challengeUpdates,
            onChanged: (value) {
              setState(() {
                _challengeUpdates = value;
              });
            },
            icon: Icons.emoji_events,
          ),
          
          const SizedBox(height: 12),
          
          _buildSwitchTile(
            title: 'Achievement Notifications',
            subtitle: 'When you unlock new achievements',
            value: _achievementNotifications,
            onChanged: (value) {
              setState(() {
                _achievementNotifications = value;
              });
            },
            icon: Icons.military_tech,
          ),
          
          const SizedBox(height: 12),
          
          _buildSwitchTile(
            title: 'Social Notifications',
            subtitle: 'Friend requests and mentions',
            value: _socialNotifications,
            onChanged: (value) {
              setState(() {
                _socialNotifications = value;
              });
            },
            icon: Icons.people,
          ),
          
          const SizedBox(height: 24),
          
          // Email Notifications
          _buildSectionTitle('Email Notifications'),
          const SizedBox(height: 16),
          
          _buildSwitchTile(
            title: 'Email Notifications',
            subtitle: 'Receive updates via email',
            value: _emailNotifications,
            onChanged: (value) {
              setState(() {
                _emailNotifications = value;
              });
            },
            icon: Icons.email_outlined,
          ),
          
          const SizedBox(height: 32),
          
          // Save Button
          _buildSaveButton(),
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

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: value
                  ? const Color(0xFF1DAB87).withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: value ? const Color(0xFF1DAB87) : Colors.grey,
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
                    fontWeight: FontWeight.w600,
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF1DAB87),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker({
    required String title,
    required String time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF1DAB87).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time,
              color: Color(0xFF1DAB87),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1DAB87),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF7E7E7E),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    String currentTime,
    Function(String) onTimeSelected,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1DAB87),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final String formattedTime = picked.format(context);
      onTimeSelected(formattedTime);
    }
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveNotificationSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1DAB87),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: const Text(
          'Save Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}