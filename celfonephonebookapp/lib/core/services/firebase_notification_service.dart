import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // 1. Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Get FCM token
    final token = await _messaging.getToken();

    if (token != null) {
      await saveToken(token);
    }

    // 3. Token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      await saveToken(token);
    });

    //All users
    await FirebaseMessaging.instance.subscribeToTopic('all_users');

    await FirebaseMessaging.instance.subscribeToTopic('business');


    // 4. Foreground notifications
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 5. Notification tapped
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // 6. App opened from a terminated state by tapping a notification
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  Future<void> saveToken(String token) async {
    // Save token to Supabase
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");
    print("Data: ${message.data}");

    // TODO: Show a local notification here if desired.
  }

  void _handleNotificationTap(RemoteMessage message) {
    print("Notification tapped");
    print(message.data);

    // TODO: Navigate to the correct screen based on message.data.
  }
}