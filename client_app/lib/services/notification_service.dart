import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/reminder_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();

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

    await _plugin.initialize(initSettings);
  }

  static Future<bool> requestPermissions() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final granted = await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosGranted = await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return granted ?? iosGranted ?? true;
  }

  static Future<void> scheduleReminder(ReminderModel reminder) async {
    if (!reminder.isEnabled) {
      await cancelReminder(reminder.notificationId);
      return;
    }

    final scheduledDate = tz.TZDateTime.from(reminder.dateTime, tz.local);

    // Don't schedule for past dates
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    const androidDetails = AndroidNotificationDetails(
      'pocket_khoroch_reminders',
      'Pocket Khoroch Reminders',
      channelDescription: 'Bill, savings, and semester fee reminders',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFF18251D),
    );
    const iosDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    DateTimeComponents? matchComponents;
    switch (reminder.repeatEnum) {
      case ReminderRepeat.daily:
        matchComponents = DateTimeComponents.time;
        break;
      case ReminderRepeat.weekly:
        matchComponents = DateTimeComponents.dayOfWeekAndTime;
        break;
      case ReminderRepeat.monthly:
        matchComponents = DateTimeComponents.dayOfMonthAndTime;
        break;
      case ReminderRepeat.yearly:
        matchComponents = DateTimeComponents.dateAndTime;
        break;
      case ReminderRepeat.none:
        matchComponents = null;
        break;
    }

    await _plugin.zonedSchedule(
      reminder.notificationId,
      reminder.title,
      reminder.note ?? 'Tap to open Pocket Khoroch',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: matchComponents,
    );
  }

  static Future<void> cancelReminder(int notificationId) async {
    await _plugin.cancel(notificationId);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
