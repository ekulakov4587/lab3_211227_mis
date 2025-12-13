import 'package:flutter/material.dart';
// Firebase & messaging packages required:
// firebase_core, firebase_messaging, flutter_local_notifications, firebase_auth
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/home_page.dart';
import 'screens/favorites_page.dart';
import 'screens/random_meal_page.dart';

// NOTE: Add the following to pubspec.yaml and run `flutter pub get`:
// firebase_core: ^2.4.1
// firebase_messaging: ^14.2.1
// flutter_local_notifications: ^12.0.4
// firebase_auth: ^4.4.0
//
// Also follow platform Firebase configuration steps for Android/iOS (google-services.json / GoogleService-Info.plist).
// After platform config you may also run `flutterfire configure` (optional) to generate firebase_options.dart.

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If using background handling, ensure Firebase is initialized.
  await Firebase.initializeApp();
  // You can show a notification here if desired.
  final notification = message.notification;
  if (notification != null) {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails('default_channel', 'Default',
        channelDescription: 'Default channel for notifications',
        importance: Importance.max,
        priority: Priority.high);
    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformDetails,
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize local notifications
  const AndroidInitializationSettings androidInit =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
  InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Setup FCM
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request permissions for iOS (and on Android when needed)
  final fcm = FirebaseMessaging.instance;
  await fcm.requestPermission();

  // Optional: get token for testing
  String? token = await fcm.getToken();
  // print('FCM Token: $token'); // useful during development

  // Foreground message handler: display local notification when app is foregrounded
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final notification = message.notification;
    if (notification != null) {
      const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails('default_channel', 'Default',
          channelDescription: 'Default channel for notifications',
          importance: Importance.max,
          priority: Priority.high);
      const NotificationDetails platformDetails =
      NotificationDetails(android: androidDetails);
      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformDetails,
      );
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      // Keep routes for navigation to easy access
      routes: {
        '/': (context) => const HomePage(),
        '/favorites': (context) => const FavoritesPage(),
        '/random': (context) => const RandomMealPage(),
      },
      initialRoute: '/',
    );
  }
}
