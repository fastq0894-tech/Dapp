import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    // Initialize timezone
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kuwait'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    // Request permission for Android 13+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    // Request permission for iOS
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> scheduleShiftReminder({
    required DateTime shiftStartTime,
    required String shift,
    required String duty,
    required int notificationId,
  }) async {
    // Schedule 1 hour before shift
    final DateTime reminderTime = shiftStartTime.subtract(const Duration(hours: 1));

    if (reminderTime.isAfter(DateTime.now())) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        '⏰ Shift Reminder',
        'Shift $shift starts in 1 hour!\n$duty',
        tz.TZDateTime.from(reminderTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'shift_reminder_channel',
            'Shift Reminders',
            channelDescription: 'Reminders before your shift starts',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> scheduleAttendanceCheck({
    required DateTime shiftStartTime,
    required String shift,
    required int notificationId,
  }) async {
    // Schedule 2 hours after shift start
    final DateTime checkTime = shiftStartTime.add(const Duration(hours: 2));

    if (checkTime.isAfter(DateTime.now())) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        '📋 Attendance Check',
        'Have you checked in for Shift $shift?\nDon\'t forget to mark your attendance!',
        tz.TZDateTime.from(checkTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'attendance_channel',
            'Attendance Checks',
            channelDescription: 'Reminders to check attendance',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> scheduleShiftNotifications({
    required DateTime shiftStartTime,
    required String shift,
    required String duty,
    required int dayIndex,
  }) async {
    // Use dayIndex to create unique notification IDs
    final int reminderId = dayIndex * 10 + 1;
    final int attendanceId = dayIndex * 10 + 2;

    await scheduleShiftReminder(
      shiftStartTime: shiftStartTime,
      shift: shift,
      duty: duty,
      notificationId: reminderId,
    );

    await scheduleAttendanceCheck(
      shiftStartTime: shiftStartTime,
      shift: shift,
      notificationId: attendanceId,
    );
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
