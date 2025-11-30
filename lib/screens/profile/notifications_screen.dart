import 'package:flutter/material.dart';
import 'package:powerhouse/widgets/animated_message.dart';
import 'package:provider/provider.dart';
import 'package:powerhouse/core/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:powerhouse/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
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

  // Daily Tips
  bool _dailyTipsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load daily tips settings
      _dailyTipsEnabled = prefs.getBool('daily_tips_enabled') ?? false;
      final hour = prefs.getInt('notification_hour') ?? 9;
      final minute = prefs.getInt('notification_minute') ?? 0;
      _notificationTime = TimeOfDay(hour: hour, minute: minute);

      // Load workout reminder settings
      _workoutReminders = prefs.getBool('workout_reminders') ?? true;
      _workoutReminderTime =
          prefs.getString('workout_reminder_time') ?? '07:00 AM';

      // Load meal reminder settings
      _mealReminders = prefs.getBool('meal_reminders') ?? true;
      _breakfastTime = prefs.getString('breakfast_time') ?? '08:00 AM';
      _lunchTime = prefs.getString('lunch_time') ?? '12:30 PM';
      _dinnerTime = prefs.getString('dinner_time') ?? '07:00 PM';

      // Load water reminder settings
      _waterReminders = prefs.getBool('water_reminders') ?? true;

      // Load progress report settings
      _weeklyProgressReport = prefs.getBool('weekly_progress_report') ?? true;
      _weeklyReportDay = prefs.getString('weekly_report_day') ?? 'Sunday';
      _monthlyReport = prefs.getBool('monthly_report') ?? true;

      setState(() {
        _isLoading = false;
      });
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
        child: CircularProgressIndicator(color: Color(0xFF1DAB87)),
      ),
    );

    // Simulate saving
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      Navigator.pop(context); // Close loading

      AnimatedMessage.show(
        context,
        message: 'Notification settings saved!',
        backgroundColor: Color(0xFF1DAB87),
        icon: Icons.check_circle_rounded,
        duration: const Duration(seconds: 2),
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
          child: CircularProgressIndicator(color: Color(0xFF1DAB87)),
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
            onChanged: (value) async {
              if (value) {
                final time = await _parseTimeString(_workoutReminderTime);
                await NotificationService().scheduleWorkoutReminder(
                  hour: time.hour,
                  minute: time.minute,
                );
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('workout_reminders', true);
                if (mounted) {
                  AnimatedMessage.show(
                    context,
                    message: 'Workout reminders enabled!',
                    backgroundColor: Color(0xFF1DAB87),
                    icon: Icons.check_circle_rounded,
                    duration: const Duration(seconds: 2),
                  );
                }
              } else {
                await NotificationService().cancelWorkoutReminder();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('workout_reminders', false);
              }
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
              onTap: () =>
                  _selectTime(context, _workoutReminderTime, (newTime) async {
                    setState(() {
                      _workoutReminderTime = newTime;
                    });
                    // Save and reschedule immediately
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('workout_reminder_time', newTime);
                    if (_workoutReminders) {
                      final time = await _parseTimeString(newTime);
                      await NotificationService().scheduleWorkoutReminder(
                        hour: time.hour,
                        minute: time.minute,
                      );
                    }
                  }),
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
            onChanged: (value) async {
              if (value) {
                final breakfast = await _parseTimeString(_breakfastTime);
                final lunch = await _parseTimeString(_lunchTime);
                final dinner = await _parseTimeString(_dinnerTime);

                await NotificationService().scheduleMealReminders(
                  breakfastHour: breakfast.hour,
                  breakfastMinute: breakfast.minute,
                  lunchHour: lunch.hour,
                  lunchMinute: lunch.minute,
                  dinnerHour: dinner.hour,
                  dinnerMinute: dinner.minute,
                );
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('meal_reminders', true);
                if (mounted) {
                  AnimatedMessage.show(
                    context,
                    message: 'Meal reminders enabled!',
                    backgroundColor: Color(0xFF1DAB87),
                    icon: Icons.check_circle_rounded,
                    duration: const Duration(seconds: 2),
                  );
                }
              } else {
                await NotificationService().cancelMealReminders();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('meal_reminders', false);
              }
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
              onTap: () =>
                  _selectTime(context, _breakfastTime, (newTime) async {
                    setState(() {
                      _breakfastTime = newTime;
                    });
                    // Save and reschedule immediately
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('breakfast_time', newTime);
                    if (_mealReminders) {
                      final breakfast = await _parseTimeString(_breakfastTime);
                      final lunch = await _parseTimeString(_lunchTime);
                      final dinner = await _parseTimeString(_dinnerTime);
                      await NotificationService().scheduleMealReminders(
                        breakfastHour: breakfast.hour,
                        breakfastMinute: breakfast.minute,
                        lunchHour: lunch.hour,
                        lunchMinute: lunch.minute,
                        dinnerHour: dinner.hour,
                        dinnerMinute: dinner.minute,
                      );
                    }
                  }),
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 8),
            _buildTimePicker(
              title: 'Lunch Time',
              time: _lunchTime,
              onTap: () => _selectTime(context, _lunchTime, (newTime) async {
                setState(() {
                  _lunchTime = newTime;
                });
                // Save and reschedule immediately
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('lunch_time', newTime);
                if (_mealReminders) {
                  final breakfast = await _parseTimeString(_breakfastTime);
                  final lunch = await _parseTimeString(_lunchTime);
                  final dinner = await _parseTimeString(_dinnerTime);
                  await NotificationService().scheduleMealReminders(
                    breakfastHour: breakfast.hour,
                    breakfastMinute: breakfast.minute,
                    lunchHour: lunch.hour,
                    lunchMinute: lunch.minute,
                    dinnerHour: dinner.hour,
                    dinnerMinute: dinner.minute,
                  );
                }
              }),
              isDarkMode: isDarkMode,
            ),
            const SizedBox(height: 8),
            _buildTimePicker(
              title: 'Dinner Time',
              time: _dinnerTime,
              onTap: () => _selectTime(context, _dinnerTime, (newTime) async {
                setState(() {
                  _dinnerTime = newTime;
                });
                // Save and reschedule immediately
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('dinner_time', newTime);
                if (_mealReminders) {
                  final breakfast = await _parseTimeString(_breakfastTime);
                  final lunch = await _parseTimeString(_lunchTime);
                  final dinner = await _parseTimeString(_dinnerTime);
                  await NotificationService().scheduleMealReminders(
                    breakfastHour: breakfast.hour,
                    breakfastMinute: breakfast.minute,
                    lunchHour: lunch.hour,
                    lunchMinute: lunch.minute,
                    dinnerHour: dinner.hour,
                    dinnerMinute: dinner.minute,
                  );
                }
              }),
              isDarkMode: isDarkMode,
            ),
          ],

          const SizedBox(height: 12),

          _buildSwitchTile(
            title: 'Water Reminders',
            subtitle: 'Hourly reminders to drink water',
            value: _waterReminders,
            onChanged: (value) async {
              if (value) {
                await NotificationService().scheduleWaterReminders();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('water_reminders', true);
                if (mounted) {
                  AnimatedMessage.show(
                    context,
                    message: 'Water reminders enabled!',
                    backgroundColor: Color(0xFF1DAB87),
                    icon: Icons.check_circle_rounded,
                    duration: const Duration(seconds: 2),
                  );
                }
              } else {
                await NotificationService().cancelWaterReminders();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('water_reminders', false);
              }
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
            onChanged: (value) async {
              if (value) {
                final dayOfWeek = _getDayOfWeekNumber(_weeklyReportDay);
                await NotificationService().scheduleWeeklyReport(
                  dayOfWeek: dayOfWeek,
                );
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('weekly_progress_report', true);
                if (mounted) {
                  AnimatedMessage.show(
                    context,
                    message: 'Weekly reports enabled!',
                    backgroundColor: Color(0xFF1DAB87),
                    icon: Icons.check_circle_rounded,
                    duration: const Duration(seconds: 2),
                  );
                }
              } else {
                await NotificationService().cancelWeeklyReport();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('weekly_progress_report', false);
              }
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
              items: [
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday',
              ],
              onChanged: (value) async {
                setState(() {
                  _weeklyReportDay = value!;
                });
                // Save and reschedule immediately
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('weekly_report_day', value!);
                if (_weeklyProgressReport) {
                  final dayOfWeek = _getDayOfWeekNumber(value);
                  await NotificationService().scheduleWeeklyReport(
                    dayOfWeek: dayOfWeek,
                  );
                }
              },
              isDarkMode: isDarkMode,
            ),
          ],

          const SizedBox(height: 12),

          _buildSwitchTile(
            title: 'Monthly Progress Report',
            subtitle: 'Summary of your monthly progress',
            value: _monthlyReport,
            onChanged: (value) async {
              if (value) {
                await NotificationService().scheduleMonthlyReport();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('monthly_report', true);
                if (mounted) {
                  AnimatedMessage.show(
                    context,
                    message: 'Monthly reports enabled!',
                    backgroundColor: Color(0xFF1DAB87),
                    icon: Icons.check_circle_rounded,
                    duration: const Duration(seconds: 2),
                  );
                }
              } else {
                await NotificationService().cancelMonthlyReport();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('monthly_report', false);
              }
              setState(() {
                _monthlyReport = value;
              });
            },
            icon: Icons.calendar_month,
            isDarkMode: isDarkMode,
          ),

          const SizedBox(height: 24),

          // Daily Tips Section
          _buildSectionTitle('Daily Tips', isDarkMode),
          const SizedBox(height: 16),
          _buildSwitchTile(
            title: 'Daily Fitness Tips',
            subtitle: _dailyTipsEnabled
                ? 'Enabled at ${_notificationTime.format(context)}'
                : 'Get daily fitness tips and educational content',
            value: _dailyTipsEnabled,
            onChanged: (value) async {
              if (value) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _notificationTime,
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

                if (time != null) {
                  setState(() {
                    _dailyTipsEnabled = true;
                    _notificationTime = time;
                  });

                  await NotificationService().scheduleDailyTipNotification(
                    hour: time.hour,
                    minute: time.minute,
                  );

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('daily_tips_enabled', true);
                  await prefs.setInt('notification_hour', time.hour);
                  await prefs.setInt('notification_minute', time.minute);

                  if (mounted) {
                    AnimatedMessage.show(
                      context,
                      message: 'Daily tip notifications enabled!',
                      backgroundColor: Color(0xFF1DAB87),
                      icon: Icons.check_circle_rounded,
                      duration: const Duration(seconds: 2),
                    );
                  }
                }
              } else {
                setState(() => _dailyTipsEnabled = false);
                await NotificationService().cancelDailyNotifications();

                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('daily_tips_enabled', false);

                if (mounted) {
                  AnimatedMessage.show(
                    context,
                    message: 'Daily tip notifications disabled',
                    backgroundColor: Colors.grey,
                    icon: Icons.error,
                    duration: const Duration(seconds: 2),
                  );
                }
              }
            },
            icon: Icons.lightbulb_outline,
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
          border: Border.all(color: const Color(0xFF1DAB87).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Color(0xFF1DAB87)),
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
        border: Border.all(color: const Color(0xFF1DAB87).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Color(0xFF1DAB87), size: 20),
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
              return DropdownMenuItem<String>(value: item, child: Text(item));
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
            colorScheme: const ColorScheme.light(primary: Color(0xFF1DAB87)),
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
              backgroundColor: isDarkMode
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
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
                      _dailyTipsEnabled = false;
                    });
                    AnimatedMessage.show(
                      context,
                      message: 'Settings reset to default',
                      backgroundColor: Color(0xFF1DAB87),
                      icon: Icons.check_circle_rounded,
                      duration: const Duration(seconds: 2),
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

  // Helper method to parse time string like "07:00 AM" to TimeOfDay
  Future<TimeOfDay> _parseTimeString(String timeString) async {
    final parts = timeString.split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final isPM = parts[1] == 'PM';

    if (isPM && hour != 12) {
      hour += 12;
    } else if (!isPM && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  // Helper method to convert day name to day of week number (1 = Monday, 7 = Sunday)
  int _getDayOfWeekNumber(String dayName) {
    switch (dayName) {
      case 'Monday':
        return 1;
      case 'Tuesday':
        return 2;
      case 'Wednesday':
        return 3;
      case 'Thursday':
        return 4;
      case 'Friday':
        return 5;
      case 'Saturday':
        return 6;
      case 'Sunday':
        return 7;
      default:
        return 7; // Default to Sunday
    }
  }
}
