import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FCMService {
  final supabase = Supabase.instance.client;

  Future<void> init() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // ✅ Request permission (IMPORTANT)
    await messaging.requestPermission();

    // ✅ Get token
    String? token = await messaging.getToken();

    final user = supabase.auth.currentUser;

    if (user != null && token != null) {
      await supabase.from('msg_profiles').upsert({
        'id': user.id,
        'fcm_token': token,
      });
    }

    // ✅ Handle token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final user = supabase.auth.currentUser;

      if (user != null) {
        await supabase.from('msg_profiles').upsert({
          'id': user.id,
          'fcm_token': newToken,
        });
      }
    });
  }
}