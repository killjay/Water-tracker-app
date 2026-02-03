import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../services/tuning_engine.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Initialize notifications
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    await AppDateUtils.initialize();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  // Request permissions
  Future<bool> requestPermissions() async {
    if (!_initialized) {
      await initialize();
    }

    // Android 13+ requires runtime permission
    final androidInfo = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    return androidInfo ?? true;
  }

  // Schedule reminder with smart tuning
  Future<void> scheduleSmartReminder({
    required double totalConsumed,
    required double dailyGoal,
    required bool smartTuningEnabled,
    int? fixedIntervalMinutes,
  }) async {
    // Cancel existing reminders
    await cancelAllReminders();

    // Check if reminders are enabled
    final prefs = await SharedPreferences.getInstance();
    final reminderEnabled =
        prefs.getBool(AppConstants.reminderEnabledKey) ?? true;

    if (!reminderEnabled) return;

    // Request permissions
    final hasPermission = await requestPermissions();
    if (!hasPermission) return;

    final hoursRemaining = AppDateUtils.getHoursRemainingInDay();

    // Calculate next reminder interval
    final Duration interval;
    if (smartTuningEnabled) {
      interval = TuningEngine.calculateNextReminderInterval(
        totalConsumed: totalConsumed,
        hoursRemaining: hoursRemaining,
        dailyGoal: dailyGoal,
      );
    } else {
      final minutes = fixedIntervalMinutes ??
          prefs.getInt(AppConstants.reminderIntervalKey) ??
          60;
      interval = TuningEngine.getFixedReminderInterval(minutes);
    }

    // Schedule notification
    final scheduledDate = tz.TZDateTime.now(tz.local).add(interval);

    await _notifications.zonedSchedule(
      AppConstants.waterReminderNotificationId,
      'Time to hydrate! 💧',
      'Don\'t forget to drink water',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_reminder',
          'Water Reminders',
          channelDescription: 'Reminders to drink water',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Cancel all reminders
  Future<void> cancelAllReminders() async {
    await _notifications.cancel(AppConstants.waterReminderNotificationId);
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to home screen
    // This will be handled by the app's navigation logic
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.reminderEnabledKey) ?? true;
  }

  // Enable/disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.reminderEnabledKey, enabled);

    if (!enabled) {
      await cancelAllReminders();
    }
  }

  // Set reminder interval (for fixed reminders)
  Future<void> setReminderInterval(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.reminderIntervalKey, minutes);
  }

  // Set smart tuning enabled
  Future<void> setSmartTuningEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.smartTuningEnabledKey, enabled);
  }
}
