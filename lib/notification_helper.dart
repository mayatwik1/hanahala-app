import 'dart:convert'; // For converting payload data to JSON
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Flutter notifications package
import 'package:timezone/timezone.dart' as tz; // For scheduling notifications in local timezone

/// A helper class to manage and schedule local notifications
class NotificationHelper {
  // Create an instance of the notifications plugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Schedules a notification at a specific time with optional custom data (payload).
  ///
  /// Parameters:
  /// - [id]: A unique ID for this notification (useful for cancelling or updating).
  /// - [title]: The title shown in the notification.
  /// - [body]: The message body shown in the notification.
  /// - [scheduledTime]: The exact date and time to show the notification.
  /// - [payloadData]: Optional map of data to send with the notification (e.g., IDs, names).
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, dynamic>? payloadData,
  }) async {
    // Android-specific notification settings
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'event_reminder_channel', // Channel ID
      'Event Reminders', // Channel name (shown in settings)
      channelDescription: 'Notifications for event reminders', // Description of what this channel is for
      importance: Importance.max, // Highest importance
      priority: Priority.high, // Show the notification immediately
    );

    // iOS-specific notification settings
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    // Combine platform-specific settings
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // If there is custom data, encode it into a JSON string
    final String? payload =
        payloadData != null ? jsonEncode(payloadData) : null;

    // Schedule the notification at the specified time using local timezone
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id, // Notification ID
      title, // Title
      body, // Body text
      tz.TZDateTime.from(scheduledTime, tz.local), // When to show the notification
      notificationDetails, // Notification style/config
      androidAllowWhileIdle: true, // Show notification even when app is idle
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime, // Interpret time exactly
      payload: payload, // Optional custom data passed along
    );
  }
}
