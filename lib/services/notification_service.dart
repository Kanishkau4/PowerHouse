import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Notification IDs
  static const int dailyTipId = 0;
  static const int workoutReminderId = 1;
  static const int breakfastReminderId = 2;
  static const int lunchReminderId = 3;
  static const int dinnerReminderId = 4;
  static const int waterReminderId = 5;
  static const int weeklyReportId = 6;
  static const int monthlyReportId = 7;
  static const int challengeStartId = 8;
  static const int challengeDeadlineId = 9;
  static const int inactivityReminderId = 10;

  Future<void> initialize() async {
    try {
      print('🔔 Initializing notification service...');
      tz.initializeTimeZones();
      tz.setLocalLocation(
        tz.getLocation('Asia/Kolkata'),
      ); // Set to Indian timezone
      print('✅ Timezone initialized: ${tz.local.name}');

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      print('✅ Notification service initialized: $initialized');
    } catch (e) {
      print('❌ Error initializing notification service: $e');
      rethrow;
    }
  }

  Future<void> requestPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();
    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // ==================== DAILY TIPS ====================
  Future<void> scheduleDailyTipNotification({
    required int hour,
    required int minute,
  }) async {
    try {
      print('🔔 Scheduling daily tip notification for $hour:$minute');
      await _notifications.cancel(dailyTipId);

      final scheduledTime = _nextInstanceOfTime(hour, minute);
      print('📅 Next notification scheduled for: $scheduledTime');

      await _notifications.zonedSchedule(
        dailyTipId,
        '💪 Daily Fitness Tip',
        'Tap to discover today\'s fitness wisdom!',
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_tips',
            'Daily Tips',
            channelDescription: 'Daily fitness tips and educational content',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/ic_notification_custom',
            color: Color(0xFF1DAB87),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('✅ Daily tip notification scheduled successfully!');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
      rethrow;
    }
  }

  Future<void> cancelDailyNotifications() async {
    await _notifications.cancel(dailyTipId);
  }

  // ==================== WORKOUT REMINDERS ====================
  Future<void> scheduleWorkoutReminder({
    required int hour,
    required int minute,
  }) async {
    try {
      print('🔔 Scheduling workout reminder for $hour:$minute');
      await _notifications.cancel(workoutReminderId);

      final scheduledTime = _nextInstanceOfTime(hour, minute);

      await _notifications.zonedSchedule(
        workoutReminderId,
        '🏋️ Workout Time!',
        'Time to crush your workout goals! Let\'s get moving! 💪',
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'workout_reminders',
            'Workout Reminders',
            channelDescription: 'Daily reminders to complete your workout',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/ic_notification_custom',
            color: Color(0xFF1DAB87),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('✅ Workout reminder scheduled successfully!');
    } catch (e) {
      print('❌ Error scheduling workout reminder: $e');
      rethrow;
    }
  }

  Future<void> cancelWorkoutReminder() async {
    await _notifications.cancel(workoutReminderId);
  }

  // ==================== MEAL REMINDERS ====================
  Future<void> scheduleMealReminders({
    required int breakfastHour,
    required int breakfastMinute,
    required int lunchHour,
    required int lunchMinute,
    required int dinnerHour,
    required int dinnerMinute,
  }) async {
    try {
      print('🔔 Scheduling meal reminders...');

      // Breakfast
      final breakfastTime = _nextInstanceOfTime(breakfastHour, breakfastMinute);
      await _notifications.zonedSchedule(
        breakfastReminderId,
        '🍳 Breakfast Time!',
        'Don\'t forget to log your breakfast and fuel your day!',
        breakfastTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'meal_reminders',
            'Meal Reminders',
            channelDescription: 'Reminders to log your meals',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/ic_notification_custom',
            color: Color(0xFF1DAB87),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // Lunch
      final lunchTime = _nextInstanceOfTime(lunchHour, lunchMinute);
      await _notifications.zonedSchedule(
        lunchReminderId,
        '🥗 Lunch Time!',
        'Time to refuel! Remember to log your lunch.',
        lunchTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'meal_reminders',
            'Meal Reminders',
            channelDescription: 'Reminders to log your meals',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/ic_notification_custom',
            color: Color(0xFF1DAB87),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // Dinner
      final dinnerTime = _nextInstanceOfTime(dinnerHour, dinnerMinute);
      await _notifications.zonedSchedule(
        dinnerReminderId,
        '🍽️ Dinner Time!',
        'End your day right! Don\'t forget to log your dinner.',
        dinnerTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'meal_reminders',
            'Meal Reminders',
            channelDescription: 'Reminders to log your meals',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/ic_notification_custom',
            color: Color(0xFF1DAB87),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('✅ All meal reminders scheduled successfully!');
    } catch (e) {
      print('❌ Error scheduling meal reminders: $e');
      rethrow;
    }
  }

  Future<void> cancelMealReminders() async {
    await _notifications.cancel(breakfastReminderId);
    await _notifications.cancel(lunchReminderId);
    await _notifications.cancel(dinnerReminderId);
  }

  // ==================== WATER REMINDERS ====================
  Future<void> scheduleWaterReminders() async {
    try {
      print('🔔 Scheduling hourly water reminders...');

      // Schedule water reminders every 2 hours from 8 AM to 8 PM
      final reminderTimes = [8, 10, 12, 14, 16, 18, 20];

      for (int i = 0; i < reminderTimes.length; i++) {
        final hour = reminderTimes[i];
        final scheduledTime = _nextInstanceOfTime(hour, 0);

        await _notifications.zonedSchedule(
          waterReminderId + i, // Unique ID for each water reminder
          '💧 Hydration Check!',
          'Time to drink some water! Stay hydrated! 🚰',
          scheduledTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'water_reminders',
              'Water Reminders',
              channelDescription: 'Hourly reminders to drink water',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
              icon: '@drawable/ic_notification_custom',
              color: Color(0xFF1DAB87),
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }

      print('✅ Water reminders scheduled successfully!');
    } catch (e) {
      print('❌ Error scheduling water reminders: $e');
      rethrow;
    }
  }

  Future<void> cancelWaterReminders() async {
    // Cancel all 7 water reminder notifications
    for (int i = 0; i < 7; i++) {
      await _notifications.cancel(waterReminderId + i);
    }
  }

  // ==================== WEEKLY PROGRESS REPORT ====================
  Future<void> scheduleWeeklyReport({required int dayOfWeek}) async {
    try {
      print('🔔 Scheduling weekly progress report for day $dayOfWeek');

      final scheduledTime = _nextInstanceOfWeekday(dayOfWeek, 9, 0); // 9 AM

      await _notifications.zonedSchedule(
        weeklyReportId,
        '📊 Weekly Progress Report',
        'Your weekly fitness summary is ready! Tap to view your progress.',
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'progress_reports',
            'Progress Reports',
            channelDescription: 'Weekly and monthly progress summaries',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/ic_notification_custom',
            color: Color(0xFF1DAB87),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );

      print('✅ Weekly report scheduled successfully!');
    } catch (e) {
      print('❌ Error scheduling weekly report: $e');
      rethrow;
    }
  }

  Future<void> cancelWeeklyReport() async {
    await _notifications.cancel(weeklyReportId);
  }

  // ==================== MONTHLY PROGRESS REPORT ====================
  Future<void> scheduleMonthlyReport() async {
    try {
      print('🔔 Scheduling monthly progress report...');

      final scheduledTime = _nextInstanceOfMonthDay(
        1,
        9,
        0,
      ); // 1st of month, 9 AM

      await _notifications.zonedSchedule(
        monthlyReportId,
        '📈 Monthly Progress Report',
        'Your monthly fitness journey summary is here! Great work! 🎉',
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'progress_reports',
            'Progress Reports',
            channelDescription: 'Weekly and monthly progress summaries',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/ic_notification_custom',
            color: Color(0xFF1DAB87),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      );

      print('✅ Monthly report scheduled successfully!');
    } catch (e) {
      print('❌ Error scheduling monthly report: $e');
      rethrow;
    }
  }

  Future<void> cancelMonthlyReport() async {
    await _notifications.cancel(monthlyReportId);
  }

  // ==================== HELPER METHODS ====================
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfWeekday(int dayOfWeek, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfMonthDay(int day, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = tz.TZDateTime(
        tz.local,
        now.month == 12 ? now.year + 1 : now.year,
        now.month == 12 ? 1 : now.month + 1,
        day,
        hour,
        minute,
      );
    }

    return scheduledDate;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Navigate to appropriate screen when notification is tapped
    // You'll need to implement navigation using a global navigator key
    print('Notification tapped: ${response.payload}');
  }

  // ==================== INACTIVITY REMINDER ====================
  /// Schedule a notification to remind inactive users (haven't used app in 3 days)
  Future<void> scheduleInactivityReminder() async {
    try {
      print('🔔 Scheduling inactivity reminder...');

      // Schedule for 3 days from now
      final scheduledTime = tz.TZDateTime.now(
        tz.local,
      ).add(const Duration(days: 3));

      await _notifications.zonedSchedule(
        inactivityReminderId,
        '💪 We Miss You!',
        'Your fitness journey is waiting! Come back and crush your goals! 🏋️',
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'inactivity_reminders',
            'Inactivity Reminders',
            channelDescription: 'Reminders when you haven\'t used the app',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/ic_notification_custom',
            color: Color(0xFF1DAB87),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      print('✅ Inactivity reminder scheduled for 3 days from now');
    } catch (e) {
      print('❌ Error scheduling inactivity reminder: $e');
      rethrow;
    }
  }

  /// Cancel the inactivity reminder (called when user opens the app)
  Future<void> cancelInactivityReminder() async {
    await _notifications.cancel(inactivityReminderId);
    print('✅ Inactivity reminder cancelled');
  }

  /// Reschedule inactivity reminder (call this when user opens the app)
  Future<void> resetInactivityTimer() async {
    await cancelInactivityReminder();
    await scheduleInactivityReminder();
    print('✅ Inactivity timer reset');
  }

  Future<bool> areNotificationsEnabled() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await androidPlugin?.areNotificationsEnabled() ?? false;
  }

  // ==================== CANCEL ALL ====================
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('✅ All notifications cancelled');
  }
}
