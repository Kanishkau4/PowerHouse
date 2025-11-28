import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
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

  Future<void> scheduleDailyTipNotification({
    required int hour,
    required int minute,
  }) async {
    try {
      print('🔔 Scheduling daily tip notification for $hour:$minute');

      // Cancel existing notifications
      await _notifications.cancel(0);
      print('✅ Cancelled existing notifications');

      final scheduledTime = _nextInstanceOfTime(hour, minute);
      print('📅 Next notification scheduled for: $scheduledTime');

      // Schedule daily notification
      await _notifications.zonedSchedule(
        0, // Notification ID
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
            icon: '@mipmap/ic_launcher',
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

  Future<void> cancelDailyNotifications() async {
    await _notifications.cancel(0);
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Navigate to tips library when notification is tapped
    // You'll need to implement navigation using a global navigator key
    print('Notification tapped: ${response.payload}');
  }

  Future<bool> areNotificationsEnabled() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await androidPlugin?.areNotificationsEnabled() ?? false;
  }
}
