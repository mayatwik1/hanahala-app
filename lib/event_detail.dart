import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:ui' as ui;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class EventDetailPage extends StatelessWidget {
  final Map<String, dynamic> eventData;

  EventDetailPage({required this.eventData});

  Widget _buildImage(String? imageUrl) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: imageUrl != null && imageUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            )
          : Center(
              child: Text(
                'אין תמונה זמינה',
                style: TextStyle(color: Colors.black54),
              ),
            ),
    );
  }

  void _scheduleReminder(
      BuildContext context, String title, DateTime dateTime) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Directionality(
          textDirection: ui.TextDirection.rtl,
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      final scheduledTime = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      flutterLocalNotificationsPlugin.zonedSchedule(
        title.hashCode,
        title,
        'תזכורת לאירוע: $title',
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminder_channel',
            'Event Reminders',
            channelDescription: 'תזכורות לאירועים באפליקציה',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      Future.delayed(Duration(seconds: 3), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('תזכורת הוגדרה לשעה ${selectedTime.format(context)}')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = eventData['title'] ?? 'ללא כותרת';
    final description = eventData['description'] ?? 'אין תיאור';
    final location = eventData['location'] ?? 'מיקום לא זמין';
    final date =
        (eventData['date'] as DateTime?) ?? DateTime.now(); // Updated to 'date'
    final imageUrl = eventData['imageUrl'];

    return Scaffold(
      body: Stack(
        children: [
          // Background Layers
          Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.2,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 116, 169, 110),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(50),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          // Back Button
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          // Content
          Positioned(
            top: MediaQuery.of(context).size.height * 0.12,
            left: 16,
            right: 16,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Event Image
                  _buildImage(imageUrl),
                  SizedBox(height: 20),
                  // Event Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  // Event Description
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Event Details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on,
                          color: const Color.fromARGB(255, 0, 0, 0)),
                      SizedBox(width: 8),
                      Text(
                        location,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today,
                          color: const Color.fromARGB(255, 0, 0, 0)),
                      SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy | HH:mm', 'he')
                            .format(date),
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Reminder Button (Prettier + Smaller)
                  ElevatedButton.icon(
                    onPressed: () => _scheduleReminder(context, title, date),
                    icon: Icon(Icons.notifications_active,
                        size: 18, color: Colors.white),
                    label: Text(
                      'הזכר לי',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      elevation: 3,
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
