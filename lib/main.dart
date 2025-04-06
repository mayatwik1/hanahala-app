import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hanahala3/home.dart';
import 'package:hanahala3/login.dart';
import 'package:hanahala3/event_detail.dart';
import 'signup.dart';
import 'dart:convert';
import 'package:intl/date_symbol_data_local.dart'; // Import for locale initialization
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Notifications
import 'package:timezone/data/latest.dart' as tz; // Timezone data
import 'package:timezone/timezone.dart' as tz; // Timezone conversion

// Initialize the notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  await initializeDateFormatting('he'); // Initialize Hebrew locale for intl

  // Initialize Timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jerusalem'));

  // Initialize Notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
    onDidReceiveLocalNotification: (id, title, body, payload) async {
      // Handle iOS notification tap
    },
  );

  InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );



  await flutterLocalNotificationsPlugin.initialize(
  initializationSettings,
  onDidReceiveNotificationResponse: (NotificationResponse response) async {
    final String? payload = response.payload;

    if (payload != null) {
      final Map<String, dynamic> data = jsonDecode(payload);
      final int eventId = data['eventId'];

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => EventDetailPage(eventData: data),
        ),
      );
    }
  },
);



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       navigatorKey: navigatorKey,
      title: 'Event Reminder App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LogInPage(),
    );
  }
}

