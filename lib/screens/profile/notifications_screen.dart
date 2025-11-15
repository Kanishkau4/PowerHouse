import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powerhouse/services/user_service.dart';
import 'package:powerhouse/core/theme/theme_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _userService = UserService();
  
  // General Notifications
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  
  // Workout Notifications
  bool _workoutReminders = true;
  bool _restDayReminders = true;
  bool _workoutCompletionCelebration = true;
  String _workoutReminderTime = '07:00 AM';
  
  // Nutrition Notifications
  bool _mealReminders = true;
  bool _waterReminders = true;
  bool _calorieGoalReminders = true;
  String _breakfastTime = '08:00 AM';
  String _lunchTime = '12:30 PM';
  String _dinnerTime = '07:00 PM';
  
  // Challenge & Progress Notifications
  bool _challengeUpdates = true;
  bool _challengeStartReminders = true;
  bool _challengeDeadlineReminders = true;
  bool _achievementNotifications = true;
  bool _levelUpNotifications = true;
  bool _xpMilestoneNotifications = true;
  
  // Social Notifications
  bool _socialNotifications = false;
  bool _friendRequestNotifications = true;
  bool _commentNotifications = true;
  bool _likeNotifications = false;
  
  // Weekly Summary
  bool _weeklyProgressReport = true;
  bool _monthlyReport = true;
  String _weeklyReportDay = 'Sunday';
  
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
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1DAB87),
        ),
      ),
    );

    // Simulate saving
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      Navigator.pop(context); // Close loading
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Notification settings saved!'),
          backgroundColor: Color(0xFF1DAB87),
          duration: Duration(seconds: 2),
        ),
      );
      
      Navigator.pop(context);
    }
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
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
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
          // General Notifications
          _buildSectionTitle('General Notifications', isDarkMode),
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
            isDarkMode: isDarkMode,
          ),
          
          const SizedBox(height: 12),
          
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
            isDarkMode: isDarkMode,
          ),
          
          const SizedBox(height: 12),
          
          _buildSwitchTile(
            title: 'SMS Notifications',
            subtitle: 'Receive text message alerts',
            value: _smsNotifications,
            onChanged: (value) {
              setState(() {
                _smsNotifications = value;
              });
            },
            icon: Icons.sms_outlined,
            isDarkMode: isDarkMode,
          ),
          
          const SizedBox(height: 24),
          
          // Workout Notifications
          _buildSectionTitle('Workout Notifications', isDarkMode),
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
            isDarkMode: isDarkMode,
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
              isDarkMode: isDarkMode,
            ),
          ],
          
          const SizedBox(height: 12),
          
          _buildSwitchTile(
            title: 'Rest Day Reminders',
            subtitle: 'Reminders to take rest days',
            value: _restDayReminders,
            onChanged: (value) {
              setState(() {
                _restDayReminders = value;
              });
            },
            icon: Icons.hotel_outlined,
            isDarkMode: isDarkMode,
          ),
          
          const SizedBox(height: 12),
          
          _buildSwitchTile(
            title: 'Workout Completion',
            subtitle: 'Celebrate when you complete workouts',
            value: _workoutCompletionCelebration,
            onChanged: (value) {
              setState(() {
                _workoutCompletionCelebration = value;
              });
            },
            icon: Icons.celebration_outlined,
            isDarkMode: isDarkMode,
          ),
          
          const SizedBox(height: 24),
          
          // Nutrition Notifications
          _buildSectionTitle('Nutrition Notifications', isDarkMode),
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
            isDarkMode: isDarkMode,
          ),
          
          if (_mealReminders) ...[
            const SizedBox(height: 12),
            _buildTimePicker(
              title: 'Breakfast Time',
              time: _breakfastTime,
              onTap: () => _selectTime(
                context,
                _breakfastTime,
                (newTime) {
                  setState(() {
                    _breakfastTime = newTime;
                  });
                },
              ),
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 8),
            _buildTimePicker(
              title: 'Lunch Time',
              time: _lunchTime,
              onTap: () => _selectTime(
                context,
                _lunchTime,
                (newTime) {
                  setState(() {
                    _lunchTime = newTime;
                  });
                },
              ),
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 8),
            _buildTimePicker(
              title: 'Dinner Time',
              time: _dinnerTime,
              onTap: () => _selectTime(
                context,
                _dinnerTime,
                (newTime) {
                  setState(() {
                    _dinnerTime = newTime;
                  });
                },
              ),
              isDarkMode: isDarkMode,
            ),
          ],
          
          const SizedBox(height: 12),
          
          _buildSwitchTile(
            title: 'Water Reminders',
            subtitle: 'Hourly reminders to drink water',
            value: _waterReminders,
            onChanged: (value) {
              setState(() {
                _waterReminders = value;
              });
            },
            icon: Icons.water_drop_outlined,
            isDarkMode: isDarkMode,
          ),
          
          const SizedBox(height: 12),
          
          _buildSwitchTile(
            title: 'Calorie Goal Reminders',
            subtitle: 'Alerts when approaching daily calorie goal',
            value: _calorieGoalReminders,
            onChanged: (value) {
              setState(() {
                _calorieGoalReminders = value;
              });
            },
            icon: Icons.local_fire_department,
            isDarkMode: isDarkMode,
          ),
          
          const SizedBox(height: 24),
          
          // Challenge & Progress Notifications
          _buildSectionTitle('Challenges & Progress', isDarkMode),
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
            isDarkMode: isDarkMode,
          ),
          
          const SizedBox(height: 12),
          
          _buildSwitchTile(
            title: 'Challenge Start Reminders',
            subtitle: 'When new challenges become available',
            value: _challengeStartReminders,
            onChanged: (value) {
              setState(() {
                _challengeStartReminders = value;
              });
            },
            icon: Icons.flag_outlined,
            isDarkMode: isDarkMode,
          ),
          
          const SizedBox(height: 12),
          
          _buildSwitchTile(
            title: 'Challenge Deadline Alerts',
            subtitle: 'Reminders before challenge deadlines',
            value: _challengeDeadlineReminders,
            onChanged: (value) {
              setState(() {
                _challengeDeadlineReminders = value;
              });
            },
            icon: Icons.alarm,
            isDarkMode: isDarkMode,
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
            isDarkMode: isDarkMode,
          ),
          
          const SizedBox(height: 12),
          
          _buildSwitchTile(
            title: 'Level Up Notifications',
            subtitle: 'When you reach a new level',
            value: _levelUpNotifications,
            onChanged: (value) {
              setState(() {
                _levelUpNotifications = value;
              });
            },
            icon: Icons.trending_up,
            isDarkMode: isDarkMode,
          ),
          
          const SizedBox(height: 12),
          
          _buildSwitchTile(
            title: 'XP Milestone Alerts',
            subtitle: 'When you reach XP milestones',
            value: _xpMilestoneNotifications,
            onChanged: (value) {
              setState(() {
                _xpMilestoneNotifications = value;
              });
            },
            icon: Icons.stars,
            isDarkMode: isDarkMode,
          ),
          
          const SizedBox(height: 24),
          
          // Social Notifications
          _buildSectionTitle('Social Notifications', isDarkMode),
          const SizedBox(height: 16),
          
          _buildSwitchTile(
            title: 'Social Notifications',
            subtitle: 'All social activity notifications',
            value: _socialNotifications,
            onChanged: (value) {
              setState(() {
                _socialNotifications = value;
              });
            },
            icon: Icons.people,
            isDarkMode: isDarkMode,
          ),
          
          if (_socialNotifications) ...[
            const SizedBox(height: 12),
            _buildSwitchTile(
              title: 'Friend Requests',
              subtitle: 'When someone sends you a friend request',
              value: _friendRequestNotifications,
              onChanged: (value) {
                setState(() {
                  _friendRequestNotifications = value;
                });
              },
              icon: Icons.person_add,
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              title: 'Comments',
              subtitle: 'When someone comments on your posts',
              value: _commentNotifications,
              onChanged: (value) {
                setState(() {
                  _commentNotifications = value;
                });
              },
              icon: Icons.comment,
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              title: 'Likes',
              subtitle: 'When someone likes your posts',
              value: _likeNotifications,
              onChanged: (value) {
                setState(() {
                  _likeNotifications = value;
                });
              },
              icon: Icons.favorite,
              isDarkMode: isDarkMode,
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Reports
          _buildSectionTitle('Progress Reports', isDarkMode),
          const SizedBox(height: 16),
          
          _buildSwitchTile(
            title: 'Weekly Progress Report',
            subtitle: 'Summary of your weekly progress',
            value: _weeklyProgressReport,
            onChanged: (value) {
              setState(() {
                _weeklyProgressReport = value;
              });
            },
            icon: Icons.assessment,
            isDarkMode: isDarkMode,
          ),
          
          if (_weeklyProgressReport) ...[
            const SizedBox(height: 12),
            _buildDropdownPicker(
              title: 'Report Day',
              value: _weeklyReportDay,
              items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
              onChanged: (value) {
                setState(() {
                  _weeklyReportDay = value!;
                });
              },
              isDarkMode: isDarkMode,
            ),
          ],
          
          const SizedBox(height: 12),
          
          _buildSwitchTile(
            title: 'Monthly Progress Report',
            subtitle: 'Summary of your monthly progress',
            value: _monthlyReport,
            onChanged: (value) {
              setState(() {
                _monthlyReport = value;
              });
            },
            icon: Icons.calendar_month,
            isDarkMode: isDarkMode,
          ),
          
          const SizedBox(height: 32),
          
          // Save Button
          _buildSaveButton(),
          
          const SizedBox(height: 16),
          
          // Reset to Default Button
          _buildResetButton(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black,
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
            activeColor: const Color(0xFF1DAB87),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker({
    required String title,
    required String time,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
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
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black,
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

  Widget _buildDropdownPicker({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1DAB87).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today,
            color: Color(0xFF1DAB87),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            dropdownColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1DAB87),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
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

  Widget _buildResetButton(bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Reset to Default',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              content: Text(
                'Are you sure you want to reset all notification settings to default?',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      // Reset all to defaults
                      _pushNotifications = true;
                      _workoutReminders = true;
                      _mealReminders = true;
                      _waterReminders = true;
                      _challengeUpdates = true;
                      _achievementNotifications = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings reset to default'),
                        backgroundColor: Color(0xFF1DAB87),
                      ),
                    );
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF1DAB87)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          'Reset to Default',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}